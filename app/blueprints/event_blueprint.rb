class EventBlueprint < Blueprinter::Base
  identifier :id

  view :basic do
    fields :title, :location, :from_date, :to_date, :created_at, :updated_at

    association :owner, blueprint: UserBlueprint, view: :basic
    association :category, blueprint: CategoryBlueprint, view: :basic
    association :venue, blueprint: VenueBlueprint, view: :basic
  end

  view :index do
    fields :title, :location, :from_date, :to_date

    field :attendees_count do |event, options|
      options[:events_info].fetch(event.id).fetch(:attendees_count)
    end

    field :checked_in_count do |event, options|
      options[:events_info].fetch(event.id).fetch(:checked_in_count)
    end

    field :available_tickets_count do |event, options|
      options[:events_info].fetch(event.id).fetch(:available_tickets_count)
    end

    field :reviews_count do |event, options|
      options[:events_info].fetch(event.id).fetch(:reviews_count)
    end

    field :average_rating do |event, options|
      value = options[:events_info].fetch(event.id).fetch(:average_rating)
      value.nil? ? nil : value.to_f
    end

    field :sponsors_total_amount do |event, options|
      options[:events_info].fetch(event.id).fetch(:sponsors_total_amount).to_f
    end

    association :category, blueprint: CategoryBlueprint, view: :basic
    association :owner, blueprint: UserBlueprint, view: :index
    association :venue, blueprint: VenueBlueprint, view: :index

    association :sponsors, blueprint: SponsorBlueprint, view: :basic do |event, options|
      options[:events_info].fetch(event.id).fetch(:sponsors)
    end
  end
end
