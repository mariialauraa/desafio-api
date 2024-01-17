module Admin  
  class ModelLoadingService
    attr_reader :records, :pagination

    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params || {}
      @records = []
      @pagination = { page: @params[:page].to_i, length: @params[:length].to_i }
    end

    def call
      fix_pagination_values
      result = @searchable_model      
      result = result.search_by_name(@params.dig(:search, :name)) if result.respond_to?(:search_by_name)      
      result = result.order(@params[:order].to_h) if result.respond_to?(:order)      
      @records = result.paginate(@pagination[:page], @pagination[:length]) 
 
      total_pages = (result.count / @pagination[:length].to_f).ceil
      @pagination.merge!(total: result.count, total_pages: total_pages)
 
      @records
    end

    private

    def fix_pagination_values
      @pagination[:page] = @searchable_model.model::DEFAULT_PAGE if @pagination[:page] <= 0
      @pagination[:length] = @searchable_model.model::MAX_PER_PAGE if @pagination[:length] <= 0
    end
  end
end