class Admin::InvitationsController < Admin::BaseController
  before_action :set_tenant

  def create
    blockers = Invitation.send_blockers
    if blockers.any?
      redirect_to admin_tenant_path(@tenant),
        alert: "Can't send invitations yet: #{blockers.join(' ')}" and return
    end

    is_account_admin = ActiveModel::Type::Boolean.new.cast(params.dig(:invitation, :is_account_admin))
    location_id = params.dig(:invitation, :location_id).presence

    if !is_account_admin && location_id.blank?
      redirect_to admin_tenant_path(@tenant),
        alert: "Pick a location, or check Is Account Admin." and return
    end

    location = nil
    if location_id.present?
      location = @tenant.locations.find_by(id: location_id)
      if location.nil?
        redirect_to admin_tenant_path(@tenant),
          alert: "That location isn't part of this tenant." and return
      end
    end

    email = params.dig(:invitation, :email).to_s.strip
    existing = email.blank? ? nil : User.find_by(email: email.downcase)
    if existing
      result = handle_existing_user_invite(existing, tenant: @tenant, location: location)
      redirect_to admin_tenant_path(@tenant), **result and return
    end

    invitation = @tenant.invitations.build(
      invited_by_user: current_user,
      email: email,
      location: location,
      first_name: params.dig(:invitation, :first_name).to_s.strip.presence,
      last_name: params.dig(:invitation, :last_name).to_s.strip.presence,
      phone_number: params.dig(:invitation, :phone_number).to_s.strip.presence,
      title: params.dig(:invitation, :title).to_s.strip.presence
    )

    if invitation.save
      mailbox = ApplicationMailbox.current
      if mailbox.nil?
        redirect_to admin_tenant_path(@tenant),
          notice: "Invitation created for #{invitation.email}, but no application mailbox is connected — email not sent. Connect one at /admin/application_mailbox."
        return
      end

      mail = InvitationMailer.with(invitation: invitation).invite.message
      sent = GmailSender.new(mailbox).send_mail(mail)
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
  # tenant resolution (current_user.tenant vs @tenant) differs.
  def handle_existing_user_invite(user, tenant:, location: nil)
    if user.is_admin
      return { alert: "#{user.email} is a system admin — admins aren't added through tenant invites." }
    end
    if user.tenant && user.tenant_id != tenant.id
      return { alert: "#{user.email} already belongs to another tenant; can't add them here." }
    end
    if user.tenant_id == tenant.id
      return { alert: "#{user.email} is already in #{tenant.name}." }
    end

    User.transaction do
      user.update!(tenant: tenant)
      user.update!(location: location) if location && user.location_id.nil?
    end
    { notice: "Added #{user.email} to #{tenant.name}." }
  end

end
