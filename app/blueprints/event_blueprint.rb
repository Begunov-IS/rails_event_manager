class EventBlueprint < Blueprinter::Base
  identifier :id
  fields :title, :location, :from_date, :to_date, :created_at, :updated_at

  association :owner, blueprint: UserBlueprint
  association :category, blueprint: CategoryBlueprint
  association :venue, blueprint: VenueBlueprint
end
