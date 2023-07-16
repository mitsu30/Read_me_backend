class Api::V1::LikesController < ApplicationController
  def create
    user = current_user
    profile = Profile.find_by(uuid: params[:id])

    begin
      user.like(profile)
      return { status: 'success', message: 'Like created successfully.'}
    rescue => e
      Rails.logger.error "Like creation failed: #{e.message}"
      return { status: 'error', message: 'Like creation failed: ' + e.message }, status: :internal_server_error
  end

  def destroy
    user = current_user
    profile = user.likes.find_by(uuid: params[:id]).profile
    begin
      user.unlike(profile)
      return { status: 'success', message: 'Like destroyed successfully.'}
    rescue => e
      Rails.logger.error "Like creation failed: #{e.message}"
      return { status: 'error', message: 'Like destroy failed: ' + e.message }
  end
end


