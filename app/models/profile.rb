class Profile < ApplicationRecord
  belongs_to :user
  has_many :open_ranges, dependent: :destroy

  validates :image_url, presence: true, length: { maximum: 255 }
end
