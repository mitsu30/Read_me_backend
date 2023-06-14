class Api::V1::GroupsController < ApplicationController
  def for_community
    community_id = params[:community_id]
    groups = Group.where(community_id: community_id)

    render json: { groups: groups }
  end
end
