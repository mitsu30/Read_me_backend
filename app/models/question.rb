class Question < ApplicationRecord
  belongs_to :template
  has_many :answers, dependent: :destroy

  validates :item,  numericality: { only_integer: true }
end
