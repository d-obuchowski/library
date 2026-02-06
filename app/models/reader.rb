class Reader < ApplicationRecord
  include UniqueNumberGenerator

  has_many :borrowings

  validates :card_number, presence: true, uniqueness: true
  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :assign_card_number, on: :create

  private

  def assign_card_number
    self.card_number = generates_unique_number(:card_number)
  end
end
