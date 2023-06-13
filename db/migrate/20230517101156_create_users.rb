class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string    :name,              null: false
      t.string    :uid,               null: false      
      t.integer   :role,              null: false, default: 0 
      t.boolean   :is_student,        null: false, default: false

      t.timestamps
    end
  end
end
