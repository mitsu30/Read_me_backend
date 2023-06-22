class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.integer :privacy, null: false, default: 0
      t.references :user, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true

      t.timestamps
    end
  end
end
