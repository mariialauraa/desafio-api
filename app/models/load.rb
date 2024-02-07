class Load < ApplicationRecord
  include Paginatable
  include LikeSearchable
  
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :delivery_date, presence: true, future_date: true
end
