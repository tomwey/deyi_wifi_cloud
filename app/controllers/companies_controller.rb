class CompaniesController < ApplicationController
  
  before_filter :require_member
  before_filter :check_member
  
  layout 'account'

  def create
    @company = Company.new(company_params)
    @company.member_id = current_member.id
    if @company.save
      current_member.update_attribute(:account_type, Member::ACCOUNT_TYPE_COMPANY)
      flash[:success] = "创建成功"
      redirect_to portal_root_path
    else
      flash[:error] = "创建失败"
      redirect_to new_company_path
    end
  end
  
  private
  def company_params
    params.require(:company).permit(:name, :address, :contact_name, :contact_number, :business_license_no, :business_license_image)
  end
end