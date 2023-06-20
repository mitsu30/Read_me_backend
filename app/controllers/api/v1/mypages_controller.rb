class Api::V1::MypagesController < ApplicationController
  def show
    user = current_user
    if user
      user_data = user.attributes
      user_data[:avatar_url] = rails_blob_url(user.avatar) if user.avatar.attached?

      # Include the names of communities the user belongs to
      user_data[:communities] = user.membered_communities.map { |c| { id: c.id, name: c.name } }

      # Include the names of groups the user belongs to
      user_data[:groups] = user.membered_groups.map { |g| { id: g.id, name: g.name } }

      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end
end
