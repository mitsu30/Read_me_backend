class AddImageUrlToImageText < ActiveRecord::Migration[6.1]
  def change
    def change
      add_column :image_texts, :image_url, :string
    end
  end
end
