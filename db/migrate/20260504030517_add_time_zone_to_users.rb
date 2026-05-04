class AddTimeZoneToUsers < ActiveRecord::Migration[8.0]
  DEFAULT_TIME_ZONE = "Central Time (US & Canada)".freeze

  def change
    add_column :users, :time_zone, :string, default: DEFAULT_TIME_ZONE, null: false
  end
end
