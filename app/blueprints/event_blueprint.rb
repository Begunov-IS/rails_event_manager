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

    field :attendees_count do |event|
      event.read_attribute(:attendees_count).to_i
    end

    field :checked_in_count do |event|
      event.read_attribute(:checked_in_count).to_i
    end

    field :available_tickets_count do |event|
      event.read_attribute(:available_tickets_count).to_i
    end

    field :reviews_count do |event|
      event.read_attribute(:reviews_count).to_i
    end

    field :average_rating do |event|
      value = event.read_attribute(:average_rating)
      value.nil? ? nil : value.to_f
    end

    field :sponsors_total_amount do |event|
      event.read_attribute(:sponsors_total_amount).to_f
    end

    association :category, blueprint: CategoryBlueprint, view: :index
    association :owner, blueprint: UserBlueprint, view: :index
    association :venue, blueprint: VenueBlueprint, view: :index

    association :sponsors, blueprint: SponsorBlueprint, view: :basic do |event|
      event.sponsors.sort_by(&:id)
    end
  end
end
