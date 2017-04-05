class Portal::ProductsController < Portal::ApplicationController
  before_action :set_product, only: [:show, :edit, :destroy]
  
  def index
    authorize Product
    @page_header = "产品列表"
    @action = new_portal_product_path
    @products = policy_scope(Product).paginate page: params[:page], per_page: 30
  end
  
  def show
    @page_header = "产品详情"
  end
  
  def new
    @page_header = "新建产品"
    @product = Product.new
    authorize @product
  end
  
  def create
    @product = Product.new(product_products)
    authorize @product
    @product.owner_id = current_member.admin? ? current_member.id : current_member.parent_id
    if @product.save
      flash[:success] = '创建成功'
      redirect_to portal_products_url
    else
      # puts @product.errors.full_messages
      render :new
    end
  end
  
  def edit
    @page_header = "更新产品"
  end
  
  def update
    if current_member.admin?
      @product = Product.find_by(owner_id: current_member.id, id: params[:id])
    else
      @product = Product.find_by(owner_id: current_member.parent_id, id: params[:id])
    end
    
    if @product.blank?
      flash[:alert] = '记录不存在'
      redirect_to portal_products_url
      return
    end
    
    authorize @product
    
    if @product.update(product_products)
      flash[:success] = '更新成功'
      redirect_to portal_products_url
    else
      render :edit
    end
  end
  
  def destroy
    @product.destroy
    flash[:success] = '删除成功'
    redirect_to portal_products_url
  end
  
  private
  def set_product
    if current_member.admin?
      @product = Product.find_by(owner_id: current_member.id, pid: params[:id])
    else
      @product = Product.find_by(owner_id: current_member.parent_id, pid: params[:id])
    end
    
    if @product.blank?
      flash[:alert] = '记录不存在'
      redirect_to portal_products_url
      return
    end
    
    authorize @product
  end
  
  def product_products
    params.require(:product).permit(:name, :intro, :body, :image, :stock, :sort, :market_price, :discount_price, :photos_quantity)
  end
end