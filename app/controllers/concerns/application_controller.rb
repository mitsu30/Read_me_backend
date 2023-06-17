require 'octokit'

class ApplicationController < ActionController::API
  include FirebaseAuth
  # include Api::ExceptionHandler
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_token

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      result = verify_id_token(token)
      Rails.logger.info "Authentication result: #{result}"
      if result[:errors]
        render_400(nil, result[:errors])
      else
        user = User.find_by(uid: result[:uid])
        if user.present? 
          @_current_user = user
        elsif params[:isNewUser]
          Rails.logger.info "isNewUser parameter: #{params[:isNewUser]}"
          creation_result = User.create_new_user(params, result[:uid])
          if creation_result[:status] == 'success'
            @_current_user = creation_result[:user]
            render json: { status: 'success', message: 'User created successfully.', id: @_current_user.id, username: @_current_user.name }
          else
            render json: { status: 'ERROR', message: creation_result[:message] }
          end
        else
          render json: { status: 'ERROR', message: 'isNewUser is false or undefined'}
        end
      end
    end
  end
  
  def current_user
    @_current_user
  end
end
