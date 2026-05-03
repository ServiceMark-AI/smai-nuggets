# Convert single-brace placeholders ({customer_first_name}) in existing
# CampaignStep templates to double-brace ({{customer_first_name}}). The
# MailGenerator regex was tightened to require {{...}}, matching the
# convention already used in db/seeds.rb and now the catalog markdown
# under docs/campaigns/v1-output/. Without this migration, campaigns
# loaded before the change would silently fail to substitute fields at
# send time.
#
# Conservative: skips rows that already contain `{{` anywhere in the
# field, on the assumption they were authored against the new
# convention. Idempotent — re-running this migration is a no-op.
class RewriteCampaignStepPlaceholdersToDoubleBrace < ActiveRecord::Migration[8.1]
  SINGLE_BRACE = /\{([a-z_]+)\}/

  def up
    CampaignStep.find_each do |step|
      changes = {}
      changes[:template_subject] = rewrite(step.template_subject) if needs_rewrite?(step.template_subject)
      changes[:template_body]    = rewrite(step.template_body)    if needs_rewrite?(step.template_body)
      step.update_columns(changes) if changes.any?
    end
  end

  def down
    # No-op. We don't want to undo the convention.
  end

  private

  def needs_rewrite?(text)
    return false if text.blank?
    return false if text.include?("{{") # assume already on the new convention
    text.match?(SINGLE_BRACE)
  end

  def rewrite(text)
    text.gsub(SINGLE_BRACE) { "{{#{Regexp.last_match(1)}}}" }
  end
end
