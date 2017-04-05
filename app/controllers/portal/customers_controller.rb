class Portal::CustomersController < Portal::ApplicationController
  before_action :set_customer, only: [:show, :edit, :destroy]
  
  def index
    authorize Customer
    @page_header = "客户列表"
    @action = new_portal_customer_path
    @customers = policy_scope(Customer).paginate page: params[:page], per_page: 30
  end
  
  def show
    @page_header = "客户详情"
  end
  
  def new
    @page_header = "新建客户"
    @customer = Customer.new
    authorize @customer
  end
  
  def create
    @customer = Customer.new(customer_params)
    authorize @customer
    @customer.owner_id = current_member.account.id
    if @customer.save
      flash[:success] = '创建成功'
      redirect_to portal_customers_url
    else
      # puts @product.errors.full_messages
      render :new
    end
  end
  
  def edit
    @page_header = "更新客户资料"
  end
  
  def update
    @customer = Customer.find_by(owner_id: current_member.account.id, id: params[:id])
    
    if @customer.blank?
      flash[:alert] = '记录不存在'
      redirect_to portal_customers_url
      return
    end
    
    authorize @customer
    
    if @customer.update(customer_params)
      flash[:success] = '更新成功'
      redirect_to portal_customers_url
    else
      render :edit
    end
  end
  
  def destroy
    @customer.destroy
    flash[:success] = '删除成功'
    redirect_to portal_customers_url
  end
  
  private
  def set_customer    
    @customer = Customer.find_by(owner_id: current_member.account.id, o_id: params[:id])
    
    if @customer.blank?
      flash[:alert] = '记录不存在'
      redirect_to portal_customers_url
      return
    end
    
    authorize @customer
  end
  
  def customer_params
    params.require(:customer).permit(:avatar, :nickname, :realname, :mobile, :address)
  end
end