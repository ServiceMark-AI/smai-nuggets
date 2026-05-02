class Admin::InvitationsController < Admin::BaseController
  before_action :set_tenant

  def create
    organization = @tenant.organizations.where(parent_id: nil).first ||
                   @tenant.organizations.first
    invitation = @tenant.invitations.build(
      organization: organization,
      invited_by_user: current_user,
      email: params.dig(:invitation, :email).to_s.strip
    )

    if invitation.save
      delegation = current_user.email_delegations.first
      if delegation.nil?
        redirect_to admin_tenant_path(@tenant),
          notice: "Invitation created for #{invitation.email}, but no Gmail account is connected on your profile yet — email not sent."
        return
      end

      sent = GmailSender.new(delegation).send_email(
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

  private

  def set_tenant
    @tenant = Tenant.find(params[:tenant_id])
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
