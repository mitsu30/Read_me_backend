class Answer < ApplicationRecord
  belongs_to :profile
  belongs_to :question
  
  validates :body, presence: true, length: { maximum: 255 }

  validates :profile_id, uniqueness: { scope: :question_id } # profile_idがquestion_idとの組み合わせで一意
end
