class ChangeColumnNamesInImageTexts < ActiveRecord::Migration[6.1]
  def change
    rename_column :image_texts, :answer1, :nickname
    rename_column :image_texts, :answer2, :hobby
    rename_column :image_texts, :answer3, :message
  end
end
