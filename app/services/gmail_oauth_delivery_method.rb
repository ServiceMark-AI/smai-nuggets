# ActionMailer delivery method that routes outbound mail through the
# singleton ApplicationMailbox via Gmail OAuth. Used so Devise emails
# (password resets, etc.) and any other ActionMailer mail in the app go
# through the same connected mailbox without SMTP credentials.
#
# Registered in config/initializers/gmail_oauth_delivery.rb. Set
#   config.action_mailer.delivery_method = :gmail_oauth
# in the desired environments.
#
# If the application mailbox is not yet connected, the delivery is logged
# and dropped — the request flow is not aborted.
class GmailOauthDeliveryMethod
  def initialize(settings = {})
    @settings = settings || {}
  end

  def deliver!(mail)
    mailbox = ApplicationMailbox.current
    if mailbox.nil?
      Rails.logger.warn "[GmailOauthDeliveryMethod] no application mailbox connected; dropping mail to #{Array(mail.to).join(', ')} (subject: #{mail.subject.inspect})"
      return false
    end

    GmailSender.new(mailbox).send_mail(mail)
  end
end
