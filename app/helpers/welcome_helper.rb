# Helper methods defined here can be accessed in any controller or view in the application

module WebsocketsProxyWeb
  class App
    module WelcomeHelper

      def send_email(subject, body)
        email(from: ENV['EMAIL_NAME'], to: ENV['EMAIL_NAME'], subject: subject, body: body)
      end

      def generate_uniq_queue
        require 'securerandom'
        queue = ''
          loop do
            current_queue = SecureRandom.hex
            if Profile[queue: current_queue].nil?
              queue = current_queue
              break
            end
          end
        queue
      end
      
    end

    helpers WelcomeHelper
  end
end
