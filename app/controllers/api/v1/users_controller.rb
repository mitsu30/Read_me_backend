module Api
  module V1
    class UsersController < ApplicationController
      def index
        users = User.all

        render json: {
          users: users
        }, status: :ok
      end

      def show
      end

      def new
      end

      def edit
      end

    end
  end
end
