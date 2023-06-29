class Api::V1::Profiles::BaseController < ApplicationController
  require 'mini_magick'
  require 'base64' 

  FONT_PATH = ENV['FONT_PATH']
  TEMP_IMAGE_PATH = ENV['TEMP_IMAGE_PATH']

  def show
    user = current_user
    profile = user.profiles.find_by(uuid: params[:id])
    if profile
      render json: { image_url: profile.image.url, privacy: profile.privacy }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end

  def destroy
    begin
      user = current_user
      profile = user.profiles.find_by(uuid: params[:id])
      profile.destroy!
      render json: { status: 'success', message: 'Profile destroyed successfully.'}
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
  
end
