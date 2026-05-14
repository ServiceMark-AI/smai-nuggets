class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.is_admin
      can :manage, :all
      return
    end

    tenant_id = user.tenant_id

    can :read, Tenant, id: tenant_id if tenant_id

    can :read, User, tenant_id: tenant_id
    can [:read, :update], JobProposal, tenant_id: tenant_id
    # Tenant admins (tenant_id set, no location) can soft-delete a
    # proposal in their own tenant. Restore still routes through SMAI
    # staff because the trash UI lives under /admin/trash.
    can :destroy, JobProposal, tenant_id: tenant_id if user.is_tenant_admin?
    can :read, JobType, tenant_id: tenant_id

    can [:read, :update], User, id: user.id
  end
end
