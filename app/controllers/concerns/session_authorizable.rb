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
    token = Encryptors::Jwt::Decrypt.run(token: request.headers["Session-Token"])
    return if token.errors.present?

    User.find_by(id: token.result["user_id"])
  end
end
