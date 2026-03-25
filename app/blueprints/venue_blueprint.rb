class VenueBlueprint < Blueprinter::Base
  identifier :id
  fields :name, :city, :address, :capacity
end
