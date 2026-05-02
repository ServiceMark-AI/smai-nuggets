class JobProposalAttachment < ApplicationRecord
  belongs_to :job_proposal
  belongs_to :uploaded_by_user, class_name: "User", optional: true

  has_one_attached :file

  validates :file, presence: true
end
