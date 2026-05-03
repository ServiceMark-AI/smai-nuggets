module JobProposalsHelper
  SORTABLE_COLUMNS = %w[created_at proposal_value].freeze
  DEFAULT_SORT_DIR = "desc".freeze

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
    when :view_job
      link_to "View job", job_proposal_path(jp), class: "btn btn-outline-primary btn-sm"
    when :open_in_gmail
      link_to "Open in Gmail", gmail_thread_url(jp.gmail_thread_id),
              class: "btn btn-outline-success btn-sm",
              target: "_blank", rel: "noopener"
    when :fix_delivery_issue
      link_to "Fix delivery issue", edit_job_proposal_path(jp),
              class: "btn btn-outline-warning btn-sm"
    when :resume_campaign
      button_to "Resume campaign", resume_job_proposal_path(jp),
                method: :patch,
                class: "btn btn-outline-primary btn-sm",
                form: { class: "d-inline" }
    end
  end

  def gmail_thread_url(thread_id)
    return "https://mail.google.com/mail/u/0/" if thread_id.blank?
    "https://mail.google.com/mail/u/0/#all/#{thread_id}"
  end
end
