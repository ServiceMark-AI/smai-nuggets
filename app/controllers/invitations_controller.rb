class InvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @invitation = Invitation.find_active_by_token(params[:id])
    if @invitation.nil?
      redirect_to root_path, alert: "Invitation not found or expired."
      return
    end

    if user_signed_in?
      @invitation.accept!(current_user)
      redirect_to root_path, notice: "Welcome to #{@invitation.tenant.name}!"
    else
      session[:invitation_token] = @invitation.token
      redirect_to new_user_registration_path(email: @invitation.email),
        notice: "You've been invited to #{@invitation.tenant.name}. Sign up to accept."
    end
  end

  def create
    tenant = current_user.tenant
    if tenant.nil?
      redirect_to users_path, alert: "You're not assigned to a tenant yet."
      return
    end

    blockers = Invitation.send_blockers
    if blockers.any?
      redirect_to users_path, alert: "Can't send invitations yet: #{blockers.join(' ')}"
      return
    end

    organization = tenant.organizations.where(parent_id: nil).first || tenant.organizations.first
    if organization.nil?
      redirect_to users_path, alert: "Your tenant has no organization to attach the invite to."
      return
    end

    email = params.dig(:invitation, :email).to_s.strip
    existing = email.blank? ? nil : User.find_by(email: email.downcase)
    if existing
      result = handle_existing_user_invite(existing, tenant: tenant, organization: organization)
      redirect_to users_path, **result and return
    end

    invitation = tenant.invitations.build(
      organization: organization,
      invited_by_user: current_user,
      email: email
    )

    if invitation.save
      mailbox = ApplicationMailbox.current
      if mailbox.nil?
        redirect_to users_path,
          notice: "Invitation created for #{invitation.email}, but no application mailbox is connected — email not sent. An admin can connect one at /admin/application_mailbox."
        return
      end

      mail = InvitationMailer.with(invitation: invitation).invite.message
      sent = GmailSender.new(mailbox).send_mail(mail)
      if sent
        redirect_to users_path, notice: "Invitation sent to #{invitation.email}."
      else
        redirect_to users_path, alert: "Invitation saved but the email failed to send."
      end
    else
      redirect_to users_path, alert: invitation.errors.full_messages.to_sentence
    end
  end

  def destroy
    invitation = current_user.tenant&.invitations&.find_by(id: params[:id])
    if invitation.nil?
      redirect_to users_path, alert: "Invitation not found." and return
    end
    if invitation.accepted?
      redirect_to users_path, alert: "That invitation has already been accepted and can't be revoked." and return
    end

    email = invitation.email
    invitation.destroy
    redirect_to users_path, notice: "Revoked invitation for #{email}."
  end

  private

  # Resolves the "invite an existing user" path. Returns a hash suitable
  # for redirect_to **result (either { notice: ... } or { alert: ... }):
  #   - admin user: rejected (admins aren't tenant-scoped)
  #   - belongs to a different tenant: rejected
  #   - already in this organization: rejected with a friendly note
  #   - exists, no tenant or same tenant, not in this org: silently added
  #     to the org (and tenant set if previously nil); no email sent
  def handle_existing_user_invite(user, tenant:, organization:)
    if user.is_admin
      return { alert: "#{user.email} is a system admin — admins aren't added through tenant invites." }
    end
    if user.tenant && user.tenant_id != tenant.id
      return { alert: "#{user.email} already belongs to another tenant; can't add them here." }
    end
    if user.organizations.include?(organization)
      return { alert: "#{user.email} is already a member of #{organization.name}." }
    end

    User.transaction do
      user.update!(tenant: tenant) if user.tenant.nil?
      OrganizationalMember.create!(user: user, organization: organization, role: :member)
    end
    { notice: "Added #{user.email} to #{organization.name}." }
  end

end
