module Events
  class Update < ActiveInteraction::Base
    object :event

    string :title, default: nil
    string :location, default: nil
    time :from_date, default: nil
    time :to_date, default: nil
    integer :owner_id, default: nil
    integer :category_id, default: nil
    integer :venue_id, default: nil

    def execute
      params = inputs.except(:event).compact

      if event.update(params)
        event
      else
        errors.merge!(event.errors)
      end
    end
  end
end
