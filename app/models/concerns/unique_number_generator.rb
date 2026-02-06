module UniqueNumberGenerator
  extend ActiveSupport::Concern

  included do
    def generates_unique_number(attribute)
      loop do
        number = rand(100_000..999_999)
        break number unless self.class.exists?(attribute => number)
      end
    end
  end
end
