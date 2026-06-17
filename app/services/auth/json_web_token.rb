module Auth
  class JsonWebToken
    ALGORITHM = "HS256".freeze
    EXPIRES_IN = 24.hours

    class << self
      def encode(payload)
        JWT.encode(payload.merge(exp: EXPIRES_IN.from_now.to_i), secret_key, ALGORITHM)
      end

      def decode(token)
        return if token.blank?

        JWT.decode(token, secret_key, true, { algorithm: ALGORITHM }).first
      rescue JWT::DecodeError
        nil
      end

      private

      def secret_key
        Rails.application.secret_key_base
      end
    end
  end
end
