module Events
  class Destroy
    include Interactor

    def call
      context.event.destroy
    end
  end
end
