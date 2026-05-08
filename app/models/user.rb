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
end
