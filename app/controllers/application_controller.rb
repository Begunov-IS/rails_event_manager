class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def authenticate_user!
    return if current_user

    render_errors(errors: [ { key: "base", messages: [ "401 unauthorized" ] } ], status: :unauthorized)
  end

  def current_user
    return @current_user if defined?(@current_user)

    @current_user = find_user_by_token
  end

  def render_errors(errors: [], status: :unprocessable_entity)
    render json: {
      success: false,
      errors: errors
    }, status: status
  end

  def render_resource_errors(resource, status: :unprocessable_entity)
    errors = resource.errors.attribute_names.map do |attr|
      {
        key: attr.to_s,
        messages: resource.errors.full_messages_for(attr)
      }
    end

    render_errors(errors: errors, status: status)
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
