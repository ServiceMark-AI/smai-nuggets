class CreateJobProposalAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :job_proposal_attachments do |t|
      t.references :job_proposal, null: false, foreign_key: true
      t.references :uploaded_by_user, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
