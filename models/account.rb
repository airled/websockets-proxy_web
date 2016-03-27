class Account < Sequel::Model

  one_to_many :profiles

  plugin :validation_helpers

  attr_accessor :password, :password_confirmation

  def validate
    validates_presence     :email
    validates_presence     :role
    validates_presence     :password if password_required
    validates_presence     :password_confirmation if password_required
    validates_length_range 4..40, :password unless password.blank?
    errors.add(:password_confirmation, 'must confirm password') if !password.blank? && password != password_confirmation
    validates_length_range 3..100, :email unless email.blank?
    validates_unique       :email unless email.blank?
    validates_format       /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :email unless email.blank?
    validates_format       /[A-Za-z]/, :role unless role.blank?
  end

  # Callbacks
  def before_save
    encrypt_password
  end

  ##
  # This method is for authentication purpose.
  #
  def self.authenticate(email, password)
    account = filter(Sequel.function(:lower, :email) => Sequel.function(:lower, email)).first
    account && account.has_password?(password) ? account : nil
  end

  ##
  # Replace ActiveRecord method.
  #
  def self.find_by_id(id)
    self[id] rescue nil
  end

  def has_password?(password)
    ::BCrypt::Password.new(self.crypted_password) == password
  end

  def admin?
    self.role == 'admin'
  end

  def add_default_profile
    require 'securerandom'
    loop do
      queue = SecureRandom.hex
      if Profile[queue: queue].nil?
        self.add_profile(name: 'default', queue: queue) 
        break
      end
    end
  end

  def destroy_all_profiles
    self.profiles.each { |profile| profile.destroy }
  end

  private

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password) if password.present?
  end

  def password_required
    self.crypted_password.blank? || password.present?
  end

end
