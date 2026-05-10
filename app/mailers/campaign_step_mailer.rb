# Used in development to route campaign step sends through Action Mailer
# so letter_opener_web captures them at /letter_opener instead of leaking
# real Gmail traffic through the connected mailbox.
#
# In production, the campaign sweep talks to GmailSender directly (the
# Gmail API gives us threadId for reply tracking, which Action Mailer
# would discard); this mailer is not on the production path.
#
# Sender address is a placeholder under the RFC-2606 .invalid TLD —
# letter_opener doesn't care about the From column being routable, but
# any pre-prod accidental relay will fail loudly rather than send.
class CampaignStepMailer < ApplicationMailer
  layout false

  FROM_PLACEHOLDER_ADDRESS = "campaign-step@smai.invalid".freeze

  def step
    to        = params[:to]
    subject   = params[:subject]
    body      = params[:body].to_s
    from_name = params[:from_name]
    files     = Array(params[:attachments])

    files.each do |a|
      next if a[:content].blank? || a[:filename].blank?
      attachments[a[:filename]] = {
        mime_type: a[:mime_type] || "application/octet-stream",
        content:   a[:content]
      }
    end

    from_header = if from_name.present?
                    %("#{from_name}" <#{FROM_PLACEHOLDER_ADDRESS}>)
                  else
                    FROM_PLACEHOLDER_ADDRESS
                  end

    mail(to: to, from: from_header, subject: subject, content_type: "text/plain", body: body)
  end
end
