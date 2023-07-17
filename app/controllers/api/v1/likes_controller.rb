class Api::V1::LikesController < ApplicationController
  def create
    begin
      user = current_user
      profile = Profile.find_by(uuid: params[:profile_id])
      user.like(profile)
      render json: { status: 'success', message: 'Like created successfully.'}
    rescue => e
      Rails.logger.error "Like creation failed: #{e.message}"
      render json: { status: 'error', message: 'Like creation failed: ' + e.message }, status: :internal_server_error
    end
  end

  def check
    user = current_user
    profile = Profile.find_by(uuid: params[:profile_id])
    liked = user.likes.exists?(profile: profile)

    render json: { isLiked: liked }
  end

  def destroy
    user = current_user
    profile = user.like_profiles.find_by(uuid: params[:id])
    begin
      user.unlike(profile)
      render json: { status: 'success', message: 'Like destroyed successfully.'}
    rescue => e
      Rails.logger.error "Like creation failed: #{e.message}"
      render json: { status: 'error', message: 'Like destroy failed: ' + e.message }
    end
  end
end


