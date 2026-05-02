class PdfProcessingRevision < ApplicationRecord
  belongs_to :model

  validates :instructions, presence: true
  validates :revision_number, presence: true, uniqueness: true

  before_validation :assign_revision_number, on: :create

  def self.is_current
    order(revision_number: :desc).first
  end

  private

  def assign_revision_number
    return if revision_number.present?
    self.revision_number = (self.class.maximum(:revision_number) || 0) + 1
  end
end
