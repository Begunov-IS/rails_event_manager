class EventsController < ActionController::API
  before_action :set_event, only: [:show, :update, :destroy]

  def index
    events = Event.includes(:owner, :category, :venue)
    events = events.where(category_id: params[:category_id]) if params[:category_id].present?
    events = events.where('from_date >= ?', params[:from_date]) if params[:from_date].present?
    events = events.where('to_date <= ?', params[:to_date]) if params[:to_date].present?
    render json: EventBlueprint.render(events)
  end

  def show
    render json: EventBlueprint.render(@event)
  end

  def create
    result = Events::Create.call(params: event_params)

    if result.success?
      render json: EventBlueprint.render(result.event), status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def update
    result = Events::Update.call(event: @event, params: event_params)

    if result.success?
      render json: EventBlueprint.render(@event)
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    Events::Destroy.call(event: @event)
    head :no_content
  end

  private

  def set_event
    @event = Event.find_by(id: params[:id])
    render json: { error: 'event not found' }, status: :not_found unless @event
  end

  def event_params
    params.require(:event).permit(:title, :location, :from_date, :to_date, :owner_id, :category_id, :venue_id)
  end
end
