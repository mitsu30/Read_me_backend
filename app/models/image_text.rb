class ImageText < ApplicationRecord
  has_one_attached :image

  validates :nickname, length: { maximum: 26 }
  validates :hobby, length: { maximum: 13 }
  validate :validate_message

  private

  def validate_message
    return if message.blank?

    lines = message.split("\n")
    if lines.length > 3
      errors.add(:message, '3行以内で入力してください。')
    elsif lines.any? { |line| line.length > 26 }
      errors.add(:message, '各行26文字以内で入力してください。')
    end
  end
end
