class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.is_admin
      can :manage, :all
      return
    end

    tenant_id = user.tenant_id
    org_ids = user.organizational_members.pluck(:organization_id)

    can :read, Tenant, id: tenant_id if tenant_id

    can :read, Organization, tenant_id: tenant_id, id: org_ids
    can :read, OrganizationalMember, organization_id: org_ids
    can :read, User, tenant_id: tenant_id, organizational_members: { organization_id: org_ids }
    can [:read, :update], JobProposal, tenant_id: tenant_id, organization_id: org_ids
    can :read, JobType, tenant_id: tenant_id

    can [:read, :update], User, id: user.id
  end
end
