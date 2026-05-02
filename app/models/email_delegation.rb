class EmailDelegation < ApplicationRecord
  belongs_to :user

  validates :provider, :email, :access_token, presence: true
  validates :email, uniqueness: { scope: [:user_id, :provider] }

  def expired?
    expires_at.present? && expires_at <= Time.current
  end
end
