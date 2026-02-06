# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Borrowings::Reminder, type: :service do
  let(:reader) { create(:reader) }
  let(:book_1) { create(:book) }
  let(:book_2) { create(:book) }
  let!(:borrowing_1) { create(:borrowing, reader:, book: book_1, borrowed_at: 30.days.ago) }
  let!(:borrowing_2) { create(:borrowing, reader:, book: book_2, borrowed_at: 27.days.ago) }
  let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

  before do
    allow(BorrowingMailer).to receive(:due_soon).and_return(mailer)
    allow(BorrowingMailer).to receive(:due_today).and_return(mailer)
    allow(mailer).to receive(:deliver_later)
  end

  subject { described_class.new.call }

  describe '#call' do
    it 'sends reminder emails to the reader' do
      subject

      expect(BorrowingMailer).to have_received(:due_soon).with(borrowing_2).once
      expect(BorrowingMailer).to have_received(:due_today).with(borrowing_1).once
    end
  end
end
