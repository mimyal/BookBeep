require 'test_helper'
#
class LibrisWrapperTest < ActiveSupport::TestCase

  test "#get_book returns a valid LibraryItem instance" do
#     VCR.use_cassette("book-response") do
    isbn = '91-1-927571-4'.tr('-', '').to_i
    actual_book = LibrisWrapper.get_book(isbn)
    assert_equal LibraryItem, actual_book.class
#     end
  end

  test "#get_book returns the correct book title" do
    isbn = '91-1-927571-4'.tr('-', '').to_i
    actual_book = LibrisWrapper.get_book(isbn)
    info = {
      'isbn' => 9119275714,
      'title' => 'Sent i november',
      'creator_surname' => 'Jansson',
      'creator_first_name' => 'Tove',
      'uri_id' => 'http://libris.kb.se/bib/7156259'
      }
    expected_book = LibraryItem.new(info)

    assert_equal actual_book.title, expected_book.title
  end

  test "get_book should set creator values to nil if not available" do
    # VCR.use_cassette("book-response2") do
    isbn = '91-7448-738-8'
    actual_book = LibrisWrapper.get_book(isbn)
    info = {
      'isbn' => 9174487388,
      'title' => 'Djurboken : en antologi',
      'uri_id' => 'http://libris.kb.se/bib/7642409'
    }
    expected_book = LibraryItem.new(info)

    assert_equal actual_book.title, expected_book.title
    assert_nil actual_book.creator_surname
    # end
  end

  test "get_book should return nil for unexpected isbn requests" do
#     VCR.use_cassette("response") do
      isbn = 'some-unknown-isbn'
      unexpected_response = LibrisWrapper.get_book(isbn)

      assert_nil unexpected_response
#     end
  end

end
