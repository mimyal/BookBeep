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
  test "#add_media should add item to DynamoDB" do
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
      puts "#add_media test query succeeded."
      assert_equal(results.items.empty?, false)
      results.items.each{|listing|
        assert_equal(listing["isbn"], 9119275714)
        assert_equal(listing["title"], 'Sent i november')
      }
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      assert false
      puts "#add_media test: Unable to query table:"
      puts "#{error.message}"
    end
  end #test
  test "#add_media a new item should increase DynamoDB table by one" do
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
      puts "#add_media test query succeeded."
      puts "THERE ARE NO ITEMS #{results.items.empty?}"
      results.items.each{|listing|
      }

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      assert false
      puts "#add_media test: Unable to query table:"
      puts "#{error.message}"
    end

    # Wrap assert around the method to ensure the new item is counted
    assert_difference("results.count", 1) do
    # Then run the creation method a second time (new item, new time)
      book = LibraryItem.add_media(item)
      results = dynamodb.query(query)
      results.items.each { |listing| # This isbn is used two times for two items
        assert(listing['isbn'], item[:isbn])
      }
    end


  end # test

  test "#add_media should not add media that has an isbn of other than 9 or 12 digits" do
    skip
  end
  test "#add_media should check that a new item of the same isbn as an exsisting item has the same title" do
    skip
  end

end
