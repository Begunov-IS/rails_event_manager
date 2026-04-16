class UserBlueprint < Blueprinter::Base
  identifier :id

  view :basic do
    fields :name, :email
  end

  view :index do
    fields :name, :email
  end
end
