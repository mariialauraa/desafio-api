module Admin::V1 
  class OrderProductsController < ApplicationController
    before_action :authorize
    before_action :set_order_product, only: [:show, :update, :destroy]
      
    def index
      if params[:order_id].present?
        @order_products = OrderProduct.includes(:product).where(order_id: params[:order_id])
          
        if @order_products.empty?
          render json: { error: 'Produtos da lista específica não foram encontrados.' }, status: :not_found
        else
          render json: @order_products.map { |order_product|
            order_product.as_json(include: { product: { only: [:id, :name] } }, except: [:product_id, :created_at, :updated_at])
          }
        end
      else
        render json: { error: 'ID da ordem não fornecido.' }, status: :bad_request
      end
    end                         
  
    def create
      @order = Order.find(params[:order_id]) 
      @order_product = @order.order_products.build(order_product_params)       
      save_order_product! 
    end
  
    def show; end
  
    def update      
      @order_product.attributes = order_product_params
      save_order_product!
    end
  
    def destroy      
      @order_product.destroy!
    rescue
      render_error(fields: @order_product.errors.messages)
    end
  
    private
  
    def set_order_product
      @order_product = OrderProduct.find_by_id(params[:id])
  
      if @order_product.nil?
        render(status: 404, json: { error: "Produto da lista não encontrado." })
      end
    end
  
    def order_product_params
      return {} unless params.has_key?(:order_product)
      params.require(:order_product).permit(:order_id, :product_id, :quantity, :box)
    end
  
    def save_order_product!
      @order_product.save!
      render :show
    rescue
      render_error(fields: @order_product.errors.messages)
    end    
  end
end