class Admin::InvitationsController < Admin::BaseController
  before_action :set_tenant

  def create
    blockers = Invitation.send_blockers
    if blockers.any?
      redirect_to admin_tenant_path(@tenant),
        alert: "Can't send invitations yet: #{blockers.join(' ')}" and return
    end

    organization = @tenant.organizations.where(parent_id: nil).first ||
                   @tenant.organizations.first

    email = params.dig(:invitation, :email).to_s.strip
    existing = email.blank? ? nil : User.find_by(email: email.downcase)
    if existing
      result = handle_existing_user_invite(existing, tenant: @tenant, organization: organization)
      redirect_to admin_tenant_path(@tenant), **result and return
    end

    invitation = @tenant.invitations.build(
      organization: organization,
      invited_by_user: current_user,
      email: email
    )

    if invitation.save
      mailbox = ApplicationMailbox.current
      if mailbox.nil?
        redirect_to admin_tenant_path(@tenant),
          notice: "Invitation created for #{invitation.email}, but no application mailbox is connected — email not sent. Connect one at /admin/application_mailbox."
        return
      end

      sent = GmailSender.new(mailbox).send_email(
        to: invitation.email,
        subject: "You're invited to #{@tenant.name}",
        body: invitation_body(invitation)
      )
      if sent
        redirect_to admin_tenant_path(@tenant), notice: "Invitation sent to #{invitation.email}."
      else
        redirect_to admin_tenant_path(@tenant), alert: "Invitation saved but the email failed to send."
      end
    else
      redirect_to admin_tenant_path(@tenant), alert: invitation.errors.full_messages.to_sentence
    end
  end

  def destroy
    invitation = @tenant.invitations.find_by(id: params[:id])
    if invitation.nil?
      redirect_to admin_tenant_path(@tenant), alert: "Invitation not found." and return
    end
    if invitation.accepted?
      redirect_to admin_tenant_path(@tenant),
        alert: "That invitation has already been accepted and can't be revoked." and return
    end

    email = invitation.email
    invitation.destroy
    redirect_to admin_tenant_path(@tenant), notice: "Revoked invitation for #{email}."
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:tenant_id])
  end

  # Same shape as InvitationsController#handle_existing_user_invite —
  # see the comment there. Inlined rather than extracted because the
  # tenant resolution (current_user.tenant vs @tenant) differs and the
  # rest is small.
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

  def invitation_body(invitation)
    accept = invitation_url(invitation.token)
    <<~BODY
      Hi,

      #{current_user.full_name || current_user.email} has invited you to join #{@tenant.name} on SMAI.

      Click here to accept (link expires #{invitation.expires_at.to_fs(:long)}):
      #{accept}

      If you don't have an account yet, you'll be asked to sign up — your tenant and organization will be set automatically.
    BODY
  end
end
