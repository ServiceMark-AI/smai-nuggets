class Location < ApplicationRecord
  belongs_to :tenant
  belongs_to :created_by_user, class_name: "User", optional: true
  belongs_to :updated_by_user, class_name: "User", optional: true
  has_many :users, dependent: :nullify
  has_many :invitations, dependent: :nullify
  has_many :job_proposals, dependent: :nullify
  has_many :email_suppressions, dependent: :destroy

  validates :display_name, presence: true
  validates :address_line_1, presence: true
  validates :city, presence: true
  validates :state,
            presence: true,
            format: { with: /\A[A-Z]{2}\z/, message: "must be a 2-letter US state code" }
  validates :postal_code, presence: true
  validates :phone_number, presence: true

  scope :active, -> { where(is_active: true) }

  before_validation :upcase_state

  private

  def upcase_state
    self.state = state.upcase if state.present?
  end
end
