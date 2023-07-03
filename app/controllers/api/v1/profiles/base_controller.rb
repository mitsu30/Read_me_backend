class Api::V1::Profiles::BaseController < ApplicationController
  require 'mini_magick'
  require 'base64' 
  
  before_action :set_current_user
  skip_before_action :authenticate_token, :set_current_user,  only: [:show_public]

  # FONT_PATH = ENV['FONT_PATH']
  # TEMP_IMAGE_PATH = ENV['TEMP_IMAGE_PATH']

  def show
    profile = @user.profiles.find_by(uuid: params[:id])
    if profile
      render json: { image_url: profile.image.url, privacy: profile.privacy, template_id: profile.template_id }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end
  
  def show_for_community
    user_communities = @user.membered_communities.map(&:id) 
    profile = Profile.find_by(uuid: params[:id])

    if profile
      if profile.privacy == 'opened' || (profile.privacy == 'membered_communities_only' && (user_communities & profile.open_ranges.map(&:community_id)).any?)
        render json: { image_url: profile.image.url, user_id: profile.user.id,  username: profile.user.name }
      else
        render json: { error: "Profile is not accessible" }, status: :forbidden
      end
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  def show_public
    profile = Profile.find_by(uuid: params[:id])
    if profile
      if profile.privacy != 'opened'
        render json: { error: "Profile is not public" }, status: :forbidden
        return
      end
      render json: { image_url: profile.image.url, user_id: profile.user.id, username: profile.user.name }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  def destroy
    begin
      profile = @user.profiles.find_by(uuid: params[:id])
      profile.destroy!
      render json: { status: 'success', message: 'Profile destroyed successfully.'}
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
  
  private

  def set_current_user
    @user = current_user
  end
end
