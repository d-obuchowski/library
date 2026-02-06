module V1
  class BorrowingSerializer < ActiveModel::Serializer
    attributes :borrowed_at, :returned_at, :reader

    def reader
      V1::ReaderSerializer.new(object.reader).attributes
    end
  end
end
