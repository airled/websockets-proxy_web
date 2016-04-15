class MailSender
  include Sidekiq::Worker

  def perform(subject, body)
    Mail.deliver do
      from     ENV['EMAIL_NAME']
      to       ENV['EMAIL_NAME']
      subject  subject
      body     body
    end
  end
end
