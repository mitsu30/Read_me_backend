class Template < ApplicationRecord
  has_many :questions, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :image_path, presence: true, length: { maximum: 255 }
end
