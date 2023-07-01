class Api::V1::AuthenticationsController < ApplicationController
  def create
    if current_user
      render json: { 
        status: 'success', 
        message: "User successfully logged in!",
        is_student: current_user.is_student  # 追加
      } 
    end
  end
end
