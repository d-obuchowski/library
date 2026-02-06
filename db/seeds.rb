# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

book_1 = Book.find_or_create_by!(author: "Author Seed", title: "Title Seed")
book_2 = Book.find_or_create_by!(author: "Another Author Seed", title: "Another Title Seed")
reader = Reader.find_or_create_by!(full_name: "Reader Seed", email: "reader_seed@example.com")

borrowing_1 = Borrowing.find_or_create_by!(book: book_1, reader: reader)
borrowing_1.update!(borrowed_at: 30.days.ago)

borrowing_2 = Borrowing.find_or_create_by!(book: book_2, reader: reader)
borrowing_2.update!(borrowed_at: 27.days.ago)
