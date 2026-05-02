class CampaignStepInstance < ApplicationRecord
  belongs_to :campaign_instance
  belongs_to :campaign_step

  enum :email_delivery_status, {
    pending: 0,
    sending: 1,
    sent: 2,
    failed: 3,
    bounced: 4
  }, prefix: true
end
