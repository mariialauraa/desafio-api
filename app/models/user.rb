class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :login, uniqueness: true
end