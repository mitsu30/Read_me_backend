class UserCommunity < ApplicationRecord
  belongs_to :user
  belongs_to :community

  validates :user_id, uniqueness: { scope: :community_id } # user_idがcommunity_idとの組み合わせで一意
end
