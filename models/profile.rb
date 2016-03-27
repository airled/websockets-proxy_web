class Profile < Sequel::Model

  many_to_one :account

  def active?
    self.active == true
  end

end
