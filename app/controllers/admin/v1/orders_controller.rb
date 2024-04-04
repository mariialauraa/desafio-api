module Admin::V1 
    class OrdersController < ApplicationController
      before_action :authorize
      before_action :set_order, only: [:show, :update, :destroy]
      
      def index
        if params[:load_id].present?
          load = Load.find_by_id(params[:load_id])
          if load.nil?
            render(status: 404, json: { error: "Carga não encontrada." })
            return
          end
          @loading_service = Admin::ModelLoadingService.new(load.orders, searchable_params)
        else
          @loading_service = Admin::ModelLoadingService.new(Order.all, searchable_params)
        end
        @loading_service.call
      end
  
      def create
        @load = Load.find(params[:load_id])
        @order = @load.orders.build(order_params)
        save_order!
      end      
  
      def show; end
  
      def update      
        @order.attributes = order_params
        save_order!
      end
  
      def destroy
        ActiveRecord::Base.transaction do
          @order.order_products.each(&:destroy!)
          @order.destroy!
        end
      rescue ActiveRecord::RecordNotDestroyed
        render_error(fields: { order: ['não pode ser deletado porque possui produtos associados que não puderam ser removidos.'] }, status: :unprocessable_entity)
      end

      def list_order_products
        @order_products = @order&.order_products || []
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