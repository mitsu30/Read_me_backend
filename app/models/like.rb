class Like < ApplicationRecord
  belongs_to :user
  belongs_to :profile

  validates :user_id, uniqueness: { scope: :profile_id } # user_idがprofile_idとの組み合わせで一意
end
