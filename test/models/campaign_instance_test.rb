require "test_helper"

class CampaignInstanceTest < ActiveSupport::TestCase
  setup do
    @campaign = campaigns(:approved_campaign)
    @proposal = job_proposals(:in_users_org)
  end

  test "creates an instance hosted on a job proposal and defaults to active" do
    instance = CampaignInstance.create!(campaign: @campaign, host: @proposal)
    assert_equal "active", instance.status
    assert instance.status_active?
    assert_equal @proposal, instance.host
    assert_equal "JobProposal", instance.host_type
    assert_equal @proposal.id, instance.host_id
  end

  test "exposes all defined status transitions" do
    instance = CampaignInstance.create!(campaign: @campaign, host: @proposal)
    %w[active paused completed stopped_on_reply stopped_on_delivery_issue stopped_on_closure].each do |s|
      instance.update!(status: s)
      assert_equal s, instance.status
    end
  end

  test "rejects an unknown status value" do
    assert_raises ArgumentError do
      CampaignInstance.new(campaign: @campaign, host: @proposal, status: "not_a_status")
    end
  end

  test "requires a campaign and a host" do
    bare = CampaignInstance.new
    assert_not bare.valid?
    assert bare.errors[:campaign].any?
    assert bare.errors[:host].any?
  end

  test "campaign exposes its instances and job_proposal exposes campaign_instances" do
    instance = CampaignInstance.create!(campaign: @campaign, host: @proposal)
    assert_includes @campaign.reload.instances, instance
    assert_includes @proposal.reload.campaign_instances, instance
  end

  test "deleting the host job proposal destroys its campaign instances" do
    proposal = JobProposal.create!(
      tenant: tenants(:one),
      location: locations(:ne_dallas),
      owner: users(:one),
      created_by_user: users(:one)
    )
    CampaignInstance.create!(campaign: @campaign, host: proposal)
    assert_difference "CampaignInstance.count", -1 do
      proposal.destroy
    end
  end

  test "deleting the parent campaign destroys its instances" do
    campaign = Campaign.create!(name: "Throwaway")
    revision = campaign.revisions.create!(revision_number: 0, status: :active, created_by_user: users(:admin))
    CampaignInstance.create!(campaign: campaign, campaign_revision: revision, host: @proposal)
    assert_difference "CampaignInstance.count", -1 do
      campaign.destroy
    end
  end
end
