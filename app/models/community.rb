class Community < ApplicationRecord
  belongs_to :user
  has_many :user_communities, dependent: :destroy
  has_many :groups, dependent: :destroy
  has_many :open_ranges, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, presence: true, length: { maximum: 255 }
  validates :password, presence: true, length: { minimum: 3, maximum: 255 }
end
