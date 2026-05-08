require "test_helper"

class JobProposalsHelperTest < ActionView::TestCase
  test "proposal_job_type_label strips a trailing 'Job type' suffix" do
    jp = JobProposal.new(job_type: JobType.new(name: "Development Job Type"))
    assert_equal "Development", proposal_job_type_label(jp)
  end

  test "proposal_job_type_label leaves names without the suffix unchanged" do
    jp = JobProposal.new(job_type: JobType.new(name: "Water Mitigation"))
    assert_equal "Water Mitigation", proposal_job_type_label(jp)
  end

  test "proposal_job_type_label is case-insensitive on the suffix" do
    jp = JobProposal.new(job_type: JobType.new(name: "Demo job TYPE"))
    assert_equal "Demo", proposal_job_type_label(jp)
  end

  test "proposal_job_type_label returns nil when there is no job type" do
    jp = JobProposal.new(job_type: nil)
    assert_nil proposal_job_type_label(jp)
  end

end
