class Api::V1::CommunitiesController < ApplicationController
  def show
    user = current_user
    user_communities = current_user.membered_communities.map { |c| { id: c.id, name: c.name } }
    if user_communities
      render json: { user_communities: user_communities }
    else
      render json: { error: "Image not found" }, status: :not_found
    end
  end
end
