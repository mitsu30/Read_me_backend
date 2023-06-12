class ChangeIdToUuidOnUsers < ActiveRecord::Migration[6.1]
  def up
    add_column :users, :uuid, :uuid, default: "gen_random_uuid()", null: false

    execute <<-SQL
      UPDATE users SET uuid = gen_random_uuid();
    SQL

    remove_column :users, :id

    rename_column :users, :uuid, :id
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end

  def down
    add_column :users, :integer_id, :bigint, null: false, auto_increment: true

    execute <<-SQL
      UPDATE users SET integer_id = id::bigint;
    SQL

    remove_column :users, :id

    rename_column :users, :integer_id, :id
    execute "ALTER TABLE users ADD PRIMARY KEY (id);"
  end
end
