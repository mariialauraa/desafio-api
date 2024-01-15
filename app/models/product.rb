class Product < ApplicationRecord
  include NameSearchable
  include Paginatable

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :ballast, presence: true
end
