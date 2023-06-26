class Api::V1::OpenRangesController < ApplicationController
  before_action :set_user, :set_profile, :set_community, only: :update

  def update
    @profile.update!(privacy: profile_params[:privacy])
    @profile.open_ranges.create!(community: @community)
  end

  private

  def set_user
    @user = current_user
  end

  def set_profile
    @profile = @user.profiles.find_by(uuid: params[:id])
  end

  def set_community
    @community = @user.membered_communities.find(params[:community_id])
  end

  def profile_params
    params.require(:profile).permit(:privacy)
  end
end
