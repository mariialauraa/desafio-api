class Load < ApplicationRecord
  include Paginatable
  
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :delivery_date, presence: true, future_date: true
end
