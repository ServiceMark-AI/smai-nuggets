# Extracts customer / job-detail fields from an uploaded proposal PDF and
# writes them onto the JobProposal. Three execution modes:
#
#   :ai       — credentials configured + extraction succeeded; fields applied
#   :ai_failed — credentials configured + extraction errored; NO fields
#                applied, error surfaces in the result so the controller
#                can flash a message to the operator
#   :stub     — credentials NOT configured (test env, or no API key
#                set, or no current PdfProcessingRevision); the static
#                stub_response fills the fields so dev UX still works
#                without burning API credits
#
# Critically: the AI-failed path no longer silently substitutes the stub.
# The previous behavior masked rate-limit / credit-depletion errors
# because the operator saw plausible-looking sample data and assumed
# the upload had been parsed.
class JobProposalProcessor
  PROVIDER_ENV_KEYS = {
    "gemini" => "GEMINI_API_KEY"
  }.freeze

  Result = Data.define(:mode, :error, :data) do
    def stub? = mode == :stub
    def ai_failed? = mode == :ai_failed
    def applied? = mode != :ai_failed
  end

  def initialize(job_proposal)
    @job_proposal = job_proposal
  end

  def process
    revision = PdfProcessingRevision.is_current
    if ai_credentials_available?(revision)
      data = extract_via_ai(revision)
      if data.is_a?(Hash)
        apply_extracted_fields(data)
        Result.new(mode: :ai, error: nil, data: data)
      else
        Result.new(mode: :ai_failed, error: @ai_error || "AI extraction returned no data.", data: nil)
      end
    else
      data = stub_response
      apply_extracted_fields(data)
      Result.new(mode: :stub, error: nil, data: data)
    end
  end

  private

  def ai_credentials_available?(revision)
    return false if Rails.env.test?
    return false unless revision&.model

    key_name = PROVIDER_ENV_KEYS[revision.model.provider]
    key_name.present? && ENV[key_name].present?
  end

  def extract_via_ai(revision)
    attachment = @job_proposal.attachments.first
    return nil unless attachment&.file&.attached?

    Tempfile.create(["upload", File.extname(attachment.file.filename.to_s)]) do |tempfile|
      tempfile.binmode
      tempfile.write(attachment.file.download)
      tempfile.flush

      chat = Chat.create!(model_id: revision.model.model_id)
      chat.with_instructions(revision.instructions)
      response = chat.ask("Extract the requested fields from the attached document.", with: tempfile.path)
      JSON.parse(response.content.to_s)
    end
  rescue StandardError => e
    Rails.logger.warn "[JobProposalProcessor] AI extraction failed (#{e.class}): #{e.message}"
    @ai_error = "#{e.class.name.demodulize}: #{e.message}"
    nil
  end

  def stub_response
    {
      "title" => "Mr.",
      "firstName" => "Sample",
      "lastName" => "Customer",
      "email" => "sample.customer@example.com",
      "jobDescription" => "Stubbed proposal pending real AI extraction.",
      "internalRef" => "STUB-#{SecureRandom.hex(3).upcase}",
      "jobType" => nil,
      "estimateDate" => Date.current.iso8601,
      "expirationDate" => (Date.current + 30).iso8601,
      "subtotal" => 9500.00,
      "taxAmount" => 760.00,
      "discountAmount" => 0.00,
      "depositAmount" => 1000.00,
      "totalAmount" => 10260.00,
      "isEmergency" => false,
      "estimatedDuration" => "3 days",
      "warrantyIncluded" => true,
      "optionsProvided" => true,
      "paymentTerms" => "Net 30",
      "houseNumber" => "123",
      "street" => "Main Street",
      "city" => "Springfield",
      "state" => "IL",
      "zip" => "62701"
    }
  end

  def apply_extracted_fields(data)
    @job_proposal.update(
      customer_title: data["title"],
      customer_first_name: data["firstName"],
      customer_last_name: data["lastName"],
      customer_house_number: data["houseNumber"],
      customer_street: data["street"],
      customer_city: data["city"],
      customer_state: data["state"],
      customer_zip: data["zip"],
      job_description: data["jobDescription"],
      internal_reference: data["internalRef"],
      proposal_value: data["totalAmount"]
    )
  end
end
