class StudiosController < ApplicationController
  
  before_filter :require_member
  before_filter :check_member
  
  layout 'account'

  def create
    @studio = Studio.new(studio_params)
    @studio.member_id = current_member.id
    
    if @studio.save
      current_member.update_attribute(:account_type, Member::ACCOUNT_TYPE_STUDIO)
      flash[:success] = "创建成功"
      redirect_to portal_root_path
    else
      flash[:error] = "创建失败"
      redirect_to new_studio_path
    end
  end
  
  private
  def studio_params
    params.require(:studio).permit(:name, :address, :contact_name, :contact_number)
  end
  
end