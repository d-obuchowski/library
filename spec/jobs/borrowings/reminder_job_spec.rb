# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Borrowings::ReminderJob, type: :job do
  describe '#perform' do
    let(:reminder_service) { instance_double(Borrowings::Reminder, call: true) }

    before do
      allow(Borrowings::Reminder).to receive(:new).and_return(reminder_service)
    end

    it 'calls the Borrowings::Reminder service' do
      described_class.perform_now

      expect(reminder_service).to have_received(:call)
    end
  end
end
