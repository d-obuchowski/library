FactoryBot.define do
  factory :borrowing do
    association :book
    association :reader
    borrowed_at { Time.current }
    returned_at { nil }
  end
end
