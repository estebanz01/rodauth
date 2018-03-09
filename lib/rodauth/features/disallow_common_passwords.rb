# frozen-string-literal: true

module Rodauth
  Feature.define(:disallow_common_passwords, :DisallowCommonPasswords) do
    depends :login_password_requirements_base

    auth_value_method :most_common_passwords_file, File.join(File.dirname(File.dirname(File.dirname(File.dirname(File.expand_path(__FILE__))))), 'dict', 'top-10_000-passwords.txt')
    auth_value_method :password_is_one_of_the_most_common_message, "is one of the most common passwords"
    auth_value_method :most_common_passwords, nil

    auth_methods :password_one_of_most_common?

    def password_meets_requirements?(password)
      super && password_not_one_of_the_most_common?(password)
    end

    def post_configure
      super

      return if most_common_passwords || !most_common_passwords_file

      require 'set'
      most_common = Set.new(File.read(most_common_passwords_file).split("\n")).freeze
      self.class.send(:define_method, :most_common_passwords){most_common}
    end

    def password_one_of_most_common?(password)
      most_common_passwords.include?(password)
    end

    private

    def password_not_one_of_the_most_common?(password)
      return true unless password_one_of_most_common?(password)
      @password_requirement_message = password_is_one_of_the_most_common_message
      false
    end
  end
end
