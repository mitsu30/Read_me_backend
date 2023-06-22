class Profile < ApplicationRecord
  belongs_to :user
  has_many :open_ranges, dependent: :destroy
end
