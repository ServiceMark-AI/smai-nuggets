module JobProposalHistoriesHelper
  # Operator-facing one-liner for the activity timeline. Folds an
  # arbitrary-sized changeset into a comma-separated list of humanized
  # field names so the timeline stays scannable.
  def history_summary(version)
    case version.event
    when "create"  then "Job proposal created"
    when "destroy" then "Job proposal deleted"
    else
      fields = (version.changeset || {}).keys
      return "Updated" if fields.empty?
      "Updated #{fields.map { |f| f.to_s.humanize.downcase }.to_sentence}"
    end
  end

  # Whodunnit is stored as a string id; resolve to a User if we can,
  # otherwise show "System" so a job-driven write or pre-paper_trail
  # row reads cleanly.
  def history_actor_label(version)
    return "System" if version.whodunnit.blank?
    user = User.find_by(id: version.whodunnit)
    user&.display_name || "User ##{version.whodunnit}"
  end
end
