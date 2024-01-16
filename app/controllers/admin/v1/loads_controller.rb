module Admin::V1 
  class LoadsController < ApplicationController
    before_action :authorize
    before_action :load_load, only: [:show, :update, :destroy]
    
    def index
      @loads = load_loads
    end

    def create
      @load = Load.new
      @load.attributes = load_params 
      save_load!  
    end

    def show; end

    def update      
      @load.attributes = load_params
      save_load!
    end

    def destroy      
      @load.destroy!
    rescue
      render_error(fields: @load.errors.messages)
    end

    private

    def load_load
      @load = Load.find(params[:id])
    end

    def load_loads
      permitted = params.permit(:page, :length)
      Admin::ModelLoadingService.new(Load.all, permitted).call
    end

    def load_params
      return {} unless params.has_key?(:load)
      params.require(:load).permit(:code, :delivery_date)
    end

    def save_load!
      @load.save!
      render :show
    rescue
      render_error(fields: @load.errors.messages)
    end    
  end
end