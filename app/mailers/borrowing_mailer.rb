class BorrowingMailer < ApplicationMailer
  def due_soon(borrowing)
    @borrowing = borrowing
    @reader = borrowing.reader
    @book = borrowing.book
    @due_date = Date.current + 3.days

    mail(
      to: @reader.email,
      subject: "Three Days Left Before Due Date: #{@book.title}"
    )
  end

  def due_today(borrowing)
    @borrowing = borrowing
    @reader = borrowing.reader
    @book = borrowing.book
    @due_date = Date.current

    mail(
      to: @reader.email,
      subject: "Book Due Today: #{@book.title}"
    )
  end
end
