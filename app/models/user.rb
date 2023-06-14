class User < ApplicationRecord
  has_many :communities, foreign_key: :owner_id, dependent: :destroy # ユーザーが作成したコミュニティ
  has_many :user_communities, dependent: :destroy
  has_many :membered_communities, through: :user_communities, source: :community  # ユーザーが所属しているコミュニティ
  
  has_many :user_groups, dependent: :destroy
  has_many :membered_groups, through: :user_groups, source: :group  # ユーザーが所属しているグループ
  
  validates :name, presence: true, length: { maximum: 255 }
  validates :uid, presence: true, uniqueness: true
  validates :role, presence: true
  validates :is_student, presence: true

  enum role: { general: 0, admin: 1 }

  has_one_attached :avatar

  def take_part_in(community)
    membered_communities << community
  end

  def join(group)
    membered_groups << group
  end
  
end
