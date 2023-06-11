class Api::V1::UsersController < ApplicationController
  def update
    user = current_user
    if user.update(user_params)
      render json: { status: 'SUCCESS', message: 'Updated the user', data: user }
    else
      render json: { status: 'ERROR', message: 'Not updated', data: user.errors }
    end
  end

  def show
    user = User.find(params[:id])
    if user
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar)
  end
end

