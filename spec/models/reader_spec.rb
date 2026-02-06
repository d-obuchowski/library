require 'rails_helper'

RSpec.describe Reader, type: :model do
  describe 'validations' do
    subject { create(:reader) }

    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('john.doe@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid-email').for(:email) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:borrowings) }
  end

  describe 'callbacks' do
    context 'before_validation on create' do
      it 'assigns a unique card number' do
        reader = create(:reader)
        expect(reader.card_number).to be_present
      end
    end
  end
end
