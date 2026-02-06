# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Books::StatusUpdater, type: :service do
  let(:current_time) { Time.new(2024, 1, 1, 12, 0, 0) }

  before do
    allow(Time).to receive(:current).and_return(current_time)
  end
  describe '#borrowed!' do
    let(:book) { create(:book, status: :available) }
    let(:reader_params) { { full_name: 'John Doe', email: 'john.doe@example.com' } }

    subject { described_class.new(book, reader_params).borrowed! }

    context 'when reader params are valid' do
      it 'updates the book status to borrowed, creates a borrowing and a reader' do
        result = subject

        expect(result[:success]).to be true
        expect(result[:book].status).to eq('borrowed')
        expect(book.borrowings.count).to eq(1)

        borrowing = book.borrowings.first
        reader = borrowing.reader

        expect(borrowing.borrowed_at).to eq(current_time)
        expect(reader.full_name).to eq('John Doe')
        expect(reader.email).to eq('john.doe@example.com')
      end

      context 'when reader already exists' do
        let!(:existing_reader) { create(:reader, full_name: 'John Doe', email: 'john.doe@example.com') }

        it 'uses the existing reader' do
          subject

          expect(book.borrowings.first.reader.id).to eq(existing_reader.id)
        end
      end
    end

    context 'when reader params are invalid' do
      let(:reader_params) { { full_name: '', email: 'invalid_email' } }

      it 'returns an error result' do
        result = subject

        expect(result[:success]).to be false
        expect(result[:errors]).to include(:full_name, :email)
        expect(book.status).to eq('available')
        expect(book.borrowings.count).to eq(0)
      end
    end
  end

  describe '#available!' do
    let(:book) { create(:book, status: :borrowed) }
    let!(:borrowing) { create(:borrowing, book:) }

    subject { described_class.new(book).available! }

    it 'updates the book status to available and sets returned_at on the borrowing' do
      result = subject

      expect(result[:success]).to be true
      expect(result[:book].status).to eq('available')
      expect(borrowing.reload.returned_at).to eq(current_time)
    end
  end
end
