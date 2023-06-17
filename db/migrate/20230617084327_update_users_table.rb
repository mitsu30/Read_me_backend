class UpdateUsersTable < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :avatar, :string
    add_column :users, :greeting, :string
  end
end
