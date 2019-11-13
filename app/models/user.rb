class User < ApplicationRecord
    has_secure_password
    validates :email, uniqueness: true
    validates :username, uniqueness: true
    has_one :shelf
    has_many :shelf_books, through: :shelf
    has_many :books, through: :shelf_books

    def public_shelf
        self.shelf_books.where("shelf_type = ?", "2").map do |shelf_book|
            shelf_book.book
        end
    end

    def private_shelf
        self.shelf_books.where("shelf_type = ?", "1").map do |shelf_book|
            shelf_book.book
        end
    end

    def desired_shelf
        self.shelf_books.where("shelf_type = ?", "0").map do |shelf_book|
            shelf_book.book
        end
    end

    # Takes in book classes and user class
    def swap_book(your_book, other_user, their_book)
        if public_shelf.include? book
            your_shelf_book = ShelfBook.all.detect do |shelf_book| 
                shelf_id == self.shelf.id and book_id == your_book.id
            end

            your_shelf_book.shelf_id = other_user.shelf.id
            your_shelf_book.shelf_type = 1
            your_shelf_book.save

            their_shelf_book = ShelfBook.all.detect do |shelf_book| 
                shelf_id == other_user.shelf.id and book_id == your_book.id
            end

            their_shelf_book.shelf_id = self.shelf.id
            their_shelf_book.shelf_type = 1
            their_shelf_book.save

        else
            nil
        end
    end
end
