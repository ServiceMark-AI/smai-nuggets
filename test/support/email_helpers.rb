# Pulls a URL out of the most recent ActionMailer delivery so system
# tests can `visit` it directly. Test env uses delivery_method = :test
# which captures every send into ActionMailer::Base.deliveries; this
# helper just unwraps the body.
#
# Example:
#   click_button "Send me reset password instructions"
#   visit link_in_last_email(matching: "reset_password")
#
# Pass `body_part: :text` to read the text part instead of the default
# HTML part — useful when the link wording differs across parts.
module EmailHelpers
  def last_email
    ActionMailer::Base.deliveries.last
  end

  def link_in_last_email(matching:, body_part: :html)
    raise "no emails delivered yet" if ActionMailer::Base.deliveries.empty?
    body = email_body(last_email, body_part)
    match = body.match(%r{(https?://[^\s"'<]*#{Regexp.escape(matching)}[^\s"'<]*)})
    raise "no link matching #{matching.inspect} in last email body:\n#{body}" if match.nil?
    match[1]
  end

  private

  def email_body(mail, body_part)
    case body_part
    when :html then (mail.html_part || mail).body.to_s
    when :text then (mail.text_part || mail).body.to_s
    else raise ArgumentError, "body_part must be :html or :text"
    end
  end
end
