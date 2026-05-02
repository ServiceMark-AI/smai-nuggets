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
end
