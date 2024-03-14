module Admin::V1 
    class OrderProductsController < ApplicationController
      before_action :authorize
      before_action :set_order_product, only: [:show, :update, :destroy]
      
      def index
        @order_products = OrderProduct.all
      end
  
      def create
        @order_product = OrderProduct.new
        @order_product.attributes = order_product_params 
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