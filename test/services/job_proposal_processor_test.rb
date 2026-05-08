require "test_helper"

class JobProposalProcessorTest < ActiveSupport::TestCase
  setup do
    tenant = tenants(:one)
    @proposal = JobProposal.create!(
      tenant: tenant,
      owner: users(:one), created_by_user: users(:one)
    )
    att = @proposal.attachments.build(uploaded_by_user: users(:one))
    att.file.attach(io: StringIO.new("fake pdf bytes"), filename: "p.pdf", content_type: "application/pdf")
    att.save!
  end

  test "stub mode applies sample fields when AI credentials aren't available" do
    # Rails.env.test? short-circuits ai_credentials_available?, so test
    # env always takes the stub branch.
    result = JobProposalProcessor.new(@proposal).process
    assert_equal :stub, result.mode
    assert_nil result.error
    assert result.applied?
    refute result.ai_failed?

    @proposal.reload
    assert_equal "Sample", @proposal.customer_first_name
    assert @proposal.internal_reference.to_s.start_with?("STUB-")
  end

  test "ai_failed mode surfaces the error and leaves customer fields blank" do
    # Force the AI branch on by stubbing ai_credentials_available? to true,
    # then make the inner extract call raise — that's what happens in real
    # life when Gemini returns 429 / credits depleted / network error.
    processor = JobProposalProcessor.new(@proposal)
    processor.define_singleton_method(:ai_credentials_available?) { |_rev| true }
    processor.define_singleton_method(:extract_via_ai) do |_rev|
      @ai_error = "RateLimitError: prepayment credits depleted"
      nil
    end

    result = processor.process
    assert_equal :ai_failed, result.mode
    refute result.applied?
    assert_match(/credits depleted/i, result.error)

    @proposal.reload
    assert_nil @proposal.customer_first_name
    assert_nil @proposal.internal_reference
    assert_nil @proposal.proposal_value
  end
end
