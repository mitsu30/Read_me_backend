class Api::V1::OpenRangesController < ApplicationController
  before_action :set_user, :set_profile, only: %i[show update]
  before_action :set_communities, only: :update, if: :membered_communities_only?

  def update
    begin
      ActiveRecord::Base.transaction do
        create_open_ranges_for_communities if membered_communities_only?
        @profile.update!(privacy: profile_params[:privacy])
      end
      render json: { status: 'SUCCESS', message: 'Loaded the user'}
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end

  def show
    open_ranges = @profile.open_ranges.map { |o| {community_id: o.community_id, }}
    render json: { open_ranges: open_ranges}
  end

  private

  def set_user
    @user = current_user
  end

  def set_profile
    @profile = @user.profiles.find_by(uuid: params[:id])
  end

  def set_communities
    @communities = @user.membered_communities.where(id: params[:community_id]) if params[:community_id].present?
  end

  def profile_params
    params.require(:profile).permit(:privacy)
  end

  def membered_communities_only?
    params.dig(:profile, :privacy) == 'membered_communities_only'
  end

  def create_open_ranges_for_communities
    @communities.each do |community|
      unless @profile.open_ranges.exists?(community: community)
        @profile.open_ranges.create!(community: community)
      end
    end
  end
end
