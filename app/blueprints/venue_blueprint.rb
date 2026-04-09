class VenueBlueprint < Blueprinter::Base
  identifier :id

  view :basic do
    fields :name, :city, :address, :capacity
  end
end
