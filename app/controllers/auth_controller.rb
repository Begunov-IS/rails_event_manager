class AuthController < ApplicationController
  def register
    outcome = Auth::Register.run(user_params)
    return render_resource_errors(outcome) if outcome.errors.present?

    render json: {
      success: true,
      user: UserBlueprint.render_as_hash(outcome.result, view: :basic)
    }, status: :created
  end

  def login
    outcome = Auth::Login.run(params)
    return render_resource_errors(outcome, status: :unauthorized) if outcome.errors.present?

    result = outcome.result

    render json: {
      success: true,
      token: result[:token],
      user: UserBlueprint.render_as_hash(result[:user], view: :basic)
    }
  end

  private

  def user_params
    params.fetch(:user, ActionController::Parameters.new)
  end
end
