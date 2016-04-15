require 'mail'

options = { :address              => "smtp.gmail.com",
            :port                 => 587,
            :domain               => 'your.host.name',
            :user_name            => ENV['EMAIL_NAME'],
            :password             => ENV['EMAIL_PASS'],
            :authentication       => 'plain',
            :enable_starttls_auto => true  }

Mail.defaults do
  delivery_method :smtp, options
end

require File.expand_path('../boot.rb', __FILE__)
Dir[File.expand_path('../../workers/*.rb', __FILE__)].each { |file| require file }
