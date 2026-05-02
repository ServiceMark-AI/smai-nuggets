class Invitation < ApplicationRecord
  belongs_to :tenant
  belongs_to :organization
  belongs_to :invited_by_user, class_name: "User"

  validates :email, presence: true
  validates :token, presence: true, uniqueness: true

  before_validation :assign_token, on: :create
  before_validation :assign_expiration, on: :create

  def self.find_active_by_token(token)
    where("expires_at > ? AND accepted_at IS NULL", Time.current).find_by(token: token)
  end

  def expired?
    expires_at <= Time.current
  end

  def accepted?
    accepted_at.present?
  end

  def accept!(user)
    transaction do
      user.update!(tenant: tenant) if user.tenant_id.nil?
      OrganizationalMember.find_or_create_by!(organization: organization, user: user) { |m| m.role = :member }
      update!(accepted_at: Time.current)
    end
  end

  private

  def assign_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def assign_expiration
    self.expires_at ||= 7.days.from_now
  end
end
