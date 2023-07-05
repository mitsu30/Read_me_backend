class OpenRange < ApplicationRecord
  belongs_to :profile
  belongs_to :community

  validates :profile_id, uniqueness: { scope: :community_id } # profile_idがcommunity_idとの組み合わせで一意
end
