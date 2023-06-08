require 'octokit'

class ApplicationController < ActionController::API
  include FirebaseAuth
  # include Api::ExceptionHandler
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_action :authenticate_token

  # HTTPトークンによる認証を行う
  # リクエストヘッダーからトークンを取り出し、FirebaseAuthモジュールのメソッドを使ってトークンを検証する。
  def authenticate_token
    authenticate_with_http_token do |token, _options|
      result = verify_id_token(token)
      if result[:errors]
        render_400(nil, result[:errors])
      else
        @_current_user = User.find_or_create_by!(uid: result[:uid])
      else
        render_400(nil, 'User email is not found in the specified organization.')
      end
    end
  end

  def current_user
    @_current_user
  end
end


# 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
