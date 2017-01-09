require File.expand_path("../../test_helper", __FILE__)
# require File.expand_path("../../helpers/dynamo_management", __FILE__)
# require 'test/test_helper'

class LibraryItemTest < ActiveSupport::TestCase

  setup do
    dynamodb = Aws::DynamoDB::Client.new( # ensure client is local and same as aws.rb
    region: "us-west-2",
    endpoint: "http://localhost:8000"
    )
    unless dynamodb.list_tables[:table_names].include?("LibraryItems")
      params = {
        table_name: "LibraryItems",
        key_schema: [ # COMPOSITE PRIMARY KEY
          {
            attribute_name: "isbn",
            key_type: "HASH"  #Partition key
          },
          {
            attribute_name: "datetime_created",
            key_type: "RANGE" #Sort key
          }
        ],
        attribute_definitions: [
          {
            attribute_name: "isbn",
            attribute_type: "N"
          },
          {
            attribute_name: "datetime_created",
            attribute_type: "N"
          },

        ],
        provisioned_throughput: {
          read_capacity_units: 1, #these are the one I allowed 1 only? Here it was 10
          write_capacity_units: 1
        }
      }

      begin
        result = dynamodb.create_table(params) # CREATE TABLE
        # puts "Created table. Status: " +
        result.table_description.table_status;

      rescue  Aws::DynamoDB::Errors::ServiceError => error
        puts "Unable to create table:"
        puts "#{error.message}"
      end
    else
      puts 'WHATS THE TABLE DOING UP?'
    end
    # puts dynamodb.list_tables
  end

  teardown do
    # puts '=========== TEAR DOWN THE TABLE ==========='
    dynamodb = Aws::DynamoDB::Client.new
    # puts dynamodb.list_tables

    table_name = "LibraryItems"

    begin
      dynamodb.delete_table({table_name: table_name})
      puts "Deleted table."

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to delete table:"
      puts "#{error.message}"
    end
    # puts dynamodb.list_tables

  end

  test "should find model tests" do
    assert true
  end

  test "#get_media Getting a non-existing item from the database should return nil" do
    isbn = 111111111
    book = LibraryItem.get_media(isbn)
    assert_nil(book)
  end

  test "#get_media should return the correct collection of items" do
    skip
    #ISBN TITLE LASTNAME QUERIES
  #     params = {
  #     isbn: 9119275714, # required
  #     }
  #
  #     book_results = LibraryItem.get_media(params) # it cant see my table: LibraryItems
  #     book_results.each { |book|
  #       assert(book.title, 'Sent i november')
  #     }
  end
  test "#add_media should add a new item to DynamoDB" do
    # First the new item info
    item = {
      isbn: 9119275714,
      title: 'Sent i november'
    }
    # Then run the creation method
    book = LibraryItem.add_media(item)
    assert_instance_of(LibraryItem, book)

    # Then set up a query
    query = {
      table_name: "LibraryItems",
      key_condition_expression: "isbn = :isbn",
      expression_attribute_values: {
        ":isbn" => item[:isbn]
      }
    }
    # RUN QUERY
    dynamodb = Aws::DynamoDB::Client.new
    begin
      results = dynamodb.query(query)
      puts "Query succeeded."
      # puts "THERE ARE ITEMS #{results.items.empty?}"
      assert_equal(results.items.empty?, false)
      puts results
      puts results.items
      results.items.each{|listing|
        puts "#{listing["isbn"]} #{listing["title"]} >>>>>>>>>>>>>>>>>>"
        assert(listing["isbn"], 9119275714000)
        assert(listing["title"], 'Sent i novemberXXX')
      }
      # puts "Count: #{results.count} Scanned Count: #{results.scanned_count}"

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      assert false
      puts "Unable to query table:"
      puts "#{error.message}"
    end


  end #test
  test "#add_media should add a new item to DynamoDB so table increase by one" do
    skip
  #   # First the new item info
  #   item = {
  #     isbn: 9119275714,
  #     title: 'Sent i november'
  #   }
  #   # Then run the creation method, and assert there are items created
  #   #     assert_difference(result.count, 1) do
  #   book = LibraryItem.add_media(item)
  #   assert_instance_of(LibraryItem, book)
  #   #       result = client.query(params)
  #   #       result.items.each { |item| # There might be more than one item with this isbn
  #   #         assert(item['isbn'], isbn)
  #   #       }
  #   #     end
  #
  #
  #   # Then set up a query
  #   query = {
  #     table_name: "LibraryItems",
  #     key_condition_expression: "isbn = :isbn",
  #     expression_attribute_values: {
  #       ":isbn" => item[:isbn]
  #     }
  #   }
  #   # RUN QUERY
  #   dynamodb = Aws::DynamoDB::Client.new
  #   begin
  #     results = dynamodb.query(query)
  #     puts "Query succeeded."
  #     assert_equal(results.items.empty?, false)
  #     results.items.each{|book|
        # puts "#{book["isbn"]} #{book["title"]} >>>>>>>>>>>>>>>>>>"
  #       assert(book["isbn"], 9119275714000)
  #       assert(book["title"], 'Sent i novemberXXX')
  #     }
  #
  #   rescue  Aws::DynamoDB::Errors::ServiceError => error
  #     assert false
  #     puts "Unable to query table:"
  #     puts "#{error.message}"
  #   end
  # end #test

  # Also in create ensure that no item is created with isbn/title different, if isbn exist, make sure the title is as before
  #
  #
  #     #could be more than one item in the real database with this isbn
  #     assert_difference(result.count, 1) do
  #       LibraryItem.add_media(isbn, title)
  #       result = client.query(params)
  #       result.items.each { |item| # There might be more than one item with this isbn
  #         assert(item['isbn'], isbn)
  #       }
  #     end
  #
  #     # test isbn and title on retrieval - chicken and egg
  #     assert false
end # test

  test "#add_media should check that a new item of the same isbn as an exsisting item has the same title" do
    skip
  end
  test "add_media: A new item to the Library Table should be found in the table" do
    # First the new item info
    item = {
      isbn: 9119275714,
      title: 'Sent i november'
    }
    # Then run the creation method
    book = LibraryItem.add_media(item)
    assert_instance_of(LibraryItem, book)

    # Then set up a query
    query = {
      table_name: "LibraryItems",
      key_condition_expression: "isbn = :isbn",
      expression_attribute_values: {
        ":isbn" => item[:isbn]
      }
    }
    # RUN QUERY
    dynamodb = Aws::DynamoDB::Client.new
    begin
      results = dynamodb.query(query)
      puts "Query succeeded."
      # puts "THERE ARE ITEMS #{results.items.empty?}"
      assert_equal(results.items.empty?, false)
      puts results
      puts results.items
      results.items.each{|book|
        puts "#{book["isbn"]} #{book["title"]} >>>>>>>>>>>>>>>>>>"
        assert(book["isbn"], 9119275714000)
        assert(book["title"], 'Sent i novemberXXX')
      }
      # puts "Count: #{results.count} Scanned Count: #{results.scanned_count}"

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      assert false
      puts "Unable to query table:"
      puts "#{error.message}"
    end


  end #test
  # #INPROGRESS
  #
  # Also in create ensure that no item is created with isbn/title different, if isbn exist, make sure the title is as before
  #
  #
  #     #could be more than one item in the real database with this isbn
  #     assert_difference(result.count, 1) do
  #       LibraryItem.add_media(isbn, title)
  #       result = client.query(params)
  #       result.items.each { |item| # There might be more than one item with this isbn
  #         assert(item['isbn'], isbn)
  #       }
  #     end
  #
  #     # test isbn and title on retrieval - chicken and egg
  #     assert false
  #   end

end
