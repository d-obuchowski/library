module Books
  class StatusUpdater
    def initialize(book, reader_params = {})
      @book = book
      @reader_params = reader_params
    end

    def borrowed!
      execute_with_result do
        with_transaction do
          reader = find_or_create_reader
          create_borrowing(reader)
          @book.borrowed!
        end
      end
    end

    def available!
      execute_with_result do
        with_transaction do
          update_borrowing
          @book.available!
        end
      end
    end

    private

    def execute_with_result
      yield
      success_result
    rescue ActiveRecord::RecordInvalid => e
      error_result(e.record.errors)
    end

    def with_transaction
      ActiveRecord::Base.transaction { yield }
    end

    def find_or_create_reader
      Reader.find_or_create_by!(@reader_params)
    end

    def create_borrowing(reader)
      @book.borrowings.create!(reader: reader, borrowed_at: Time.current)
    end

    def update_borrowing
      return unless borrowing

      borrowing.update!(returned_at: Time.current)
    end

    def borrowing
      @book.borrowings.find_by(returned_at: nil)
    end

    def success_result
      { success: true, book: @book }
    end

    def error_result(errors)
      { success: false, errors: errors }
    end
  end
end
