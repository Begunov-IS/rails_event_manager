class Encryptors::Jwt::Encrypt < ActiveInteraction::Base
  ALGORITHM = "HS512".freeze

  hash :payload, strip: false
  string :secret, default: Rails.configuration.session_jwt_secret_key
  integer :seconds, default: Rails.configuration.jwt_token_expire_time

  def execute
    JWT.encode(payload.merge(exp: Time.current.to_i + seconds), secret, ALGORITHM)
  end
end
