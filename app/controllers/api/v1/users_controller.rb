class Api::V1::UsersController < ApplicationController
  def resister_new_RUNTEQ_student
    user = current_user

    ActiveRecord::Base.transaction do
      user.update!(user_params)
      
      community = Community.find(1)
      user.take_part_in(community)

      group = Group.find(params[:group_id])
      user.join(group)

      user.avatar.attach(params[:avatar]) if params[:avatar].present?
    end

    render json: { status: 'SUCCESS', message: 'Updated the user', data: user }
  rescue ActiveRecord::RecordNotFound
    render json: { status: 'ERROR', message: 'Not found' }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e
    render json: { status: 'ERROR', message: 'Invalid data', data: e.record.errors }, status: :unprocessable_entity
  end

  def index
    users = User.includes(:user_groups, :membered_groups, :user_communities)
                .where(user_communities: { community_id: 1 })

    if params[:group_id].present? && params[:group_id] != "RUNTEQ" 
      users = users.where(user_groups: { group_id: params[:group_id] })
    end
  
    users = users.order(order_params)
                 .page(params[:page])
                 .per(10)
  
    render json: users.map { |user| user_to_json(user) }
  end

  def show
    user = User.find(params[:id])
    if user
      user_data = user.attributes
      user_data[:avatar_url] = rails_blob_url(user.avatar) if user.avatar.attached?
      render json: { status: 'SUCCESS', message: 'Loaded the user', data: user_data }
    else
      render json: { status: 'ERROR', message: 'User not found' }
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :uid, :role, :is_student, :avatar)
  end

  def order_params
    if params[:sort_by] == "name"
      "name #{sort_order}"
    else
      "users.created_at #{sort_order}"  
    end
  end

  def sort_order
    params[:order] == "desc" ? "desc" : "asc"
  end

  def user_to_json(user)
    {
      id: user.id,
      name: user.name,
      avatar: user.avatar.attached? ? url_for(user.avatar) : nil,
      group: user.membered_groups.find_by(community_id: 1).name
    }
  end
end

