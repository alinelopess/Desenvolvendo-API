require "sinatra"
require "sinatra/namespace"
require "mongoid"

# DB Connect
Mongoid.load! "mongoid.yml"

class Book
    include Mongoid::Document

    field :title, type: String
    field :author, type: String
    field :isbn, type: String
end

get "/" do
    content_type "application/json"
    return { message: "Welcome to Book API" }.to_json
end

namespace "/books" do
    before do
        content_type "application/json"
    end

    get do
        return Book.all.to_json
    end

    get "/:book_id" do |book_id|
        book = Book.where(_id: book_id).first

        return book.to_json
    end    

    post do
        begin
            payload = JSON.parse(request.body.read)

            puts payload ["title"]
            found = Book.where(isbn: payload['isbn']).first

            if found
                halt 409, { error: "Duplicated ISBN"}
            end

            book = Book.new(payload)
            book.save
            status 201
            return book.to_json
        rescue => exception
            puts exception
            halt 400, { error: exception }.to_json
        end
    end
end