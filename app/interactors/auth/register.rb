class Auth::Register < ActiveInteraction::Base
  string :name, :email, :password, :password_confirmation

  def execute
    user = User.new(inputs)
    return errors.merge!(user.errors) unless user.save

    user
  end
end
