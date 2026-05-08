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
    can :read, JobType, tenant_id: tenant_id

    can [:read, :update], User, id: user.id
  end
end
