# Thin helper for writing AuditLog rows from controllers/services. Per
# PRD-10 v1.3.1 §10, every state-changing admin operation goes through
# here so the audit trail stays uniform.
#
# Usage:
#   AuditLogger.write(tenant: @tenant, actor: current_user,
#                     action: "tenant.update", target: @tenant,
#                     before: { name: old_name }, after: { name: new_name })
class AuditLogger
  def self.write(tenant:, actor:, action:, target:, before: nil, after: nil)
    AuditLog.create!(
      tenant: tenant,
      actor_user: actor,
      action: action,
      target_type: target.class.name,
      target_id: target.id,
      payload: { before: before, after: after }.compact
    )
  end
end
