module Admin::V1 
  class LoadsController < ApplicationController
    before_action :authorize
    before_action :set_load, only: [:show, :update, :destroy]
    
    def index
      @loading_service = Admin::ModelLoadingService.new(Load.all, searchable_params)
      @loading_service.call
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

    def set_load
      @load = Load.find(params[:id])
    end

    def searchable_params
      params.permit(:page, :length)
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