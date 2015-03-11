class RemoveLowerColumn < ActiveRecord::Migration
  def change
    remove_column :users, :username_lower
    remove_column :users, :email_lower
    remove_index :users, :username
    remove_index :users, :email

    remove_column :categories, :slug_lower
    remove_index :categories, :slug
  end
end
