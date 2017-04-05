class Portal::RolesController < Portal::ApplicationController
  
  def index
    @page_header = "角色列表"
    authorize Role
    @action = new_portal_role_path
    @roles = policy_scope(Role).paginate page: params[:page], per_page: 30
  end
  
  def new
    @page_header = "新建产品"
    @role = Role.new
    authorize @role
  end
  
  def create
    @role = Role.new(role_params)
    authorize @role
    @role.owner_id = current_member.id
    puts @role.name
    if @role.save
      flash[:success] = '创建成功'
      redirect_to portal_roles_url
    else
      # flash.now.alert = @role.errors.full_messages.join(',')
      # puts @role.errors.full_messages
      render :new
    end
  end
  
  def edit
    @page_header = "更新角色"
    
    @role = Role.find_by(id: params[:id], owner_id: current_member.id)
    if @role.blank?
      flash[:alert] = '记录不存在'
      redirect_to portal_roles_path
      return
    end
    
    # @role = Role.find(params[:id])
    authorize @role
  end
  
  def update
    # @role = Role.find(params[:id])
    @role = Role.find_by(id: params[:id], owner_id: current_member.id)
    if @role.blank?
      flash[:alert] = '记录不存在'
      redirect_to portal_roles_path
      return
    end
    
    authorize @role
    if @role.update(role_params)
      flash[:success] = '更新成功'
      redirect_to portal_roles_url
    else
      render :edit
    end
  end
  
  def destroy
    # @role = Role.find(params[:id])
    @role = Role.find_by(id: params[:id], owner_id: current_member.id)
    if @role.blank?
      flash[:alert] = '记录不存在'
      redirect_to portal_roles_path
      return
    end
    
    authorize @role
    @role.destroy
    redirect_to portal_roles_url
  end
  
  private
  def role_params
    role_params = params.require(:role).permit(:name, permissions: [])
    role_params[:permissions] = build_permissions(role_params[:permissions] || [])
    role_params
  end
  
  def build_permissions(permissions)
    # puts permissions
    parse_permissions(permissions).collect do |permission|
      if @role.nil?
        Permission.new(permission)
      else
        @role.permissions.find_or_initialize_by(permission)
      end
    end
  end
  
  def parse_permissions(permissions)
    permissions.collect do |permission|
      action, resource = permission.split('#', 2)
      { action: action, resource: resource }
    end
  end
  
end