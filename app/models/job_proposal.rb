class JobProposal < ApplicationRecord
  belongs_to :tenant
  belongs_to :organization
  belongs_to :owner, class_name: "User"
  belongs_to :created_by_user, class_name: "User"
  belongs_to :closed_by_user, class_name: "User", optional: true
  belongs_to :job_type, optional: true

  has_many :attachments, class_name: "JobProposalAttachment", dependent: :destroy

  enum :status, { new: 0, open: 1, closed: 2 }, prefix: true

  # Street number + street, with whitespace squeezed and stripped.
  # Returns nil when both fields are blank so callers can fall back to a placeholder.
  def short_address
    parts = [customer_house_number, customer_street].map { |p| p.to_s.strip }
    joined = parts.reject(&:empty?).join(" ")
    joined.presence
  end
end
