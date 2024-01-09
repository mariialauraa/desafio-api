class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :login, presence: true, uniqueness: { case_sensitive: false }  
end