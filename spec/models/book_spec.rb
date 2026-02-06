require 'rails_helper'

RSpec.describe Book, type: :model do
  describe 'validations' do
    subject { create(:book) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:author) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:borrowings) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(available: 0, borrowed: 1) }
  end

  describe 'callbacks' do
    context 'before_validation on create' do
      it 'assigns a unique serial number' do
        book = create(:book)
        expect(book.serial_number).to be_present
      end
    end
  end
end
