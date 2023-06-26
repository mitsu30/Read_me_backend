class Api::V1::MypagesController < ApplicationController  
  def show
    user = current_user
    if user
      user_data = user.attributes
      user_data[:avatar_url] = rails_blob_url(user.avatar) if user.avatar.attached?
      
      # Include the names of communities the user belongs to
      user_communities = user.membered_communities.map { |c| { id: c.id, name: c.name } }
      user_data[:communities] = user_communities
      
      # Include the names of groups the user belongs to
      user_groups = user.membered_groups.map { |g| { id: g.id, name: g.name } }
      user_data[:groups] = user_groups
      
      user_profiles = user.profiles.with_attached_image.map { |p| { id: p.id, uuid: p.uuid, image_url: p.image.url, privacy: p.privacy } }
      user_data[:profiles] = user_profiles
      
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end

  def edit
    user = current_user
    if user
      user_data = user.attributes
      user_data[:avatar_url] = rails_blob_url(user.avatar) if user.avatar.attached?
      user_data[:groups] = user.membered_groups.find_by(community_id: 1)
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end

  def update
    user = current_user
    ActiveRecord::Base.transaction do
      user.update!(user_params)
      
      # community = Community.find(1)
      # user.take_part_in(community) unless user.membered_communities.include?(community)

      group = Group.find(params[:group_id])
      user.join(group)

      # user.avatar.attach(params[:avatar]) if params[:avatar].present?
    end

    render json: { status: 'SUCCESS', message: 'Updated the user', data: user }
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'ERROR', message: 'Not found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error e.record.errors.full_messages.join(", ")
    render json: { status: 'ERROR', message: 'Invalid data', data: e.record.errors }, status: :unprocessable_entity
  end

  private
  
  def user_params
    params.require(:user).permit(:name, :uid, :role, :is_student, :avatar, :greeting)
  end
end
