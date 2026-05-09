# Append-only record of a state-changing admin operation. Per PRD-10
# v1.3.1 §10, every Admin Portal write goes through here so an SMAI
# operator can answer "who changed what, when?"
#
# AuditLog rows are never updated or deleted; the Rails-side accessor is
# read-only after creation.
class AuditLog < ApplicationRecord
  belongs_to :tenant
  belongs_to :actor_user, class_name: "User", optional: true

  validates :action, :target_type, :target_id, presence: true

  before_update do
    raise ActiveRecord::ReadOnlyRecord, "audit_logs is append-only"
  end

  before_destroy do
    raise ActiveRecord::ReadOnlyRecord, "audit_logs is append-only"
  end
end
