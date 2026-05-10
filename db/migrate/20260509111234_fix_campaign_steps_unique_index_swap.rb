# Fix-up for dev environments where 20260509104240_create_campaign_revisions
# was applied before its index-swap lines were added. On a fresh install
# the previous migration already did this swap, so the guards below make
# the migration a no-op there.
#
# Symptom this addresses: creating a draft revision raises
# ActiveRecord::RecordNotUnique on
# `index_campaign_steps_on_campaign_id_and_sequence_number` because the
# old per-campaign unique index never got dropped.
class FixCampaignStepsUniqueIndexSwap < ActiveRecord::Migration[8.1]
  OLD_INDEX = "index_campaign_steps_on_campaign_id_and_sequence_number".freeze
  NEW_INDEX = "index_campaign_steps_on_revision_and_sequence".freeze

  def up
    if index_name_exists?(:campaign_steps, OLD_INDEX)
      remove_index :campaign_steps, name: OLD_INDEX
    end

    unless index_name_exists?(:campaign_steps, NEW_INDEX)
      add_index :campaign_steps, [:campaign_revision_id, :sequence_number],
                unique: true,
                name:   NEW_INDEX
    end
  end

  def down
    if index_name_exists?(:campaign_steps, NEW_INDEX)
      remove_index :campaign_steps, name: NEW_INDEX
    end

    unless index_name_exists?(:campaign_steps, OLD_INDEX)
      add_index :campaign_steps, [:campaign_id, :sequence_number],
                unique: true,
                name:   OLD_INDEX
    end
  end
end
