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
        # ユーザーのemailが組織のメンバーのものであるか確認
        if member_email_of_organization?(result[:email], 'runteq')
          @_current_user = User.find_or_create_by!(uid: result[:uid])
        else
          render_400(nil, 'User email is not found in the specified organization.')
        end
      end
    end
  end

  # 特定の組織のメンバー情報を取得する
  def organization_members(organization_name)
    client = Octokit::Client.new(access_token: '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')
    client.auto_paginate = true
    client.organization_members(organization_name).map(&:login)
  end

  # 指定したユーザーのemailが組織のメンバーのものであるか確認する
  def member_email_of_organization?(email, organization_name)
    members = organization_members(organization_name)
    client = Octokit::Client.new(access_token: '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')
    byebug
    members.any? do |member|
      user = client.user(member)
      user.email == email
    end
  end

  def current_user
    @_current_user
  end
end
