class AddDashJobNumberSupport < ActiveRecord::Migration[8.1]
  def change
    add_column :tenants, :job_reference_required, :boolean, null: false, default: false
    add_column :job_proposals, :dash_job_number, :string
    add_index :job_proposals, :dash_job_number
  end
end
