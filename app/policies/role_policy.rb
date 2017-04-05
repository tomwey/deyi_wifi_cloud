class RolePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(owner_id: @user.id)
    end
  end
  
  permit [:read, :create, :update, :destroy]
  
  # def update?
  #   @user.company? and @user == @record.member
  # end
  # 
  # def destroy?
  #   @user.company? and @user == @record.member
  # end
  
end