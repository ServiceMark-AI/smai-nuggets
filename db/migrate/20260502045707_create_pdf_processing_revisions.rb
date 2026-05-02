class CreatePdfProcessingRevisions < ActiveRecord::Migration[8.1]
  def change
    create_table :pdf_processing_revisions do |t|
      t.text :instructions, null: false
      t.integer :revision_number, null: false
      t.references :model, null: false, foreign_key: true

      t.timestamps
    end

    add_index :pdf_processing_revisions, :revision_number, unique: true
  end
end
