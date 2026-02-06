# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BorrowingMailer, type: :mailer do
  describe '#due_soon' do
    subject { described_class.due_soon(borrowing)   }
    let(:borrowing) { create(:borrowing) }

    it 'renders the headers and body' do
      expect(subject.subject).to eq("Three Days Left Before Due Date: #{borrowing.book.title}")
      expect(subject.to).to eq([ borrowing.reader.email ])
    end
  end

  describe '#due_today' do
    subject { described_class.due_today(borrowing) }
    let(:borrowing) { create(:borrowing) }

    it 'renders the headers and body' do
      expect(subject.subject).to eq("Book Due Today: #{borrowing.book.title}")
      expect(subject.to).to eq([ borrowing.reader.email ])
    end
  end
end
