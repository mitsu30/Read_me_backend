class Api::V1::UsersController < ApplicationController
  def resister_new_RUNTEQ_student
    user = current_user

    ActiveRecord::Base.transaction do
      user.update!(user_params)
      
      community = Community.find(1)
      user.take_part_in(community)

      group = Group.find(params[:group_id])
      user.join(group)
      
      user.avatar.attach(params[:avatar]) if params[:avatar].present?
    end

    render json: { status: 'SUCCESS', message: 'Updated the user', data: user }
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'ERROR', message: 'Not found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { status: 'ERROR', message: 'Invalid data', data: e.record.errors }, status: :unprocessable_entity
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

