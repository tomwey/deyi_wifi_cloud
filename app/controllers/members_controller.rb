class MembersController < ApplicationController
  
  before_filter :require_member
  before_filter :check_member
  
  layout :layout_by_action
  def layout_by_action
    if %w(more_profile studio company).include?(action_name)
      "account"
    elsif %w(new create).include?(action_name)
      "account"
    end
  end
  
  def more_profile
    @action = "完善资料"
  end
  
  def studio
    @action = "工作室"
    @studio = Studio.new
  end
  
  def company
    @action = "影楼"
    @company = Company.new
  end
end