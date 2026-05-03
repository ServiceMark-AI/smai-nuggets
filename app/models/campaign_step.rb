class CampaignStep < ApplicationRecord
  belongs_to :campaign, inverse_of: :steps

  has_many :step_instances, class_name: "CampaignStepInstance", dependent: :destroy

  validates :sequence_number, presence: true, uniqueness: { scope: :campaign_id }
  validates :offset_min, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Virtual day / hour / minute setters for the step-edit form. The form
  # collects the three independently and we compose them back into the
  # canonical offset_min on save. Readers fall back to splitting the
  # stored offset_min when no override was set, so the form pre-fills
  # correctly when editing.
  def offset_days=(value);    @offset_days_input    = value; end
  def offset_hours=(value);   @offset_hours_input   = value; end
  def offset_minutes=(value); @offset_minutes_input = value; end

  def offset_days
    return @offset_days_input.to_i if @offset_days_input
    offset_min.to_i / (24 * 60)
  end

  def offset_hours
    return @offset_hours_input.to_i if @offset_hours_input
    (offset_min.to_i % (24 * 60)) / 60
  end

  def offset_minutes
    return @offset_minutes_input.to_i if @offset_minutes_input
    offset_min.to_i % 60
  end

  before_validation :compose_offset_min

  private

  def compose_offset_min
    return unless @offset_days_input || @offset_hours_input || @offset_minutes_input
    self.offset_min = @offset_days_input.to_i * 1440 +
                      @offset_hours_input.to_i * 60 +
                      @offset_minutes_input.to_i
  end
end
