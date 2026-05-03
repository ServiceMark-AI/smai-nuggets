class AddCustomerEmailToJobProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :job_proposals, :customer_email, :string
  end
end
