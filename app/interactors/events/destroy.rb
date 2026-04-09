module Events
  class Destroy < ActiveInteraction::Base
    object :event

    def execute
      event.destroy
    end
  end
end
