class CreateOpenRanges < ActiveRecord::Migration[6.1]
  def change
    create_table :open_ranges do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true

      t.timestamps
    end
  end
end
