class Api::V1::MypagesController < ApplicationController
  before_action :set_current_user, only: [:show, :edit, :update, :avatar]

  def show
    if @user
      user_data = build_user_data
      user_data[:profiles] = build_profiles_data
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end
  
  def avatar
    if @user
      user_data = {}
      user_data[:avatar_url] = rails_blob_url(@user.avatar) if @user.avatar.attached?
      user_data[:is_student] = @user.is_student
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end

  def edit
    if @user
      user_data = build_user_data
      user_data[:groups] = @user.membered_groups.find_by(community_id: 1) if @user.is_student
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end

  def update
    @user
    ActiveRecord::Base.transaction do
      @user.update!(user_params)
      group = Group.find(params[:group_id]) if @user.is_student
      @user.join(group) if @user.is_student
    end

      render json: { status: 'SUCCESS', message: 'Updated the user', data: @user.avatar.url }
    rescue ActiveRecord::RecordNotFound
      render json: { status: 'ERROR', message: 'Not found' }, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error e.record.errors.full_messages.join(", ")
      render json: { status: 'ERROR', message: 'Invalid data', data: e.record.errors }, status: :unprocessable_entity
  end

  private

  def set_current_user
    @user = current_user
  end

  def build_user_data
    user_data = @user.attributes
    user_data[:avatar_url] = rails_blob_url(@user.avatar) if @user.avatar.attached?
    user_data[:communities] = @user.membered_communities.map { |c| { id: c.id, name: c.name } }
    user_data[:groups] = @user.membered_groups.map { |g| { id: g.id, name: g.name } }
    user_data
  end

  def build_profiles_data
    @user.profiles.with_attached_image.map do |p| 
      {
        id: p.id,
        uuid: p.uuid,
        image_url: p.image.url,
        privacy: p.privacy,
        open_range_communities: p.open_ranges.map { |open_range| open_range.community.name } 
      }
    end
  end
  
  def user_params
    params.require(:user).permit(:name, :uid, :role, :is_student, :avatar, :greeting)
  end
end
