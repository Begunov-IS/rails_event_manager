class VenueBlueprint < Blueprinter::Base
  identifier :id

  view :basic do
    fields :name, :city, :address, :capacity
  end

  view :index do
    fields :name, :city, :address
  end
end
