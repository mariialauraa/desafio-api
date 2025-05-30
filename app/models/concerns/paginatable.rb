module Paginatable
  extend ActiveSupport::Concern

  MAX_PER_PAGE = 10
  DEFAULT_PAGE = 1

  included do
    scope :paginate, -> (page, length) do
      page = page.present? && page > 0 ? page : DEFAULT_PAGE
      length = length.present? && length > 0 ? length : MAX_PER_PAGE
      # a partir de qual página vai pegar os resultados
      starts_at = (page - 1) * length
      # filtra os elementos
      limit(length).offset(starts_at) # offset é qual elemento ele tem q começar a contar
    end
  end
end