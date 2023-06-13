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
          is_member = runteq_member?(params[:username])
          Rails.logger.info "#{params[:username]} is a member of runteq: #{is_member}"
          if is_member
            begin
              @_current_user = User.create!(uid: result[:uid], name: params[:username], is_student: true)
              render json: { status: 'success', message: 'User created successfully.', id: @_current_user.id, username: @_current_user.name }
            rescue => e
              Rails.logger.error "User creation failed: #{e.message}"
              render json: { status: 'ERROR', message: 'User creation failed: ' + e.message}
            end
          else
            render json: { status: 'ERROR', message: 'Not a runteq member'}
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

  private

  def runteq_member?(github_user_id)
    client = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])
    is_member = client.organization_member?('runteq', github_user_id)
    Rails.logger.info "Checked if #{github_user_id} is a member of runteq: #{is_member}"
    is_member
  end

end
