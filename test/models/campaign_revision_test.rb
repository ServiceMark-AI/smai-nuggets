require "test_helper"

class CampaignRevisionTest < ActiveSupport::TestCase
  setup do
    @campaign = campaigns(:approved_campaign)
    @user     = users(:admin)
  end

  test "valid with required fields" do
    rev = @campaign.revisions.build(
      revision_number: 1,
      status:          :drafting,
      created_by_user: @user
    )
    assert rev.valid?, rev.errors.full_messages.to_sentence
  end

  test "revision_number is unique within a campaign" do
    @campaign.revisions.create!(revision_number: 5, status: :drafting, created_by_user: @user)
    dup = @campaign.revisions.build(revision_number: 5, status: :drafting, created_by_user: @user)
    refute dup.valid?
    assert_includes dup.errors[:revision_number], "has already been taken"
  end

  test "two campaigns can each have their own revision_number 0" do
    a = campaigns(:approved_campaign)
    b = campaigns(:draft_campaign)
    assert_equal 0, a.revisions.find_by!(status: :active).revision_number
    assert_equal 0, b.revisions.find_by!(status: :active).revision_number
  end

  test "only one active revision per campaign" do
    second_active = @campaign.revisions.build(
      revision_number: 99,
      status:          :active,
      created_by_user: @user
    )
    refute second_active.valid?
    assert_includes second_active.errors[:status],
                    "can only be active on one revision per campaign"
  end

  test "spawn_draft_from_active copies the active revision's steps and bumps the revision number" do
    draft = nil
    assert_difference -> { @campaign.revisions.count }, 1 do
      assert_difference -> { CampaignStep.count }, @campaign.active_revision.steps.count do
        draft = CampaignRevision.spawn_draft_from_active(campaign: @campaign, user: @user)
      end
    end
    assert draft.status_drafting?
    assert_equal 1, draft.revision_number, "expected next revision_number after fixture's revision 0"
    assert_equal @campaign.active_revision.steps.size, draft.steps.size
    # Subjects and bodies are carried verbatim.
    assert_equal @campaign.active_revision.steps.pluck(:template_subject).sort,
                 draft.steps.pluck(:template_subject).sort
  end

  test "spawn_draft_from_active works on a campaign with no active revision (no-op for steps)" do
    fresh = Campaign.create!(name: "Fresh, no revision")
    draft = CampaignRevision.spawn_draft_from_active(campaign: fresh, user: @user)
    assert draft.status_drafting?
    assert_equal 0, draft.revision_number
    assert_empty draft.steps
  end
end
