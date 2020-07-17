# frozen_string_literal: true
require 'jwt'

module Utils
  class AuthToken
    def self.issue_token(payload)
      # Set expiration to 30 days.
      payload['exp'] ||= 30.days.from_now.to_i
      JWT.encode(payload, SERVICES_CONFIG["secret_token"], 'HS256')
    end

    def self.valid?(token)
      leeway = 30 # seconds
      begin
        JWT.decode(token, SERVICES_CONFIG["secret_token"], true, { exp_leeway: leeway, algorithm: 'HS256' })
      rescue => e
        false
      end
    end
  end
end
