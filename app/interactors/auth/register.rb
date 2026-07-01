class Auth::Register < ActiveInteraction::Base
  string :name
  string :email
  string :password
  string :password_confirmation

  def execute
    user = User.new(inputs)
    return user if user.save

    errors.merge!(user.errors)
  end
end
