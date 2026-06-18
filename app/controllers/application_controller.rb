class ApplicationController < ActionController::Base
  include SessionAuthorizable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

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
end
