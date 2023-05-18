class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }
  validates :uid, presence: true, uniqueness: true
  validates :role, presence: true
  validates :is_student, presence: true

  enum role: { general: 0, admin: 1 }
end
