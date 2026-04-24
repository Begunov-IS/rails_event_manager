class EventsController < ActionController::API
  before_action :authenticate_user!, only: [:my]
  before_action :set_event, only: [:show, :update, :destroy]

  def index
    outcome = Events::Index.run(
      params.permit(
        :city,
        :owner_id,
        :from_date,
        :to_date,
        :with_available_tickets,
        :with_checked_in_users,
        :sort_by,
        :page,
        :per_page,
        category_ids: []
      )
    )

    if outcome.valid?
      render_success(
        :events,
        EventBlueprint.render_as_hash(outcome.result.fetch(:events), view: :index),
        meta: outcome.result.fetch(:pagination_info)
      )
    else
      render_failure(outcome.errors, status: :unprocessable_entity)
    end
  end

  def my
    events = Event.includes(:owner, :category, :venue).owned_by(current_user)
    render_success(:events, EventBlueprint.render_as_hash(events, view: :basic))
  end

  def show
    render_success(:event, EventBlueprint.render_as_hash(@event, view: :basic))
  end

  def create
    outcome = Events::Create.run(create_event_params)

    if outcome.valid?
      render_success(
        :event,
        EventBlueprint.render_as_hash(outcome.result, view: :basic),
        status: :created
      )
    else
      render_failure(outcome.errors, status: :unprocessable_entity)
    end
  end

  def update
    outcome = Events::Update.run(update_event_params.merge(event: @event))

    if outcome.valid?
      render_success(:event, EventBlueprint.render_as_hash(outcome.result, view: :basic))
    else
      render_failure(outcome.errors, status: :unprocessable_entity)
    end
  end

  def destroy
    Events::Destroy.run!(event: @event)
    head :no_content
  end

  private

  def authenticate_user!
    return if current_user

    render_failure({ base: ['unauthorized'] }, status: :unauthorized)
  end

  def current_user
    @current_user ||= User.find_by(id: request.headers['X-User-Id'])
  end

  def set_event
    outcome = Events::Find.run(id: params[:id])
    @event = outcome.result

    return if @event

    render_failure({ base: ['event not found'] }, status: :not_found)
  end

  def create_event_params
    params.require(:event).permit(:title, :location, :from_date, :to_date, :owner_id, :category_id, :venue_id)
  end

  def update_event_params
    params.fetch(:event, ActionController::Parameters.new)
      .permit(:title, :location, :from_date, :to_date, :owner_id, :category_id, :venue_id)
  end

  def render_success(resource_key, resource, status: :ok, meta: nil)
    render json: {
      success: true,
      resource_key => resource,
      meta: meta
    }.compact, status: status
  end

  def render_failure(errors, status:)
    render json: {
      success: false,
      errors: normalize_errors(errors)
    }, status: status
  end

  def normalize_errors(errors)
    case errors
    when ActiveModel::Errors
      normalize_errors(errors.to_hash)
    when Hash
      errors.map { |key, messages| error_entry(key, messages) }
    else
      Array(errors).map { |error| normalize_error(error) }
    end
  end

  def normalize_error(error)
    return error_entry(error[:key], error[:messages]) if error.is_a?(Hash) && error.key?(:key)

    if error.is_a?(Hash) && error.size == 1
      key, messages = error.first
      return error_entry(key, messages)
    end

    error_entry(:base, error)
  end

  def error_entry(key, messages)
    {
      key: key.to_s,
      messages: Array(messages)
    }
  end
end
