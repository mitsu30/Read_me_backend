require 'octokit'

class ApplicationController < ActionController::API
  include FirebaseAuth
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_token

  def authenticate_token
    token, _options = ActionController::HttpAuthentication::Token.token_and_options(request)
    
    if token
      result = verify_id_token(token)
      Rails.logger.info "Authentication result: #{result}"
      
      if result[:errors]
        render status: :bad_request, json: { errors: result[:errors] }
      else
        user = User.find_by(uid: result[:uid])
        if user.present?
          @_current_user = user
        else
          Rails.logger.info "Creating new user as the user was not found in the database."
          creation_result = User.create_new_user(params, result[:uid])
          if creation_result[:status] == 'success'
            @_current_user = creation_result[:user]
            @is_new_user = true
            render status: :created, json: { status: 'success', message: 'User created successfully.', uid: @_current_user.uid, username: @_current_user.name, is_student: @_current_user.is_student, isNewUser: true }
          else
            render status: :unprocessable_entity, json: { status: 'ERROR', message: creation_result[:message] }
          end
        end
      end
    else
      # トークンが見つからなかった場合のエラーメッセージを返す
      render status: :unauthorized, json: { status: 'ERROR', message: 'No token provided' }
    end
  end
  
  def current_user
    @_current_user
  end
end
