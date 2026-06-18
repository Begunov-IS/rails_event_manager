class AuthController < ApplicationController
  def register
    user = User.new(user_params)
    return render_resource_errors(user) unless user.save

    render json: {
      success: true,
      user: UserBlueprint.render_as_hash(user, view: :basic)
    }, status: :created
  end

  def login
    user = User.find_by(email: params[:email])
    return render_invalid_credentials unless user&.authenticate(params[:password])

    render json: {
      success: true,
      token: Auth::JsonWebToken.encode(user_id: user.id),
      user: UserBlueprint.render_as_hash(user, view: :basic)
    }
  end

  private

  def user_params
    params.fetch(:user, ActionController::Parameters.new)
      .permit(:name, :email, :password, :password_confirmation)
  end

  def render_invalid_credentials
    render_errors(
      errors: [ { key: "base", messages: [ I18n.t("errors.messages.invalid_email_or_password") ] } ],
      status: :unauthorized
    )
  end
end
