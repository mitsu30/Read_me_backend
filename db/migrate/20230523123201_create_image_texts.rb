class CreateImageTexts < ActiveRecord::Migration[6.1]
  def change
    create_table :image_texts, id: :uuid do |t|
      t.string :answer1
      t.string :answer2
      t.string :answer3
      t.string :image_url, null: false

      t.timestamps
    end
  end
end
