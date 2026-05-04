class RenameCampaignStatusNewToDraft < ActiveRecord::Migration[8.1]
  # The Campaign status enum was renamed from `new` to `draft` in the
  # model. Both values map to the same underlying integer (0) in the
  # `campaigns.status` column, so this migration is a logical no-op for
  # any row that already had the integer encoding — the new code reads
  # 0 as "draft" automatically.
  #
  # The defensive UPDATE below covers the unlikely case that a row was
  # written with the literal string "new" (e.g. via a string-cast in
  # raw SQL bypassing the enum). Idempotent: rows already at 0 are
  # left as-is.

  def up
    # Defensive: any column data that ended up as the string "new"
    # (rather than the integer 0 the enum normally writes) gets coerced
    # to integer 0. ActiveRecord won't emit this normally, but the
    # update is safe to run regardless.
    affected = execute(<<~SQL).cmd_tuples
      UPDATE campaigns
      SET status = 0
      WHERE status::text IN ('new', '0')
        AND status IS DISTINCT FROM 0
    SQL
    say "Coerced #{affected} campaign row(s) with string-typed 'new' to integer 0 (now meaning :draft)."
  end

  def down
    # No-op. The integer column never held a non-numeric value through
    # ActiveRecord, so there is nothing to revert. Documented for
    # completeness.
    say "Down migration is intentionally a no-op."
  end
end
