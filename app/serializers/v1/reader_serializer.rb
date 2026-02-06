module V1
  class ReaderSerializer < ActiveModel::Serializer
    attributes :full_name, :card_number, :email
  end
end
