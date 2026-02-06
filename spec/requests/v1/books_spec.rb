# frozen_string_literal: true

require 'rails_helper'
RSpec.describe "V1::Books", type: :request do
  let_it_be(:book) { create(:book) }
  describe "PATCH /v1/books/:id/borrow" do
    let(:status_updater) { instance_double(Books::StatusUpdater, borrowed!: result) }

    before do
      allow(Books::StatusUpdater).to receive(:new).and_return(status_updater)
    end

    context "with valid reader parameters" do
      let(:reader_params) { { full_name: "John Doe", email: "john.doe@example.com" } }
      let(:result) { { success: true, book: book } }

      it "borrows the book successfully" do
        patch borrow_v1_book_path(book), params: { reader: reader_params }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid reader parameters' do
      let(:reader_params) { { full_name: "", email: "invalid-email" } }
      let(:errors) { { full_name: [ "can't be blank" ] } }
      let(:result) { { success: false, errors: errors } }

      it "returns unprocessable entity status with errors" do
        patch borrow_v1_book_path(book), params: { reader: reader_params }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to eq(errors.as_json)
      end
    end
  end

  describe "PATCH /v1/books/:id/return" do
    let(:status_updater) { instance_double(Books::StatusUpdater, available!: result) }

    before do
      allow(Books::StatusUpdater).to receive(:new).and_return(status_updater)
    end

    context "when returning the book is successful" do
      let(:result) { { success: true, book: book } }

      it "returns ok status" do
        patch return_v1_book_path(book)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when returning the book fails" do
      let(:errors) { { base: [ "some update error" ] } }
      let(:result) { { success: false, errors: errors } }

      it "returns unprocessable entity status with errors" do
        patch return_v1_book_path(book)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to eq(errors.as_json)
      end
    end
  end

  describe "GET /v1/books" do
    it "returns a list of books" do
      create_list(:book, 3)

      get v1_books_path

      expect(response).to have_http_status(:ok)
      expect(json_response.length).to eq(4)
    end
  end

  describe "GET /v1/books/:id" do
    it "returns the book details" do
      get v1_book_path(book)

      expect(response).to have_http_status(:ok)
      expect(json_response['id']).to eq(book.id)
    end
  end

  describe "POST /v1/books" do
    context "with valid parameters" do
      let(:valid_params) { { book: { title: "New Book", author: "Jane Smith" } } }

      it "creates a new book" do
        expect {
          post v1_books_path, params: valid_params
        }.to change(Book, :count).by(1)

        expect(response).to have_http_status(:created)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { book: { title: "", author: "" } } }

      it "returns unprocessable entity status with errors" do
        post v1_books_path, params: invalid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  describe "DELETE /v1/books/:id" do
    it "deletes the book" do
      delete v1_book_path(book)

      expect(response).to have_http_status(:no_content)
      expect(Book.exists?(book.id)).to be_falsey
    end
  end
end
