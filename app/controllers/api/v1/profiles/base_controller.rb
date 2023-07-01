class Api::V1::Profiles::BaseController < ApplicationController
  require 'mini_magick'
  require 'base64' 
  
  before_action :set_current_user
  skip_before_action :authenticate_token, :set_current_user,  only: [:show_public]

  FONT_PATH = ENV['FONT_PATH']
  TEMP_IMAGE_PATH = ENV['TEMP_IMAGE_PATH']

  def show
    profile = @user.profiles.find_by(uuid: params[:id])
    if profile
      render json: { image_url: profile.image.url, privacy: profile.privacy }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  def show_public
    profile = Profile.find_by(uuid: params[:id])
    if profile
      render json: { image_url: profile.image.url, privacy: profile.privacy }
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
