module Borrowings
  class ReminderJob < ApplicationJob
    queue_as :default

    def perform
      Borrowings::Reminder.new.call
    end
  end
end
