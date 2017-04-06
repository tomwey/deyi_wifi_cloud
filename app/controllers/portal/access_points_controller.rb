class Portal::AccessPointsController < Portal::ApplicationController
  before_action :set_ap, only: [:show, :edit, :destroy]
  
  def index
    @page_header = "设备列表"
    @action = new_portal_access_point_path
    @access_points = AccessPoint.order('id desc').paginate page: params[:page], per_page: 30
  end
  
  # def show
  #   @page_header = "产品详情"
  # end
  def show
    @page_header = "设备详情"
  end
  
  def new
    @page_header = "新建设备"
    @access_point = AccessPoint.new
  end
  
  def create
    @access_point = AccessPoint.new(access_point_params)
    
    @shop = Merchant.find_by(id: params[:access_point][:merchant_id])
    if @shop.blank? or @shop.owner.blank? or @shop.owner != current_user
      flash[:error] = '非法操作'
      redirect_to new_portal_access_point_path
      return
    end
    
    if @access_point.save
      flash[:success] = '创建成功'
      redirect_to portal_access_points_url
    else
      # puts @product.errors.full_messages
      render :new
    end
  end
  
  def edit
    @page_header = "更新设备"
  end
  
  def update
    @access_point = AccessPoint.find(params[:id])
    if @access_point.merchant.blank? or @access_point.merchant.owner.blank? or @access_point.merchant.owner != current_user
      flash[:error] = '非法操作'
      redirect_to portal_access_points_url
      return
    end
    if @access_point.update(access_point_params)
      flash[:success] = '更新成功'
      redirect_to portal_access_points_url
    else
      render :edit
    end
  end
  
  def destroy
    @access_point.destroy
    flash[:success] = '删除成功'
    redirect_to portal_access_points_url
  end
  
  private
  
  def set_ap
    @access_point = AccessPoint.find_by(ap_id: params[:id])
    if @access_point.blank?
      flash[:error] = '没找到设备'
      rediret_to portal_access_points_url
      return
    end
    
    if @access_point.merchant.blank? or @access_point.merchant.owner != current_user
      flash[:error] = '非法操作'
      rediret_to portal_access_points_url
      return
    end
  end
  
  def access_point_params
    params.require(:access_point).permit(:ssid, :gw_mac, :gw_address, :gw_port, :merchant_id)
  end
end