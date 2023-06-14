class UserGroup < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :user_id, uniqueness: { scope: :group_id } # user_idがcommunity_idとの組み合わせで一意
end
