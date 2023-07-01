class Api::V1::TwitterShareController < ApplicationController
  def show
    profile = Profile.find_by(uuid: params[:id])
    if profile
      render json: { image_url: profile.image.url }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end
end
