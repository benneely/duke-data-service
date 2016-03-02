class ProjectPolicy < ApplicationPolicy
  def create?
    true
  end

  def update?
    permission
  end

  def destroy?
    permission
  end

  class Scope < Scope
    def resolve
      scope.joins(:project_permissions).where(project_permissions: {user: user})
    end
  end
end
