module Admin  
  class ModelLoadingService
    attr_reader :records, :pagination

    def initialize(searchable_model, params)
      @searchable_model = searchable_model
      # Assegura que params seja tratado corretamente, seja nil ou um ActionController::Parameters
      params = ActionController::Parameters.new({}).permit! if params.nil?
      @params = params.permit(:page, :length, order: {}, search: [:name]).to_h.deep_symbolize_keys
      @records = []
      @pagination = {}
    end    

    def call
      set_pagination_values
      set_default_order
      searched = search_records(@searchable_model)
      order_params = @params[:order] || set_default_order
      @records = searched.order(order_params)
                         .paginate(@params[:page], @params[:length])
      set_pagination_attributes(searched.count)
    end

    private

    def set_pagination_values
      @params[:page] = @params[:page].to_i
      @params[:length] = @params[:length].to_i
      @params[:page] = 1 if @params[:page] <= 0
      @params[:length] = @searchable_model.model::MAX_PER_PAGE if @params[:length] <= 0 || @params[:length] > @searchable_model.model::MAX_PER_PAGE
    end

    def search_records(searched)
      return searched unless @params.has_key?(:search)
      @params[:search].each do |key, value|
        searched = searched.where("#{key} ILIKE ?", "%#{value}%")
      end
      searched
    end

    def set_pagination_attributes(total_filtered)
      total_pages = (total_filtered.to_f / @params[:length]).ceil
      @pagination.merge!(page: @params[:page], length: @records.size, 
                         total: total_filtered, total_pages: total_pages,
                         order: @params[:order])
    end

    def set_default_order
      default_order = if @searchable_model.model.column_names.include?('name')
                        {name: :asc}
                      elsif @searchable_model.model.column_names.include?('code')
                        {code: :asc}
                      else
                        {}
                      end
      @params[:order] = default_order unless @params[:order].present? && valid_order_param?
      default_order
    end

    def valid_order_param?
      @params[:order].is_a?(Hash) && @params[:order].keys.all? do |key|
        [:name, :code].include?(key) && @searchable_model.model.column_names.include?(key.to_s)
      end
    end
  end
end