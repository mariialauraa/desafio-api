class User < ApplicationRecord
  has_secure_password

  include NameSearchable
  include Paginatable
  
  validates :name, presence: true
  validates :login, presence: true, uniqueness: { case_sensitive: false }  
end