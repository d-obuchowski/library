class Book < ApplicationRecord
  include UniqueNumberGenerator

  has_many :borrowings, dependent: :destroy

  validates :serial_number, presence: true, uniqueness: true
  validates :title, presence: true
  validates :author, presence: true

  enum :status, { available: 0, borrowed: 1 }

  before_validation :assign_serial_number, on: :create

  private

  def assign_serial_number
    self.serial_number = generates_unique_number(:serial_number)
  end
end
