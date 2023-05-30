class ImageText < ApplicationRecord
  has_one_attached :image

  validates :answer1, length: { maximum: 32 }
  validates :answer2, length: { maximum: 16 }
  validate :validate_answer3

  private

  def validate_answer3
    return if answer3.blank?

    lines = answer3.split("\n")
    if lines.length > 3
      errors.add(:answer3, '3行以内で入力してください。')
    elsif lines.any? { |line| line.length > 32 }
      errors.add(:answer3, '各行32文字以内で入力してください。')
    end
  end
end
