module V1
  class BookDetailSerializer < ActiveModel::Serializer
    attributes :id, :serial_number, :title, :author, :status

    has_many :borrowings, serializer: V1::BorrowingSerializer
  end
end
