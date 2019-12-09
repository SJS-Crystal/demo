class ChangeColumn < ActiveRecord::Migration[6.0]
  def change
    change_column :comments, :id_parent, :bigint
    rename_column :comments, :id_parent, :rating_id
    add_foreign_key :comments, :ratings
  end
end
