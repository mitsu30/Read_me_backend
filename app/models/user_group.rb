class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group
  has_one :community, through: :group

  validates :user_id, uniqueness: { scope: :group_id } # user_idがcommunity_idとの組み合わせで一意
end
