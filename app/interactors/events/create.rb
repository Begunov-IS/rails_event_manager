module Events
  class Create < ActiveInteraction::Base
    string :title, :location
    time :from_date, :to_date
    integer :owner_id
    integer :category_id, default: nil
    integer :venue_id, default: nil

    def execute
      event = Event.new(inputs)

      if event.save
        event
      else
        errors.merge!(event.errors)
      end
    end
  end
end
