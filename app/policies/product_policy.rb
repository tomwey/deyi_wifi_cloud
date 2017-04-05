class ProductPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      if @user.parent_id.blank?
        scope.where(owner_id: @user.id).order('created_at desc')
      else
        parent = @user.parent
        scope.where(owner_id: parent.id).order('created_at desc')
      end
    end
  end
  
  permit [:read, :create, :update, :destroy]
  
  # def update?
  #   @user.admin? and @user == @record.member
  # end
  # 
  # def destroy?
  #   @user.admin? and @user == @record.member
  # end
  
end