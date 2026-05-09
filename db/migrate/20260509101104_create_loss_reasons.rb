class CreateLossReasons < ActiveRecord::Migration[8.1]
  def up
    create_table :loss_reasons do |t|
      t.string :code, null: false
      t.string :display_name, null: false
      t.integer :sort_order, null: false, default: 0
      t.timestamps
    end
    add_index :loss_reasons, :code, unique: true

    execute <<~SQL
      INSERT INTO loss_reasons (code, display_name, sort_order, created_at, updated_at) VALUES
        ('price_too_high',             'Price too high',                10, NOW(), NOW()),
        ('went_with_competitor',       'Went with competitor',          20, NOW(), NOW()),
        ('insurance_issue',            'Insurance issue',               30, NOW(), NOW()),
        ('no_response_from_customer',  'No response from customer',     40, NOW(), NOW()),
        ('timing_scheduling_conflict', 'Timing / scheduling conflict',  50, NOW(), NOW()),
        ('other',                      'Other',                         99, NOW(), NOW());
    SQL

    add_reference :job_proposals, :loss_reason, foreign_key: true

    # Best-effort backfill from the free-text column. Known seed strings
    # map to their natural code; anything else non-blank lands on "other"
    # so no historical context is lost outright.
    execute <<~SQL
      UPDATE job_proposals AS jp
      SET loss_reason_id = lr.id
      FROM loss_reasons AS lr
      WHERE lr.code = CASE jp.loss_reason
                        WHEN 'Price'       THEN 'price_too_high'
                        WHEN 'No response' THEN 'no_response_from_customer'
                        WHEN 'Timing'      THEN 'timing_scheduling_conflict'
                        ELSE                    'other'
                      END
        AND jp.loss_reason IS NOT NULL
        AND jp.loss_reason <> '';
    SQL

    remove_column :job_proposals, :loss_reason
  end

  def down
    add_column :job_proposals, :loss_reason, :string
    remove_reference :job_proposals, :loss_reason, foreign_key: true
    drop_table :loss_reasons
  end
end
