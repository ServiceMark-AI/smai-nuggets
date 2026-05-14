module JobProposalsHelper
  SORTABLE_COLUMNS = %w[created_at proposal_value].freeze
  DEFAULT_SORT_DIR = "desc".freeze

  # Count of proposals visible to the current user that need operator
  # action (drafting, approving, or in-campaign with a customer reply
  # / delivery issue overlay). Drives the sidebar "Needs Attention"
  # badge. Memoized per request because the layout calls this on
  # every authenticated page render.
  def needs_attention_count
    return 0 unless current_user
    @_needs_attention_count ||= JobProposal.accessible_by(current_ability).needs_attention.count
  end

  def sortable_header(column, label, th_class: nil)
    current_column = active_sort_column
    current_dir = active_sort_direction
    is_active = current_column == column

    # Toggle direction if clicking the same column; otherwise default desc.
    next_dir = is_active && current_dir == "desc" ? "asc" : DEFAULT_SORT_DIR

    icon = if is_active
      current_dir == "asc" ? "↑" : "↓"
    else
      "↕"
    end
    icon_class = is_active ? "ms-1 small" : "ms-1 text-muted small"

    new_params = request.query_parameters.merge(sort: column, dir: next_dir)

    content_tag(:th, class: th_class) do
      link_to url_for(new_params), class: "text-decoration-none text-reset" do
        safe_join([label, content_tag(:span, icon, class: icon_class)])
      end
    end
  end

  def active_sort_column
    SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def active_sort_direction
    %w[asc desc].include?(params[:dir]) ? params[:dir] : DEFAULT_SORT_DIR
  end

  # Renders the next-action button/link for a proposal based on its CTA.
  # Single source of truth for the call-to-action UI — keep new CTAs added to
  # JobProposal.cta_for in lockstep with a branch here.
  def job_proposal_cta_link(jp)
    case jp.cta
    when :review_proposal
      link_to "Review", edit_job_proposal_path(jp), class: "btn btn-warning btn-sm"
    when :review_campaign
      instance = jp.campaign_instances.order(created_at: :desc).first
      if instance
        link_to "Review Campaign", job_proposal_campaign_instance_path(jp, instance),
                class: "btn btn-warning btn-sm"
      end
    when :view_job
      link_to "View job", job_proposal_path(jp), class: "btn btn-primary btn-sm"
    when :open_in_gmail
      link_to "Open in Gmail", gmail_thread_url(jp.gmail_thread_id),
              class: "btn btn-success btn-sm",
              target: "_blank", rel: "noopener"
    when :fix_delivery_issue
      link_to "Fix Issue", edit_job_proposal_path(jp),
              class: "btn btn-danger btn-sm"
    when :resume_campaign
      button_to "Resume", resume_job_proposal_path(jp),
                method: :patch,
                class: "btn btn-success btn-sm",
                form: { class: "d-inline" }
    end
  end

  def gmail_thread_url(thread_id)
    return "https://mail.google.com/mail/u/0/" if thread_id.blank?
    "https://mail.google.com/mail/u/0/#all/#{thread_id}"
  end

  # Inline status-overlay label rendered on the proposal index card.
  # Returns nil when there's no overlay so callers can render nothing.
  OVERLAY_LABELS = {
    "customer_waiting" => { text: "reply needed",  klass: "text-warning fw-semibold" },
    "delivery_issue"   => { text: "delivery issue", klass: "text-danger fw-semibold" },
    "paused"           => { text: "paused",        klass: "text-muted fw-semibold" }
  }.freeze

  def proposal_overlay_label(jp)
    cfg = OVERLAY_LABELS[jp.status_overlay]
    return nil unless cfg
    content_tag(:span, cfg[:text], class: cfg[:klass])
  end

  # Display label for a proposal's job type. Strips a trailing "Job type"
  # from the JobType.name so labels like "Development Job Type" render as
  # "Development" — the "Job type" suffix is redundant in context.
  def proposal_job_type_label(jp)
    name = jp.job_type&.name
    return nil if name.blank?
    name.sub(/\s+Job\s+type\z/i, "").presence
  end

  # Single-line customer address: "house street, city ST zip".
  # Empty parts are dropped; returns nil when nothing to show.
  def proposal_full_address(jp)
    street = [jp.customer_house_number, jp.customer_street].map { |p| p.to_s.strip }.reject(&:empty?).join(" ")
    city_state = [jp.customer_city, jp.customer_state].map { |p| p.to_s.strip }.reject(&:empty?).join(" ")
    tail = [city_state, jp.customer_zip.to_s.strip].reject(&:empty?).join(" ")
    [street, tail].reject(&:empty?).join(", ").presence
  end

  # Red asterisk used to flag required fields on the proposal edit form. The
  # asterisk is decorative — the input itself carries `required: true` for
  # screen readers and form-level submit prevention.
  def required_marker
    content_tag(:span, "*", class: "text-danger ms-1", "aria-hidden": "true")
  end

  # Renders a small "Needed for the campaign to start: ..." caption under
  # an edit-form input when the corresponding field is blank and the
  # proposal isn't already in flight. Returns nil (renders nothing) when
  # the field has a value, so the form stays clean once everything's
  # filled in.
  def readiness_warning_for(job_proposal, field)
    return nil if job_proposal.campaign_instances.exists? # in flight, no need to nag
    blocker = job_proposal.campaign_readiness_blockers.find { |b| b[:field] == field }
    return nil unless blocker

    content_tag(:div, class: "form-text text-warning") do
      safe_join([
        content_tag(:strong, "Needed for the campaign to start: "),
        blocker[:reason]
      ])
    end
  end

  # Operator-readable description of where a JobProposalAttachment's file
  # actually lives. Active Storage decouples blob from backend, but the
  # operator on the proposal show page needs a "I can find this file
  # here" label, especially when troubleshooting bounces or mis-uploads.
  # Returns a hash: { service: "Google Cloud Storage", location: "bucket your-bucket", key: "abc..." }.
  # Falls back gracefully when the service object doesn't expose a
  # familiar shape — newer Active Storage releases or custom services.
  def attachment_storage_source(file)
    blob = file.blob
    service = ActiveStorage::Blob.services.fetch(blob.service_name) rescue blob.service
    case service.class.name
    when "ActiveStorage::Service::GCSService"
      bucket = (service.instance_variable_get(:@config) || {})[:bucket] || ENV["GCS_BUCKET"]
      { service: "Google Cloud Storage", location: bucket ? "bucket #{bucket}" : nil, key: blob.key }
    when "ActiveStorage::Service::S3Service"
      bucket = (service.bucket.name rescue nil) || ENV["AWS_BUCKET"]
      { service: "Amazon S3", location: bucket ? "bucket #{bucket}" : nil, key: blob.key }
    when "ActiveStorage::Service::DiskService"
      root = service.instance_variable_get(:@root)
      { service: "Local disk", location: root ? "path #{root}" : nil, key: blob.key }
    else
      { service: service.class.name.demodulize.sub("Service", ""), location: nil, key: blob.key }
    end
  end
end
