class CategoryBlueprint < Blueprinter::Base
  identifier :id

  view :basic do
    fields :title
  end

  view :index do
    fields :title
  end
end
