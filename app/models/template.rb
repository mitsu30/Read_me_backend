class Template < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :profiles, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :image_path, presence: true, length: { maximum: 255 }
  validates :next_path, presence: true, length: { maximum: 255 }
  validates :only_student, inclusion: { in: [true, false] }
end
