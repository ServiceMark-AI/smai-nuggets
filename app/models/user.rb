class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  belongs_to :tenant, optional: true
  belongs_to :location, optional: true
  has_many :email_delegations, dependent: :destroy

  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }, allow_blank: true

  def full_name
    [first_name, last_name].compact_blank.join(" ").presence
  end

  def display_name
    full_name || email
  end

  # An "account admin" is a tenant user with no location assignment;
  # SMAI staff (is_admin) can invite from any tenant context they're
  # attached to. Regular tenant users (those scoped to a location)
  # can't invite.
  def can_invite_into_tenant?
    return false if tenant_id.nil?
    is_admin || location_id.nil?
  end
end
