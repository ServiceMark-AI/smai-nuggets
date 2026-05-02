class OrganizationalMember < ApplicationRecord
  belongs_to :organization
  belongs_to :user

  enum :role, { member: 0, admin: 1 }

  validates :user_id, uniqueness: { scope: :organization_id }
end
