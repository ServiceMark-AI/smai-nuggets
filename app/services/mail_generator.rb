# Renders an outbound campaign email by substituting merge-field placeholders
# in a CampaignStep's subject + body templates with values from a JobProposal
# (and the originator, organization, tenant, and location it resolves to).
#
# Usage:
#   result = MailGenerator.render(campaign_step:, job_proposal:)
#   result.subject  # => "Following up on 123 Oak Ridge"
#   result.body     # => "Hi Sarah, …"
#
# Returns a MailGenerator::Output value object. Raises
# MailGenerator::UnresolvedMergeFieldError if any `{token}`-shaped placeholder
# remains after substitution (typo or unsupported field).
#
# Known placeholders that resolve to missing data substitute the empty string —
# template authors are responsible for keeping surrounding prose grammatical
# when an optional field is absent.
class MailGenerator
  class UnresolvedMergeFieldError < StandardError; end

  Output = Data.define(:subject, :body)

  PLACEHOLDER_RE = /\{([a-z_]+)\}/

  KNOWN_KEYS = %w[
    customer_name customer_first_name customer_last_name
    property_address property_address_short
    proposal_value damage_description
    originator_name originator_first_name originator_last_name
    originator_phone originator_email
    company_name company_phone
    location_name location_address state
  ].freeze

  # Grouping used by the campaign-step edit form's "available merge
  # fields" reference list. Order mirrors a top-down read of an email:
  # who you're writing to, what their job is, what you're proposing,
  # who's signing it, and where it's coming from. Keep aligned with
  # KNOWN_KEYS — every key listed there should appear in exactly one
  # group so authors don't get a partial list.
  MERGE_FIELD_GROUPS = {
    "Customer" => %w[customer_name customer_first_name customer_last_name],
    "Property" => %w[property_address property_address_short],
    "Proposal" => %w[proposal_value damage_description],
    "Originator (proposal owner)" => %w[
      originator_name originator_first_name originator_last_name
      originator_phone originator_email
    ],
    "Company" => %w[company_name company_phone],
    "Location" => %w[location_name location_address state]
  }.freeze

  # Pre-populated fake values used by .preview to render an email
  # exactly as it would look at send time, without needing a real
  # JobProposal. Powers the campaign show page's "what does this look
  # like?" panel. Keep aligned with KNOWN_KEYS — every key listed there
  # should have a sample value here.
  SAMPLE_VALUES = {
    "customer_name"          => "Jane Doe",
    "customer_first_name"    => "Jane",
    "customer_last_name"     => "Doe",
    "property_address"       => "123 Main Street, Springfield, IL 62701",
    "property_address_short" => "123 Main Street",
    "proposal_value"         => "$10,260.00",
    "damage_description"     => "Category-1 clean-water damage from a supply-line failure in the laundry; affected the kitchen ceiling and ~220 ft² of hardwood downstairs.",
    "originator_name"        => "Pat Sample",
    "originator_first_name"  => "Pat",
    "originator_last_name"   => "Sample",
    "originator_phone"       => "(555) 123-4567",
    "originator_email"       => "pat@example.com",
    "company_name"           => "Acme Restoration",
    "company_phone"          => "(555) 555-0100",
    "location_name"          => "Main HQ",
    "location_address"       => "100 Industrial Way, Springfield, IL 62701",
    "state"                  => "Illinois"
  }.freeze

  US_STATES = {
    "AL" => "Alabama",      "AK" => "Alaska",      "AZ" => "Arizona",
    "AR" => "Arkansas",     "CA" => "California",  "CO" => "Colorado",
    "CT" => "Connecticut",  "DE" => "Delaware",    "DC" => "District of Columbia",
    "FL" => "Florida",      "GA" => "Georgia",     "HI" => "Hawaii",
    "ID" => "Idaho",        "IL" => "Illinois",    "IN" => "Indiana",
    "IA" => "Iowa",         "KS" => "Kansas",      "KY" => "Kentucky",
    "LA" => "Louisiana",    "ME" => "Maine",       "MD" => "Maryland",
    "MA" => "Massachusetts","MI" => "Michigan",    "MN" => "Minnesota",
    "MS" => "Mississippi",  "MO" => "Missouri",    "MT" => "Montana",
    "NE" => "Nebraska",     "NV" => "Nevada",      "NH" => "New Hampshire",
    "NJ" => "New Jersey",   "NM" => "New Mexico",  "NY" => "New York",
    "NC" => "North Carolina","ND" => "North Dakota","OH" => "Ohio",
    "OK" => "Oklahoma",     "OR" => "Oregon",      "PA" => "Pennsylvania",
    "RI" => "Rhode Island", "SC" => "South Carolina","SD" => "South Dakota",
    "TN" => "Tennessee",    "TX" => "Texas",       "UT" => "Utah",
    "VT" => "Vermont",      "VA" => "Virginia",    "WA" => "Washington",
    "WV" => "West Virginia","WI" => "Wisconsin",   "WY" => "Wyoming"
  }.freeze

  def self.render(campaign_step:, job_proposal:)
    new(campaign_step, job_proposal).call
  end

  # Same substitution as .render, but tolerant of unresolved placeholders —
  # they're left as `{token}` in the output instead of raising. Use for UI
  # previews where a single typo'd merge field shouldn't crash the whole
  # page; reserve .render for the actual send path where unresolved fields
  # are a real failure.
  def self.render_safely(campaign_step:, job_proposal:)
    instance = new(campaign_step, job_proposal)
    values   = KNOWN_KEYS.to_h { |k| [k, instance.send(:resolve, k)] }
    Output.new(
      subject: substitute(campaign_step.template_subject, values),
      body:    append_signature(substitute(campaign_step.template_body, values), values)
    )
  end

  # Render the step's subject and body with SAMPLE_VALUES substituted in,
  # using THE SAME substitution path as send-time render — the only
  # difference is the values hash (sample data) and the unresolved-field
  # policy (kept in place, not raised). So if the rendered preview looks
  # right, the live send will too.
  def self.preview(campaign_step:)
    Output.new(
      subject: substitute(campaign_step.template_subject, SAMPLE_VALUES),
      body:    append_signature(substitute(campaign_step.template_body, SAMPLE_VALUES), SAMPLE_VALUES)
    )
  end

  # Single substitution engine. Replaces every `{key}` in `text` with
  # `values[key].to_s`. Unknown keys (no entry in `values`) are left in
  # place — the caller decides whether that's an error.
  def self.substitute(text, values)
    text.to_s.gsub(PLACEHOLDER_RE) do |match|
      values.key?($1) ? values[$1].to_s : match
    end
  end

  # Appends a standard sign-off block to every email body so individual
  # campaign templates don't have to repeat (and drift on) the
  # "name / phone / email / org" pattern. Built from already-resolved
  # values so a missing phone or unset originator name simply omits that
  # piece — the signature never produces ragged empty lines.
  #
  # Output is preceded by the RFC 3676 signature delimiter ("\n-- \n")
  # which most mail clients use to fold the signature on reply.
  #
  # Used by .render (via #call), .render_safely, and .preview — touch
  # this one method to change the sign-off everywhere.
  def self.append_signature(body, values)
    pieces = []
    pieces << values["originator_name"]   if values["originator_name"].present?
    pieces << values["company_name"]      if values["company_name"].present?
    contact = [values["originator_phone"], values["originator_email"]].compact_blank.join(" · ")
    pieces << contact                     if contact.present?
    return body.to_s if pieces.empty?

    "#{body.to_s.rstrip}\n\n-- \n#{pieces.join("\n")}"
  end

  def initialize(campaign_step, job_proposal)
    @campaign_step = campaign_step
    @job_proposal = job_proposal
  end

  def call
    values = KNOWN_KEYS.to_h { |k| [k, resolve(k)] }
    subject = self.class.substitute(@campaign_step.template_subject, values)
    body    = self.class.substitute(@campaign_step.template_body,    values)

    unresolved = (subject.scan(PLACEHOLDER_RE) + body.scan(PLACEHOLDER_RE)).flatten.uniq.sort
    if unresolved.any?
      raise UnresolvedMergeFieldError, "Unresolved merge fields: #{unresolved.join(", ")}"
    end

    body = self.class.append_signature(body, values)
    Output.new(subject:, body:)
  end

  private

  def resolve(key)
    case key
    when "customer_name"          then "#{@job_proposal.customer_first_name} #{@job_proposal.customer_last_name}".strip.presence
    when "customer_first_name"    then @job_proposal.customer_first_name
    when "customer_last_name"     then @job_proposal.customer_last_name
    when "property_address"       then property_address
    when "property_address_short" then property_address_short
    when "proposal_value"         then format_currency(@job_proposal.proposal_value)
    when "damage_description"     then @job_proposal.job_description
    when "originator_name"        then originator_name
    when "originator_first_name"  then originator&.first_name
    when "originator_last_name"   then originator&.last_name
    when "originator_phone"       then originator&.phone_number
    when "originator_email"       then originator&.email
    when "company_name"           then organization&.name || tenant&.name
    when "company_phone"          then location&.phone_number
    when "location_name"          then location&.display_name
    when "location_address"       then location_address
    when "state"                  then US_STATES[location&.state]
    end
  end

  def originator
    @job_proposal.owner
  end

  def organization
    @job_proposal.organization
  end

  def tenant
    @job_proposal.tenant
  end

  def location
    organization&.location
  end

  def originator_name
    return nil unless originator
    "#{originator.first_name} #{originator.last_name}".strip.presence
  end

  def property_address
    parts = [
      property_address_short,
      [@job_proposal.customer_city, @job_proposal.customer_state].compact_blank.join(", "),
      @job_proposal.customer_zip
    ].compact_blank
    parts.any? ? parts.join(", ") : nil
  end

  def property_address_short
    "#{@job_proposal.customer_house_number} #{@job_proposal.customer_street}".strip.presence
  end

  def location_address
    return nil unless location
    parts = [
      location.address_line_1,
      location.address_line_2.presence,
      [location.city, location.state].compact_blank.join(", "),
      location.postal_code
    ].compact_blank
    parts.any? ? parts.join(", ") : nil
  end

  def format_currency(value)
    return nil if value.blank?
    "$#{ActiveSupport::NumberHelper.number_to_delimited(format("%.2f", value))}"
  end
end
