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

    organization = tenant.organizations.where(parent_id: nil).first || tenant.organizations.first
    if organization.nil?
      redirect_to users_path, alert: "Your tenant has no organization to attach the invite to."
      return
    end

    invitation = tenant.invitations.build(
      organization: organization,
      invited_by_user: current_user,
      email: params.dig(:invitation, :email).to_s.strip
    )

    if invitation.save
      mailbox = ApplicationMailbox.current
      if mailbox.nil?
        redirect_to users_path,
          notice: "Invitation created for #{invitation.email}, but no application mailbox is connected — email not sent. An admin can connect one at /admin/application_mailbox."
        return
      end

      sent = GmailSender.new(mailbox).send_email(
        to: invitation.email,
        subject: "You're invited to #{tenant.name}",
        body: invitation_body(invitation, tenant)
      )
      if sent
        redirect_to users_path, notice: "Invitation sent to #{invitation.email}."
      else
        redirect_to users_path, alert: "Invitation saved but the email failed to send."
      end
    else
      redirect_to users_path, alert: invitation.errors.full_messages.to_sentence
    end
  end

  private

  def invitation_body(invitation, tenant)
    accept = invitation_url(invitation.token)
    <<~BODY
      Hi,

      #{current_user.full_name || current_user.email} has invited you to join #{tenant.name} on SMAI.

      Click here to accept (link expires #{invitation.expires_at.to_fs(:long)}):
      #{accept}

      If you don't have an account yet, you'll be asked to sign up — your tenant and organization will be set automatically.
    BODY
  end
end
