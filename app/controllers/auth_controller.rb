class AuthController < ApplicationController
  def register
    user = User.new(user_params)
    return render_resource_errors(user) unless user.save

    render json: {
      success: true,
      user: user_response(user)
    }, status: :created
  end

  def login
    user = User.find_by(email: params[:email])
    return render_invalid_credentials unless user&.authenticate(params[:password])

    render json: {
      success: true,
      token: Auth::JsonWebToken.encode(user_id: user.id),
      user: user_response(user)
    }
  end

  private

  def user_params
    params.fetch(:user, ActionController::Parameters.new)
      .permit(:name, :email, :password, :password_confirmation)
  end

  def user_response(user)
    UserBlueprint.render_as_hash(user, view: :basic)
  end

  def render_invalid_credentials
    render_errors(
      errors: [ { key: "base", messages: [ "invalid email or password" ] } ],
      status: :unauthorized
    )
  end
end
