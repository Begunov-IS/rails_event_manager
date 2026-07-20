class Auth::Login < ActiveInteraction::Base
  string :email
  string :password

  def execute
    user = User.find_by(email: email)
    return errors.add(:base, :invalid_email_or_password) unless user&.authenticate(password)

    {
      user: user,
      token: Encryptors::Jwt::Encrypt.run!(payload: { user_id: user.id })
    }
  end
end
