class EventsController < ActionController::API
  before_action :authenticate_user!, only: [:my]
  before_action :set_event, only: [:show, :update, :destroy]

  def index
    outcome = Events::Index.run(index_params)

    if outcome.valid?
      render json: EventBlueprint.render(outcome.result, view: :index)
    else
      render json: { errors: outcome.errors }, status: :unprocessable_entity
    end
  end

  def my
    events = Event.includes(:owner, :category, :venue).owned_by(current_user)
    render json: EventBlueprint.render(events, view: :basic)
  end

  def show
    render json: EventBlueprint.render(@event, view: :basic)
  end

  def create
    outcome = Events::Create.run(event_params)

    if outcome.valid?
      render json: EventBlueprint.render(outcome.result, view: :basic), status: :created
    else
      render json: { errors: outcome.errors }, status: :unprocessable_entity
    end
  end

  def update
    outcome = Events::Update.run(event_params.merge(event: @event))

    if outcome.valid?
      render json: EventBlueprint.render(outcome.result, view: :basic)
    else
      render json: { errors: outcome.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    Events::Destroy.run!(event: @event)
    head :no_content
  end

  private

  def authenticate_user!
    render json: { error: 'unauthorized' }, status: :unauthorized unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: request.headers['X-User-Id'])
  end

  def set_event
    @event = Event.find_by(id: params[:id])
    render json: { error: 'event not found' }, status: :not_found unless @event
  end

  def event_params
    params.require(:event).permit(:title, :location, :from_date, :to_date, :owner_id, :category_id, :venue_id)
  end

  def index_params
    {}.tap do |result|
      result[:category_ids] = normalized_category_ids if normalized_category_ids.any?
      result[:city] = params[:city] if params[:city].present?
      result[:owner_id] = params[:owner_id] if params[:owner_id].present?
      result[:from_date] = params[:from_date] if params[:from_date].present?
      result[:to_date] = params[:to_date] if params[:to_date].present?
      result[:with_available_tickets] = params[:with_available_tickets] if params.key?(:with_available_tickets)
      result[:with_checked_in_users] = params[:with_checked_in_users] if params.key?(:with_checked_in_users)
      result[:sort_by] = params[:sort_by] if params[:sort_by].present?
      result[:page] = params[:page] if params[:page].present?
      result[:per_page] = params[:per_page] if params[:per_page].present?
    end
  end

  def normalized_category_ids
    raw_category_ids = params[:category_ids]
    return [] if raw_category_ids.blank?

    if raw_category_ids.is_a?(String)
      raw_category_ids.split(',')
    else
      Array(raw_category_ids)
    end
  end
end
