module V1
  class BookSerializer < ActiveModel::Serializer
    attributes :id, :serial_number, :title, :author, :status
  end
end
