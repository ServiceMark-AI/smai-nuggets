class InvitationMailer < ApplicationMailer
  layout false

  # The address part is a placeholder under the RFC-2606 .invalid TLD.
  # GmailSender#rewrite_from replaces it with the connected
  # ApplicationMailbox at send time, preserving the display name so
  # recipients see   "Inga Vega" <connected-mailbox@gmail.com>.
  FROM_PLACEHOLDER_ADDRESS = "noreply@smai.invalid".freeze

  def invite
    @invitation = params[:invitation]
    @inviter    = @invitation.invited_by_user
    @tenant     = @invitation.tenant
    @from_admin = @inviter.is_admin
    @inviter_name = @inviter.full_name.presence || @inviter.email
    @display_name = @from_admin ? "ServiceMark AI Admin" : @inviter_name
    @accept_url = invitation_url(@invitation.token)
    @expires_at = @invitation.expires_at

    subject = if @from_admin
                "You've been invited to #{@tenant.name} on ServiceMark AI"
              else
                "#{@inviter_name} invited you to #{@tenant.name} on ServiceMark AI"
              end

    mail(
      to: @invitation.email,
      from: %("#{@display_name}" <#{FROM_PLACEHOLDER_ADDRESS}>),
      subject: subject
    )
  end
end
