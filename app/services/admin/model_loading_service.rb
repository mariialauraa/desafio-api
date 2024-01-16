module Admin  
  class ModelLoadingService

    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params
      @params ||= {}
    end

    def call
      result = @searchable_model
      result = result.search_by_name(@params.dig(:search, :name)) if @searchable_model.respond_to?(:search_by_name)
      result = result.order(@params[:order].to_h) if @searchable_model.respond_to?(:order)
      result = result.paginate(@params[:page].to_i, @params[:length].to_i)
      result
    end
  end
end