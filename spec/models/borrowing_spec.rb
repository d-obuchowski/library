require 'rails_helper'

RSpec.describe Borrowing, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:book) }
    it { is_expected.to belong_to(:reader) }
  end

  describe 'validations' do
    let(:book) { create(:book) }
    subject { build(:borrowing, book: book) }

    it { is_expected.to validate_presence_of(:borrowed_at) }

    context 'when a book was already borrowed' do
      let!(:borrowing_2) { create(:borrowing, book: book) }
      it 'raises a validation error' do
        expect(subject).not_to be_valid
        expect(subject.errors[:book]).to include("is currently borrowed and not available")
      end
    end
  end

  describe '#active?' do
    let(:borrowing) { build(:borrowing, returned_at: Time.current) }
    it 'returns false' do
      expect(borrowing.active?).to be false
    end
  end
end
