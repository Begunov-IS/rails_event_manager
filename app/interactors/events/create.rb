module Events
  class Create
    include Interactor

    def call
      event = Event.new(context.params)

      if event.save
        context.event = event
      else
        context.fail!(errors: event.errors)
      end
    end
  end
end
