namespace :gmail do
  desc "Diagnose what GmailReplyPollJob would do this tick — list every step instance it would poll, fetch each thread, and explain the reply-detection decision per thread. Read-only."
  task diagnose_replies: :environment do
    mailbox = ApplicationMailbox.current
    if mailbox.nil?
      puts "[gmail:diagnose_replies] No application mailbox connected. The poll job is a no-op until one is connected via /admin/application_mailbox."
      next
    end

    puts "[gmail:diagnose_replies] Mailbox: #{mailbox.email}"
    puts "[gmail:diagnose_replies] Cutoff:  #{(Time.current - GmailReplyPollJob::POLLING_CUTOFF).iso8601}"

    job = GmailReplyPollJob.new
    sender = GmailSender.new(mailbox)
    ids = job.send(:pollable_step_instance_ids, Time.current)

    if ids.empty?
      puts "[gmail:diagnose_replies] No step instances are eligible to poll this tick."
      next
    end

    puts "[gmail:diagnose_replies] #{ids.size} step instance(s) eligible:"
    puts ""

    ids.each do |id|
      step = CampaignStepInstance.find(id)
      instance = step.campaign_instance
      host = instance.host
      proposal_label = host.is_a?(JobProposal) ? "proposal ##{host.id} — #{host.customer_first_name} #{host.customer_last_name} <#{host.customer_email}>" : host.class.name
      puts "=" * 80
      puts "Step instance ##{step.id} (#{proposal_label})"
      puts "  campaign_instance: ##{instance.id}  status=#{instance.status}  ended_at=#{instance.ended_at&.iso8601 || '—'}"
      puts "  gmail_thread_id:   #{step.gmail_thread_id}"
      puts "  snapshot present?  #{step.gmail_thread_snapshot.present?}"
      puts "  step sent at:      #{step.updated_at.iso8601}"

      thread = sender.fetch_thread(step.gmail_thread_id)
      if thread.nil?
        puts "  >>> thread fetch returned nil (transient failure, missing scope, or 404). Job would log and skip."
        puts ""
        next
      end

      live_messages = Array(thread["messages"])
      snapshot_messages = Array(step.gmail_thread_snapshot && step.gmail_thread_snapshot["messages"])
      puts "  live messages:     #{live_messages.size}"
      puts "  snapshot messages: #{snapshot_messages.size}"

      live_messages.each_with_index do |msg, i|
        is_new = i >= snapshot_messages.size
        from_value = extract_header(msg, "From")
        date_value = extract_header(msg, "Date")
        parsed = parse_email(from_value)
        from_other = parsed.present? && parsed.casecmp(mailbox.email.to_s) != 0
        marker = is_new ? "NEW    " : "BASE   "
        puts "    [#{i}] #{marker} from=#{from_value.inspect}"
        puts "         date=#{date_value.inspect}"
        puts "         parsed_sender=#{parsed.inspect} from_other_party?=#{from_other}"
      end

      if step.gmail_thread_snapshot.blank?
        puts "  >>> DECISION: first-pass baseline. Job would persist the live thread as the snapshot and bail."
      elsif live_messages.size <= snapshot_messages.size
        puts "  >>> DECISION: no new messages since send-time snapshot. No reply."
      else
        new_msgs = live_messages.last(live_messages.size - snapshot_messages.size)
        reply = new_msgs.find { |m| from_other_party?(m, mailbox.email) }
        if reply
          puts "  >>> DECISION: REPLY DETECTED on message id=#{reply['id']}. Job would flag customer_replied=true, store payload, stop campaign instance."
        else
          puts "  >>> DECISION: new messages exist but all are from the mailbox itself (e.g., follow-up sends). No reply."
        end
      end
      puts ""
    end
  end

  def extract_header(message, name)
    headers = message.dig("payload", "headers") || []
    headers.find { |h| h["name"].to_s.casecmp(name).zero? }&.dig("value").to_s
  end

  def parse_email(from_value)
    bracketed = from_value.match(/<([^>]+)>/)
    return bracketed[1].strip if bracketed
    bare = from_value.match(/\S+@\S+/)
    bare ? bare[0].strip : ""
  end

  def from_other_party?(message, mailbox_email)
    from_value = extract_header(message, "From")
    sender_email = parse_email(from_value)
    sender_email.present? && sender_email.casecmp(mailbox_email.to_s) != 0
  end
end
