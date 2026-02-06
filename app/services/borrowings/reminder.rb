module Borrowings
  class Reminder
    BORROWING_PERIOD_DAYS = 30

    def call
      send_three_days_left_reminders
      send_due_date_reminders
    end

    private

    def send_three_days_left_reminders
      borrowings_due_in_days(3).find_each do |borrowing|
        BorrowingMailer.due_soon(borrowing).deliver_later
      end
    end

    def send_due_date_reminders
      borrowings_due_in_days(0).find_each do |borrowing|
        BorrowingMailer.due_today(borrowing).deliver_later
      end
    end

    def borrowings_due_in_days(days)
      target_date = (BORROWING_PERIOD_DAYS - days).days.ago.to_date
      Borrowing.active.where(borrowed_at: target_date.beginning_of_day..target_date.end_of_day)
    end
  end
end
