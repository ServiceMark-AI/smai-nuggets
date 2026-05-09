class CreateCampaignRevisions < ActiveRecord::Migration[8.1]
  # Shim used only for the inline backfill below. Defining it here keeps
  # the migration self-contained — future schema changes to the real
  # CampaignRevision model can't reach back and break this migration.
  class CampaignRevisionShim < ActiveRecord::Base
    self.table_name = "campaign_revisions"
  end

  def up
    create_table :campaign_revisions do |t|
      t.references :campaign, null: false, foreign_key: true
      t.integer :revision_number, null: false
      t.integer :status, null: false, default: 0
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }
      t.references :approved_by_user, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.timestamps
    end
    add_index :campaign_revisions, [:campaign_id, :revision_number], unique: true
    # Only one active revision per campaign — partial unique index.
    # status = 1 is :active per the enum on the CampaignRevision model.
    add_index :campaign_revisions,
              :campaign_id,
              unique: true,
              where: "status = 1",
              name: "index_campaign_revisions_one_active_per_campaign"

    add_reference :campaign_steps,     :campaign_revision, foreign_key: true
    add_reference :campaign_instances, :campaign_revision, foreign_key: true

    backfill_revisions!

    change_column_null :campaign_steps,     :campaign_revision_id, false
    change_column_null :campaign_instances, :campaign_revision_id, false

    # Sequence numbers are now unique within a revision, not within a
    # campaign. Two revisions on the same campaign each have their own
    # step 1, etc. — drop the old per-campaign uniqueness constraint and
    # add a per-revision one.
    remove_index :campaign_steps, name: "index_campaign_steps_on_campaign_id_and_sequence_number"
    add_index    :campaign_steps, [:campaign_revision_id, :sequence_number],
                 unique: true,
                 name:   "index_campaign_steps_on_revision_and_sequence"
  end

  def down
    if index_exists?(:campaign_steps, [:campaign_revision_id, :sequence_number],
                     name: "index_campaign_steps_on_revision_and_sequence")
      remove_index :campaign_steps, name: "index_campaign_steps_on_revision_and_sequence"
    end
    unless index_exists?(:campaign_steps, [:campaign_id, :sequence_number],
                         name: "index_campaign_steps_on_campaign_id_and_sequence_number")
      add_index :campaign_steps, [:campaign_id, :sequence_number],
                unique: true,
                name:   "index_campaign_steps_on_campaign_id_and_sequence_number"
    end
    remove_reference :campaign_instances, :campaign_revision, foreign_key: true
    remove_reference :campaign_steps,     :campaign_revision, foreign_key: true
    drop_table :campaign_revisions
  end

  private

  # For each existing campaign, create revision_number 0 with status=:active
  # and link every step + every running instance to it. created_by_user_id
  # falls back to the campaign's approved_by, paused_by, or the first admin
  # user so the NOT NULL constraint applied at the end of this migration
  # is satisfied. Approval audit fields are copied from the campaign so
  # the revision retains the original approval timestamp where one exists.
  def backfill_revisions!
    fallback_user_id = User.where(is_admin: true).order(:id).pick(:id) || User.order(:id).pick(:id)

    Campaign.find_each do |campaign|
      created_by_id = campaign.approved_by_user_id ||
                      campaign.paused_by_user_id ||
                      fallback_user_id
      if created_by_id.nil?
        raise "no users exist in this database — cannot backfill campaign_revisions.created_by_user_id"
      end

      revision = CampaignRevisionShim.create!(
        campaign_id:         campaign.id,
        revision_number:     0,
        status:              1, # :active
        created_by_user_id:  created_by_id,
        approved_by_user_id: campaign.approved_by_user_id,
        approved_at:         campaign.approved_at
      )

      execute "UPDATE campaign_steps     SET campaign_revision_id = #{revision.id.to_i} WHERE campaign_id = #{campaign.id.to_i} AND campaign_revision_id IS NULL"
      execute "UPDATE campaign_instances SET campaign_revision_id = #{revision.id.to_i} WHERE campaign_id = #{campaign.id.to_i} AND campaign_revision_id IS NULL"
    end
  end
end
