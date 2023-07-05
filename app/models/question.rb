class Question < ApplicationRecord
  belongs_to :template
  has_many :answers, dependent: :destroy

  validates :item,  presence: true, length: { maximum: 255 }
end
