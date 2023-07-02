class Api::V1::AuthenticationsController < ApplicationController
  def create
    unless @is_new_user
    render json: {  status: 'success', message: "User successfully logged in!", is_student: current_user.is_student} if current_user
  end
end


