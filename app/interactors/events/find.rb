class Events::Find < ActiveInteraction::Base
  integer :id

  def execute
    Event.includes(:owner, :category, :venue).find_by(id: id)
  end
end
