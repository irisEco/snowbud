# frozen_string_literal: true

require 'bcrypt'

module Devise
  module Encryptor
    def self.digest(klass, password)
      ::BCrypt::Password.create(password, cost: 11).to_s
    end

    def self.compare(klass, hashed_password, password)
      return false if hashed_password.blank?
      bcrypt   = ::BCrypt::Password.new(hashed_password)
      password = ::BCrypt::Engine.hash_secret(password, bcrypt.salt)
      Devise.secure_compare(password, hashed_password)
    end
  end

  # constant-time comparison algorithm to prevent timing attacks
  def self.secure_compare(a, b)
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end
