class Events::Find < ActiveInteraction::Base
  integer :event_id

  def execute
    event = Event.find_by(id: event_id)
    return event if event

    errors.add(:event_id, :not_found)
    nil
  end
end
