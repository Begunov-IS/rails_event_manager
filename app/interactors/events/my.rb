class Events::My < ActiveInteraction::Base
  object :user

  def execute
    Event.includes(:owner, :category, :venue).owned_by(user)
  end
end
