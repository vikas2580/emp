class Employee < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true 
  validates :phone_numbers, presence: true
  validates :doj, presence: true
  validates :salary, presence: true
end
