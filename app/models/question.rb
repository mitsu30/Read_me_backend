class Question < ApplicationRecord
  belongs_to :template

  validates :item,  numericality: { only_integer: true }
end
