class UsersController < ApplicationController
  def index
    users = User.all

    render json: {
      users: users
    }, status: :OK
  end

  def show
  end

  def new
  end

  def edit
  end
end
