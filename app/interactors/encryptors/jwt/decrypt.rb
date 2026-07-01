class Encryptors::Jwt::Decrypt < ActiveInteraction::Base
  ALGORITHM = "HS512".freeze

  string :token, default: nil
  string :secret, default: Rails.configuration.session_jwt_secret_key

  def execute
    JWT.decode(token, secret, true, { algorithm: ALGORITHM }).first
  rescue JWT::DecodeError
    errors.add(:token, :invalid)
  end
end
