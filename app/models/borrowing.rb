class Borrowing < ApplicationRecord
  belongs_to :reader
  belongs_to :book

  validates :borrowed_at, presence: true
  validate :book_must_be_available, on: :create

  scope :active, -> { where(returned_at: nil) }

  def active?
    returned_at.nil?
  end

  private

  def book_must_be_available
    return unless book.present? && book.borrowings.active.exists?

    errors.add(:book, "is currently borrowed and not available")
  end
end
