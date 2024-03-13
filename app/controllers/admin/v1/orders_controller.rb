module Admin::V1 
    class OrdersController < ApplicationController
      before_action :authorize
      before_action :set_order, only: [:show, :update, :destroy]
      
      def index
        @loading_service = Admin::ModelLoadingService.new(Order.all, searchable_params)
        @loading_service.call
      end
  
      def create
        @order = Order.new
        @order.attributes = order_params 
        save_order!  
      end
  
      def show; end
  
      def update      
        @order.attributes = order_params
        save_order!
      end
  
      def destroy      
        @order.destroy!
      rescue
        render_error(fields: @order.errors.messages)
      end
  
      private
  
      def set_order
        @order = Order.find_by_id(params[:id])
  
        if @order.nil?
          render(status: 404, json: { error: "Lista não encontrada." })
        end
      end
  
      def searchable_params
        params.permit(:page, :length)
      end
  
      def order_params
        return {} unless params.has_key?(:order)
        params.require(:order).permit(:code, :bay, :load_id)
      end
  
      def save_order!
        @order.save!
        render :show
      rescue
        render_error(fields: @order.errors.messages)
      end    
    end
end