# Custom PaperTrail::Version subclass used for every audit row in this
# app. The whole point of the audit trail is "you can't quietly rewrite
# history," so block updates and destroys at the Rails layer. Records
# stay queryable; mutations raise `ActiveRecord::ReadOnlyRecord`.
#
# Wired in via config/initializers/paper_trail.rb
# (`PaperTrail.config.version_class_name = "Version"`).
class Version < PaperTrail::Version
  before_update  :reject_mutation
  before_destroy :reject_mutation

  def readonly?
    persisted?
  end

  private

  def reject_mutation
    raise ActiveRecord::ReadOnlyRecord, "audit-trail Version rows are immutable once written"
  end
end
