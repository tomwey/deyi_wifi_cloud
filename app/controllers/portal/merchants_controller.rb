class Portal::MerchantsController < Portal::ApplicationController
  # before_action :set_merchant, only: [:show, :edit, :destroy]
  
  def index
    @page_header = "门店列表"
    @action = new_portal_merchant_path
    @merchants = Merchant.order('id desc').paginate page: params[:page], per_page: 30
  end
  
  # def show
  #   @page_header = "产品详情"
  # end
  
  def new
    @page_header = "新建门店"
    @merchant = Merchant.new
  end
  
  def create
    @merchant = Merchant.new(merchant_params)
    @merchant.owner_id = current_user.id
    if @merchant.save
      flash[:success] = '创建成功'
      redirect_to portal_merchants_url
    else
      # puts @product.errors.full_messages
      render :new
    end
  end
  
  def edit
    @page_header = "更新门店"
  end
  
  def update
    @merchant = current_user.merchants.find(params[:id])
    if @merchant.update(merchant_params)
      flash[:success] = '更新成功'
      redirect_to portal_merchants_url
    else
      render :edit
    end
  end
  
  def destroy
    @merchant = current_user.merchants.find_by(params[:id])
    @merchant.destroy
    flash[:success] = '删除成功'
    redirect_to portal_merchants_url
  end
  
  private
  
  def merchant_params
    params.require(:merchant).permit(:name, :address, :mobile, :memo)
  end
end