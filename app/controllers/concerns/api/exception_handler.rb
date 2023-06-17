module Api::ExceptionHandler
  # Rubyのモジュールの機能を拡張するためのモジュール。
  extend ActiveSupport::Concern
  
  #included メソッド内に rescue_from メソッドを配置することで、Api::ExceptionHandler モジュールを include したクラス（この場合、Railsのコントローラー）で特定の例外が発生したときにそれを捕捉し、特定のメソッド（この場合、エラーに対応するHTTPステータスコードとメッセージをレンダリングする render_400, render_404, render_500）を呼び出す設定を共有することができます。
  included do
    rescue_from StandardError, with: :render_500
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActiveRecord::RecordInvalid do |exception|
      render_400(nil, exception.record.errors.full_messages)
    end
  end

  private

  def render_400(exception = nil, messages = nil)
    render_error(400, "Bad Request", exception&.messages, *messages)
  end

  def render_404(exception = nil, messages = nil)
    render_error(404, "Record Not Found", exception&.message, *messages)
  end

  def render_500(exception = nil, messages = nil)
    render_error(500, "Internal Server Error", exception&.message, *messages)
  end

  def render_error(code, message, *error_messages)
    response = { message: message, errors: error_messages.compact }

    render json: response, status: code
  end
end
