class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      claim_pending_invitation(user) if user.persisted?
    end
  end

  private

  def claim_pending_invitation(user)
    token = session.delete(:invitation_token)
    return if token.blank?

    invitation = Invitation.find_active_by_token(token)
    invitation&.accept!(user)
  end
end
