class Api::V1::AuthenticationsController < ApplicationController
  def create
    render json: {  status: 'success', message: "User successfully logged in!" } if current_user
  end
end

