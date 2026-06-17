class EventsController < ApplicationController
  before_action :authenticate_user!, only: [ :my ]
  before_action :set_event, only: [ :show, :update, :destroy ]

  def index
    outcome = Events::Index.run(params)
    return render_resource_errors(outcome) if outcome.errors.present?

    result = outcome.result
    render json: { success: true }.merge(
      EventBlueprint.render_as_hash(
        result[:events],
        view: :index,
        root: :events,
        meta: result[:pagination_info],
        events_info: result[:events_info]
      )
    )
  end

  def my
    events = Events::My.run!(user: current_user)
    render json: { success: true }.merge(EventBlueprint.render_as_hash(events, view: :basic, root: :events))
  end

  def show
    render json: { success: true }.merge(EventBlueprint.render_as_hash(@event, view: :basic, root: :event))
  end

  def create
    outcome = Events::Create.run(event_params)
    return render_resource_errors(outcome) if outcome.errors.present?

    render json: { success: true }.merge(
      EventBlueprint.render_as_hash(outcome.result, view: :basic, root: :event)
    ), status: :created
  end

  def update
    outcome = Events::Update.run(event_params.merge(event: @event))
    return render_resource_errors(outcome) if outcome.errors.present?

    render json: { success: true }.merge(EventBlueprint.render_as_hash(outcome.result, view: :basic, root: :event))
  end

  def destroy
    Events::Destroy.run!(event: @event)
    head :no_content
  end

  private

  def set_event
    outcome = Events::Find.run(event_id: params[:id])
    return render_resource_errors(outcome, status: :not_found) if outcome.errors.present?

    @event = outcome.result
  end

  def event_params
    params.fetch(:event, ActionController::Parameters.new)
      .permit(:title, :location, :from_date, :to_date, :owner_id, :category_id, :venue_id)
  end
end
