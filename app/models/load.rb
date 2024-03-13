class Load < ApplicationRecord
  include Paginatable
  include LikeSearchable

  has_many :orders
  
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :delivery_date, presence: true, future_date: true
end
