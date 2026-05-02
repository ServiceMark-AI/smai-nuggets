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

  def initialize(campaign_step, job_proposal)
    @campaign_step = campaign_step
    @job_proposal = job_proposal
  end

  def call
    subject = substitute(@campaign_step.template_subject.to_s)
    body = substitute(@campaign_step.template_body.to_s)

    unresolved = (subject.scan(PLACEHOLDER_RE) + body.scan(PLACEHOLDER_RE)).flatten.uniq.sort
    if unresolved.any?
      raise UnresolvedMergeFieldError, "Unresolved merge fields: #{unresolved.join(", ")}"
    end

    Output.new(subject:, body:)
  end

  private

  def substitute(text)
    text.gsub(PLACEHOLDER_RE) do |match|
      KNOWN_KEYS.include?($1) ? resolve($1).to_s : match
    end
  end

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
