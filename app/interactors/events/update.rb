module Events
  class Update
    include Interactor

    def call
      if context.event.update(context.params)
        # event уже обновлён
      else
        context.fail!(errors: context.event.errors)
      end
    end
  end
end
