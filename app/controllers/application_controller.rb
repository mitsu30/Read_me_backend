require 'octokit'

class ApplicationController < ActionController::API
  include FirebaseAuth
  # include Api::ExceptionHandler
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_token

  def authenticate_token
    authenticate_with_http_token do |token, _options|
      result = verify_id_token(token)
      byebug
      if result[:errors]
        render_400(nil, result[:errors])
      else
        user = User.find_by(uid: result[:uid])
        byebug
        if user.present? 
          @_current_user = user
        elsif params[:isNewUser] && runteq_member?(params[:username])
          @_current_user = User.create(uid: result[:uid])
        else
          render_400(nil, 'User is not a member of the specified organization or user not found.')
        end
      end
    end
  end
  
  def current_user
    @_current_user
  end

  private

  def runteq_member?(gitHub_user_id)
    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    client.organization_member?('runteq', gitHub_user_id)
    byebug
  end

end
