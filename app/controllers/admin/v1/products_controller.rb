module Admin::V1
  class ProductsController < ApplicationController
    before_action :authorize
    before_action :load_product, only: [:show, :update, :destroy]

    def index
      @products = load_products
    end
    
    def create
      @product = Product.new
      @product.attributes = product_params 
      save_product!  
    end

    def show; end

    def update      
      @product.attributes = product_params
      save_product!
    end

    def destroy      
      @product.destroy!
    rescue
      render_error(fields: @product.errors.messages)
    end

    private

    def load_product
      @product = Product.find(params[:id])
    end

    def load_products
      permitted = params.permit({ search: :name }, { order: {} }, :page, :length)
      Admin::ModelLoadingService.new(Product.all, permitted).call
    end

    def product_params
      return {} unless params.has_key?(:product)
      params.require(:product).permit(:name, :ballast)
    end

    def save_product!
      @product.save!
      render :show
    rescue
      render_error(fields: @product.errors.messages)
    end
  end
end

