module SessionAuthorizable
  extend ActiveSupport::Concern

  private

  def authenticate_user!
    return if current_user

    render_errors(errors: [ { key: "base", messages: [ I18n.t("errors.messages.unauthorized") ] } ], status: :unauthorized)
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = find_user_by_token
  end

  def find_user_by_token
    payload = Auth::JsonWebToken.decode(bearer_token)
    return if payload.blank?

    User.find_by(id: payload["user_id"])
  end

  def bearer_token
    authorization_header = request.headers["Authorization"].to_s
    match = authorization_header.match(/\ABearer (.+)\z/)

    match&.[](1)
  end
end
