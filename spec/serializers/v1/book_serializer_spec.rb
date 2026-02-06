# frozen_string_literal: true

require 'rails_helper'
RSpec.describe V1::BookSerializer, type: :serializer do
  let(:book) { create(:book, title: "The Great Gatsby", author: "F. Scott Fitzgerald") }
  let(:serializer) { described_class.new(book) }
  let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
  let(:serialized_json) { JSON.parse(serialization.to_json) }

  describe 'attributes' do
    it 'includes the expected attributes' do
      expect(serialized_json['id']).to eq(book.id)
      expect(serialized_json['title']).to eq("The Great Gatsby")
      expect(serialized_json['author']).to eq("F. Scott Fitzgerald")
      expect(serialized_json['status']).to eq(book.status)
      expect(serialized_json['serial_number']).to eq(book.serial_number)
    end
  end
end
