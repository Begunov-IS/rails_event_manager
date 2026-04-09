class EventBlueprint < Blueprinter::Base
  identifier :id

  view :basic do
    fields :title, :location, :from_date, :to_date, :created_at, :updated_at

    association :owner, blueprint: UserBlueprint, view: :basic
    association :category, blueprint: CategoryBlueprint, view: :basic
    association :venue, blueprint: VenueBlueprint, view: :basic
  end
end
