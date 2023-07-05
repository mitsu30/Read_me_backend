class Api::V1::TwitterShareController < ApplicationController
  skip_before_action :authenticate_token
  
  
  def show
    profile = Profile.find_by(uuid: params[:id])
    if profile
      render json: { image_url: profile.image.url, privacy: profile.privacy }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end
end
