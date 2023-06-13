class Api::V1::UsersController < ApplicationController
  def update
    user = current_user
    if user_params[:avatar].blank? 
      user.avatar.attach(io: File.open(Rails.root.join('public', 'images', 'default_avatar.png')), filename: 'default-avatar.jpg') 
    else
      user.update(user_params)
    end

    if user.save
      render json: { status: 'SUCCESS', message: 'Updated the user', data: user }
    else
      render json: { status: 'ERROR', message: 'Not updated', data: user.errors }
    end
  end

  def show
    user = User.find(params[:id])
    if user
      user_data = user.attributes
      user_data[:avatar_url] = rails_blob_url(user.avatar) if user.avatar.attached?
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :uid, :role, :is_student, :avatar)
  end
end

