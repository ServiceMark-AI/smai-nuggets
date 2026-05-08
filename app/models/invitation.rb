class Invitation < ApplicationRecord
  belongs_to :tenant
  belongs_to :organization
  belongs_to :location, optional: true
  belongs_to :invited_by_user, class_name: "User"

  validates :email, presence: true
  validates :token, presence: true, uniqueness: true
  validate :location_must_belong_to_tenant

  before_validation :assign_token, on: :create
  before_validation :assign_expiration, on: :create

  def self.find_active_by_token(token)
    where("expires_at > ? AND accepted_at IS NULL", Time.current).find_by(token: token)
  end

  # Operator-readable reasons the invite-send form should be disabled.
  # Empty array means everything required to send is in place. Both
  # conditions must hold:
  #   - APP_HOST set (otherwise the absolute URL inside the email body
  #     points at localhost or fails URL helpers entirely)
  #   - ApplicationMailbox connected (otherwise there's no Gmail account
  #     authenticated to send through)
  def self.send_blockers
    blockers = []
    blockers << "APP_HOST is not set, so the invite link in the email would be broken." if ENV["APP_HOST"].blank?
    blockers << "No Gmail account is connected as the application mailbox, so there's nothing to send through." if ApplicationMailbox.current.nil?
    blockers
  end

  def self.can_send?
    send_blockers.empty?
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
      user.update!(location: location) if location_id.present? && user.location_id.nil?
      OrganizationalMember.find_or_create_by!(organization: organization, user: user) { |m| m.role = :member }
      # users.is_pending defaults to true at insert; clearing it here is
      # the only place a real user transitions from "Pending" to "Active"
      # in the Users tables. Without this, an invited user keeps showing
      # the Pending badge after they sign up and join the tenant.
      user.update!(is_pending: false) if user.is_pending
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

  def location_must_belong_to_tenant
    return if location.nil? || tenant_id.nil?
    return if location.organization&.tenant_id == tenant_id

    errors.add(:location, "must belong to the same tenant as the invitation")
  end
end
