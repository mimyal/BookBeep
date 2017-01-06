require File.expand_path("../../test_helper", __FILE__)
# require 'test_helper'

class LibraryItemTest < ActiveSupport::TestCase
  test "should find model tests" do
    assert true
  end

  test "get_media: Getting a non-existing item from the database should return nil" do
      VCR.use_cassette("book-response") do
        isbn = '91-1-927571-4'
        actual_book = LibraryItem.get_media(isbn)
        assert_nil(actual_book)
      end
    end
  test "get_media: Getting an existing item from the database should return the correct item" do
    skip #until create tests are passing
  end
  test "add_media: Adding a new item to the Library Table should work" do
    isbn = 9119275714
    title = 'Sent i november'
    LibraryItem.add_media(isbn, title)
    # test count up by one
    # test isbn and title on retrieval - chicken and egg
    assert false
  end

end
