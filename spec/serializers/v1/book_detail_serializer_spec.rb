# frozen_string_literal: true

require 'rails_helper'
RSpec.describe V1::BookDetailSerializer, type: :serializer do
  let(:book) { create(:book, title: "1984", author: "George Orwell") }
  let!(:borrowing) { create(:borrowing, book: book, borrowed_at: time, returned_at: time) }
  let(:serializer) { described_class.new(book) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:serialized_json) { JSON.parse(serialization.to_json) }
  let(:time) { Time.utc(2020, 8, 30, 19, 0, 20) }

  describe 'attributes' do
    it 'includes the expected attributes' do
      expect(serialized_json['id']).to eq(book.id)
      expect(serialized_json['title']).to eq("1984")
      expect(serialized_json['author']).to eq("George Orwell")
      expect(serialized_json['status']).to eq(book.status)
      expect(serialized_json['serial_number']).to eq(book.serial_number)
      expect(serialized_json['borrowings']).to eq([
        {
          'borrowed_at' => time.iso8601(3),
          'returned_at' => time.iso8601(3),
          'reader' => {
            'card_number' => borrowing.reader.card_number,
            'full_name' => borrowing.reader.full_name,
            'email' => borrowing.reader.email
          }
        }
      ])
    end
  end
end
