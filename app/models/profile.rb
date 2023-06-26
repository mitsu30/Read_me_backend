class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :template
  has_many :open_ranges, dependent: :destroy
  has_many :answers, dependent: :destroy

  has_one_attached :image

  validates :uuid, presence: true, length: { maximum: 255 }
  validates :privacy, presence: true

  enum privacy: { opened: 0, closed: 1, membered_communities_only: 2}
end
