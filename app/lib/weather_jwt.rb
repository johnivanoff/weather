class WeatherJwt
  attr_reader :jwt

  def initialize
    @jwt = generate_jwt
  end

  private
    def generate_jwt
      JWT.encode(payload, private_key, "ES256", header)
    end

    def header
      {
        "alg" => "ES256",
        "kid" => Rails.application.credentials.dig(:weather, :apple_key_id)
      }
    end

    def payload
      {
        "iss" => Rails.application.credentials.dig(:team_id),
        "iat" => Time.now.to_i,
        "exp" => Time.now.to_i + 60 * 60 * 24 * 30 * 5, # Expire in 5 months
        "sub" => Rails.application.credentials.dig(:weather, :client_id)
      }
    end

    def private_key
      OpenSSL::PKey.read(Rails.application.credentials.dig(:weather, :private_key))
    end
end
