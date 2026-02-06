# frozen_string_literal: true

# Configure Solid Queue to use the queue database
Rails.application.config.after_initialize do
  if defined?(SolidQueue)
    SolidQueue::Record.connects_to database: { writing: :queue, reading: :queue }
  end
end
