class RemoveSubpitchIdFromComments < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :comments, column: :subpitch_id
    remove_column :comments, :subpitch_id, :bigint
  end
end
