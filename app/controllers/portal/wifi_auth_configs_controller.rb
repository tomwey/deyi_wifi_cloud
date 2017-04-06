class Portal::WifiAuthConfigsController < Portal::ApplicationController
  
  def edit
    @page_header = '认证配置'
    @config = current_user.auth_config
    if @config.blank?
      @config = WifiAuthConfig.create!(user_id: current_user.id)
    end
  end
  
  def update
     @config = current_user.auth_config
     if @config.update(config_params)
       flash[:success] = '保存成功'
       redirect_to portal_manage_auth_config_path
     else
       render :edit
     end
  end
  
  private
  def config_params
    params.require(:wifi_auth_config).permit(:auth_type, :wifi_length, :auto_jump, :countdown, :auth_click_button, :https_auth_support, :allow_websites, :allow_macs, :not_allow_macs)
  end
  
end