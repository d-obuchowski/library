module V1
  class BooksController < ApplicationController
    before_action :set_book, only: %i[show destroy borrow return]

    def index
      render json: Book.all, each_serializer: V1::BookSerializer
    end

    def show
      render json: @book, serializer: V1::BookDetailSerializer
    end

    def create
      book = Book.new(create_params)

      if book.save
        render json: book, serializer: V1::BookSerializer, status: :created
      else
        render json: { errors: book.errors }, status: :unprocessable_entity
      end
    end

    def borrow
      result = ::Books::StatusUpdater.new(@book, reader_params).borrowed!

      if result[:success]
        render json: @book, serializer: V1::BookDetailSerializer
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    end

    def return
      result = ::Books::StatusUpdater.new(@book).available!

      if result[:success]
        render json: @book, serializer: V1::BookDetailSerializer
      else
        render json: { errors: result[:errors] }, status: :unprocessable_entity
      end
    end

    def destroy
      @book.destroy
      head :no_content
    end

    private

    def set_book
      @book ||= Book.find(params[:id])
    end

    def create_params
      params.require(:book).permit(:title, :author)
    end

    def reader_params
      params.require(:reader).permit(:full_name, :email)
    end
  end
end
