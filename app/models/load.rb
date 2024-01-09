class Load < ApplicationRecord
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :delivery_date, presence: true
end
