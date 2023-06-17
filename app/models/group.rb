class Group < ApplicationRecord
  belongs_to :community
  has_many :user_groups, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
end
