FactoryBot.define do
  factory :reader do
   sequence(:full_name) { |n| "reader_#{n}" }
   sequence(:email) { |n| "email_#{n}@example.com" }
  end
end
