class Api::V1::UsersController < ApplicationController
  skip_before_action :authenticate_token, only: [:show_public]

  def index
    @user = current_user
    users = User.left_outer_joins(:user_groups, :membered_groups, :user_communities)
                .where(user_communities: { community_id: 1 })
                .includes(:user_groups, :user_communities, :membered_groups)

    if params[:group_id].present? && params[:group_id] != "RUNTEQ" 
      users = users.where(user_groups: { group_id: params[:group_id] })
    end

    if params[:name].present?
      users = users.where('users.name LIKE ?', "%#{params[:name]}%")
    end
  
    users = users.order(order_params)
                 .page(params[:page] || 1)
                 .per(10)

    pagination_info = {
      current_page: users.current_page,
      total_pages: users.total_pages,
      per_page: users.limit_value,
    }

    render json: { users: users.map { |user| user_to_json(user) }, pagination: pagination_info }
  end

  def show
    @user = current_user
    @showed_user = User.find(params[:id])
    if @showed_user
      render_user_data(method(:build_profiles_data))
    else
      render_user_not_found
    end
  end

  def show_public
    @showed_user = User.find(params[:id])
    if @showed_user
      render_user_data(method(:build_profiles_data_public))
    else
      render_user_not_found
    end
  end

  private
  
  def order_params
    case params[:sort_by]
    when "name_asc"
      "users.name asc"
    when "created_at_desc"
      "users.created_at desc"
    else
      "users.created_at desc"  
    end
  end
  
  def user_to_json(user)
    {
      id: user.id,
      name: user.name,
      greeting: user.greeting,
      avatar: (@user.is_student && user.avatar.attached?) ? url_for(user.avatar) : nil,
      group: user.membered_groups.first ? user.membered_groups.first.name : nil
    }
  end
  
  
  def build_user_data
    showed_user_data = @showed_user.attributes
    showed_user_data[:avatar_url] = (@user.is_student && @showed_user.avatar.attached?) ? rails_blob_url(@showed_user.avatar) : nil
    showed_user_data[:communities] = @showed_user.membered_communities.map { |c| { id: c.id, name: c.name } }
    showed_user_data[:groups] = @showed_user.membered_groups.map { |g| { id: g.id, name: g.name } }
    showed_user_data
  end

  def build_profiles_data
    user_communities = @user.membered_communities.map(&:id) 
    @showed_user.profiles.with_attached_image.select do |profile|
      profile.privacy == 'opened' || (profile.privacy == 'membered_communities_only' && (user_communities & profile.open_ranges.map(&:community_id)).any?)
    end.map do |p| 
      {
        id: p.id,
        uuid: p.uuid,
        image_url: p.image.url,
      }
    end
  end

  def build_profiles_data_public
    @showed_user.profiles.with_attached_image.select do |profile|
      profile.privacy == 'opened' 
    end.map do |p| 
      {
        id: p.id,
        uuid: p.uuid,
        image_url: p.image.url,
      }
    end
  end
  
  def render_user_data(profile_builder)
    showed_user_data = build_user_data
    showed_user_data[:profiles] = profile_builder.call
    render json: { status: 'SUCCESS', message: 'Loaded the user', data: showed_user_data }
  end

  def render_user_not_found
    render json: { status: 'ERROR', message: 'User not found' }
  end
end
