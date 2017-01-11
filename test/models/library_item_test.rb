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
        global_secondary_indexes: [
        {
          index_name: "title-index", # required
          key_schema: [ # required
            {
              attribute_name: "title", # required
              key_type: "HASH", # required, accepts HASH, RANGE
            },
          ],
          projection: { # required
            projection_type: "ALL" # accepts ALL, KEYS_ONLY, INCLUDE
          },
          provisioned_throughput: { # required
            read_capacity_units: 1, # required
            write_capacity_units: 1, # required
          },
        },
        {
          index_name: "last-name-index", # required
          key_schema: [ # required
            {
              attribute_name: "creator_last_name", # required
              key_type: "HASH", # required, accepts HASH, RANGE
            }
          ],
          projection: { # required
            projection_type: "ALL" # accepts ALL, KEYS_ONLY, INCLUDE
          },
          provisioned_throughput: { # required
            read_capacity_units: 1, # required
            write_capacity_units: 1, # required
          },
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
          {
            attribute_name: "title",
            attribute_type: "S"
          },
          {
            attribute_name: "creator_last_name",
            attribute_type: "S"
          }

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
    dynamodb = Aws::DynamoDB::Client.new

    table_name = "LibraryItems"

    begin
      dynamodb.delete_table({table_name: table_name})
      # puts "Deleted table."

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to delete table:"
      puts "#{error.message}"
    end

  end

  test "should find model tests" do
    assert true
  end

  test "#get_media Getting a non-existing item from the database should return nil" do
    skip
    isbn = 111111111
    book = LibraryItem.get_media({isbn: isbn})
    assert_nil(book)
  end

  test "#get_media should return a collection of LibraryItem with correct values" do
    #First add the new item info
    item1 = {
      isbn: 9119275714,
      title: 'Sent i november',
      creator_first_name: 'Tove',
      creator_last_name: 'Jansson'
    }
    item2 = {
      isbn: 123456789,
      title: 'Another item'
    }
    item3 = {
      isbn: 987654321,
      title: 'Another item again',
      creator_last_name: 'NNN'
    }

    # Then run the creation method
    LibraryItem.add_media(item1) # test pass
    LibraryItem.add_media(item1) # test pass
    LibraryItem.add_media(item2)
    LibraryItem.add_media(item3)
    # puts 'creation succeeded'

    # Then call the method to be tested
    #Primary Partition Key query
    results1isbn = LibraryItem.get_media({isbn: 9119275714}) # Should return collection of two
    results2isbn = LibraryItem.get_media({isbn: 123456789})
    results3isbn = LibraryItem.get_media({isbn: 987654321})
    # Method only works if it does not return nil for any of these requests
    if results1isbn == nil || results2isbn == nil || results3isbn == nil
      assert false, 'Partition key query returned nil'
    end
    assert_equal(results1isbn.count, 2) # added two in that 'drawer'
    # Primary partition key test
    results3isbn.each { |item|
      assert_equal(item.isbn, 987654321)
      assert_equal(item.title, 'Another item again')
    }
    results1isbn.each { |item|
      # puts "what is this item? #{item}"
      assert_equal(item.isbn, 9119275714)
      assert_equal(item.title, 'Sent i november')
      assert_instance_of(LibraryItem, item)
    }
    results2isbn.each { |item|
      assert_equal(item.isbn, 123456789)
      assert_equal(item.title, 'Another item')
    }

    # GSI query
    results1title = LibraryItem.get_media({title: 'Sent i november'}) # Should return collection of two
    results3surname = LibraryItem.get_media({creator_last_name: 'NNN'})
    # Method only works if it does not return nil for any of these requests
    if results1title == nil || results3surname == nil
      assert false, 'GSI query returned nil'
    end
    assert_equal(results1title.count, 2) # added two in that 'drawer'

    # GSI Queries test
    results1title.each { |item|
      assert_equal(item.isbn, 9119275714)
      assert_equal(item.title, 'Sent i november')
      assert_instance_of(LibraryItem, item)
    }
    results3surname.each { |item|
      assert_equal(item.isbn, 987654321)
      assert_equal(item.title, 'Another item again')
      assert_equal(item.creator_last_name, 'NNN')
      assert_instance_of(LibraryItem, item)
    }
  end
  test "#add_media should add item to DynamoDB" do
    # First the new item info
    item = {
      isbn: 9119275714,
      title: 'Sent i november',
      creator_first_name: 'Tove',
      creator_last_name: 'Jansson'
    }
    # Then run the creation method
    LibraryItem.add_media(item)

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
      # puts "#add_media test query succeeded."
      assert_equal(results.items.empty?, false)
      # puts "QUERY KEYS ARE STRING TYPE"
      results.items.each{ |listing|
        assert_equal(listing['isbn'], 9119275714)
        assert_equal(listing['title'], 'Sent i november')
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
      :isbn => 9119275714,
      :title => 'Sent i november'
    }
    # Then run the creation method
    LibraryItem.add_media(item)

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
      # puts "#add_media test query succeeded."
      # results.items.each{ |listing|
      #   assert false, 'whats this?'
      #
      # }

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      assert false
      puts "#add_media test: Unable to query table:"
      puts "#{error.message}"
    end

    # Wrap assert around the method to ensure the new item is counted
    assert_difference("results.count", 1) do
    # Then run the creation method a second time (new item, new time)
      LibraryItem.add_media(item)
      results = dynamodb.query(query)
      results.items.each { |listing| # This isbn is used two times for two items
        assert(listing['isbn'], item[:isbn])
      }
    end
  end # test

  test "#add_media should return an instance of LibraryItem with the correct values" do
    # First the new item info
    item = {
      :isbn => 9119275714,
      :title => 'Sent i november',
      :creator_first_name => 'Tove',
      :creator_last_name => 'Jansson'
    }
    # Then run the creation method
    book = LibraryItem.add_media(item)
    assert_instance_of(LibraryItem, book)

    assert_equal(book.isbn, item[:isbn])
    assert_equal(book.title, item[:title])
    assert_equal(book.creator_first_name, item[:creator_first_name])
    assert_equal(book.creator_last_name, item[:creator_last_name])

  end
  test "#add_media should not add media that has an isbn of other than 6 (for media without barcode), 9 or 12 digits" do
    skip
  end
  test "#add_media should check that a new item of the same isbn as an exsisting item has the same title" do
    skip
  end

end
