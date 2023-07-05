class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :template
  has_many :open_ranges, dependent: :destroy
  has_many :answers, dependent: :destroy

  has_one_attached :image

  validates :uuid, presence: true, length: { maximum: 255 }
  validates :privacy, presence: true
  validate :ensure_open_range_present_if_membered_communities_only, if: -> { membered_communities_only? }

  enum privacy: { opened: 0, closed: 1, membered_communities_only: 2}

  private

  def ensure_open_range_present_if_membered_communities_only
    if open_ranges.empty?
      errors.add(:base, "プロフィール帳を公開するコミュニティを選択してください")
    end
  end
end
