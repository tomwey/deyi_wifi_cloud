module RolesHelper
  def resolve_checked(object, resource, attributes)
    return false if object.blank?
    
    action, target = params[resource][attributes].split('#', 2)
    return object.permissions.exists?(action: action, resource: target)
  end
end