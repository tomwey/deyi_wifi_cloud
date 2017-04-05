class MemberPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(parent_id: @user.id).order('created_at desc')
    end
  end
  
  permit [:read, :create, :update, :destroy]
  
  # def update?
  #   @user.company? and @user == @record.parent
  # end
  # 
  # def destroy?
  #   @user.company? and @user == @record.parent
  # end
  
end