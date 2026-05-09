class AddLocationToApplicationMailboxes < ActiveRecord::Migration[8.1]
  def change
    # `add_reference` would create a non-unique index — we want a partial
    # unique one instead, so disable the auto-index and add ours explicitly.
    add_reference :application_mailboxes, :location, foreign_key: true, null: true, index: false
    # At most one mailbox per location. The legacy "no location" singleton
    # is allowed (location_id IS NULL); we don't add an index that uniques
    # NULLs because Postgres treats them as distinct, which is what we want.
    add_index :application_mailboxes, :location_id, unique: true, where: "location_id IS NOT NULL"
  end
end
