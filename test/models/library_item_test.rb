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
          index_name: "title-upcase-index", # required
          key_schema: [ # required
            {
              attribute_name: "title_upcase", # required
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
          index_name: "surname-upcase-index", # required
          key_schema: [ # required
            {
              attribute_name: "creator_surname_upcase", # required
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
            attribute_name: "title_upcase",
            attribute_type: "S"
          },
          {
            attribute_name: "creator_surname_upcase",
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

  test "#libris_search(isbn) should return a single instance of LibraryItem" do
     isbn = 9119275714
     actual_book = LibraryItem.libris_search(isbn)
     assert_equal LibraryItem, actual_book.class
     assert_equal('Sent i november', actual_book.title)
  end

  test "#libris_search should return nil for an unknown isbn" do
    isbn = 98192121921219218291821221
    response = LibraryItem.libris_search(isbn)
    assert_nil response
  end

  test "#get_media Getting a non-existing item from the database should return nil" do
    isbn = 111111111 # Partition key
    book_collection = LibraryItem.get_media({'isbn' => isbn})
    assert_equal(book_collection, [])
    title = "Not a book" # Secondary Index
    book_collection = LibraryItem.get_media({'title' => title})
    assert_equal(book_collection, [])
  end

  test "#get_media should return a collection of LibraryItem with correct values" do
    #First add the new item info and create new instances of LibraryItem
    info1 = {
      'isbn' => 9119275714,
      'title' => 'Sent i november',
      'creator_first_name' => 'Tove',
      'creator_surname' => 'Jansson'
    }
    info2 = {
      'isbn' => 123456789,
      'title' => 'Another item'
    }
    info3 = {
      'isbn' => 987654321,
      'title' => 'Another item again',
      'creator_surname' => 'NNN'
    }

    # Create a new instance of the item
    library_item1 = LibraryItem.new(info1)
    library_item2 = LibraryItem.new(info2)
    library_item3 = LibraryItem.new(info3)

    # Create two copies of the first book
    library_item4 = LibraryItem.new(info1)

    # Second run the method to add the instance to DDB
    library_item1.add_media
    library_item2.add_media
    library_item3.add_media

    # Add first item twice
    library_item4.add_media

    # Then call the method to be tested
    #Primary Partition Key query
    results1isbn = LibraryItem.get_media({'isbn' => 9119275714}) # Should return collection of two
    results2isbn = LibraryItem.get_media({'isbn' => 123456789})
    results3isbn = LibraryItem.get_media({'isbn' => 987654321})
    # Method only works if it does not return nil for any of these requests
    if results1isbn == nil || results2isbn == nil || results3isbn == nil
      assert false, 'Partition key query returned nil'
    end

    # Check that the two copies were both listed in DDB
    assert_equal(results1isbn.length, 2) # added two in that 'drawer'

    # Primary partition key test
    results3isbn.each { |item|
      assert_equal(987654321, item.isbn)
      assert_equal('Another item again', item.title)
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
    results1title = LibraryItem.get_media({'title' => info1['title']}) # Should return collection of two
    results3surname = LibraryItem.get_media({'creator_surname' => info3['title']})
    # Method only works if it does not return nil for any of these requests
    if results1title == nil || results3surname == nil
      assert false, 'GSI query returned nil'
    end
    assert_equal(results1title.length, 2) # added two in that 'drawer'

    # GSI Queries test
    results1title.each { |item|
      assert_equal(item.isbn, 9119275714)
      assert_equal(item.title, 'Sent i november')
      assert_instance_of(LibraryItem, item)
    }
    results3surname.each { |item|
      assert_equal(item.isbn, 987654321)
      assert_equal(item.title, 'Another item again')
      assert_equal(item.creator_surname, 'NNN')
      assert_instance_of(LibraryItem, item)
    }
  end

  test "#add_media should add item to DynamoDB" do
    # First the new item info
    item = {
      'isbn' => 9119275714,
      'title' => 'Sent i november',
      'creator_first_name' => 'Tove',
      'creator_surname' => 'Jansson'
    }
    # Create a new instance of the item
    library_item = LibraryItem.new(item)
    # Then run the method to add the instance to DDB
    library_item.add_media # returns itself, or nil, if not added?

    # Then set up a query
    query = {
      table_name: "LibraryItems",
      key_condition_expression: "isbn = :isbn",
      expression_attribute_values: {
        ":isbn" => item['isbn']
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
      'isbn' => 9119275714,
      'title' => 'Sent i november'
    }
    # Create a new instance of the item
    library_item = LibraryItem.new(item)

    # Then run the method to add the instance to DDB
    library_item.add_media # returns itself, or nil, if not added?

    # Then set up a query
    query = {
      table_name: "LibraryItems",
      key_condition_expression: "isbn = :isbn",
      expression_attribute_values: {
        ":isbn" => item['isbn']
      }
    }
    # RUN QUERY
    dynamodb = Aws::DynamoDB::Client.new
    begin
      results = dynamodb.query(query)
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "#add_media test: Unable to query table:"
      puts "#{error.message}"
      assert false
    end

    # Wrap assert around the method to ensure the new item is counted
    assert_difference("results.count", 1) do
      # Then run the creation method a second time (new item, new time)
      library_item2 = LibraryItem.new(item)

      # Then run the method to add the instance to DDB
      library_item2.add_media

      # Run the query again
      begin
        results = dynamodb.query(query)
      rescue  Aws::DynamoDB::Errors::ServiceError => error
        puts "#add_media test: Unable to query table:"
        puts "#{error.message}"
        assert false
      end

      # This time of length two
      assert_equal(2, results.items.length)
      results.items.each { |listing| # This isbn is used two times for two items
        assert(listing['isbn'], item['isbn'])
      }
    end # count difference
  end # test

  test "#add_media should return an instance of LibraryItem with the correct values" do
    # First the new item info
    item = {
      'isbn' => 9119275714,
      'title' => 'Sent i november',
      'creator_first_name' => 'Tove',
      'creator_surname' => 'Jansson'
    }
    # Create a new instance of the item
    library_item = LibraryItem.new(item)
    # Then run the method to add the instance to DDB
    book = library_item.add_media # returns itself, or nil, if not added?

    assert_instance_of(LibraryItem, book)

    assert_equal(book.isbn, item['isbn'])
    assert_equal(book.title, item['title'])
    assert_equal(book.creator_first_name, item['creator_first_name'])
    assert_equal(book.creator_surname, item['creator_surname'])

  end

  test "instance invalid if isbn or title are missing" do
    # ISBN First the new item info
    item1 = {
      'isbn' => 9119275714,
      'creator_first_name' => 'Tove',
      'creator_surname' => 'Jansson'
    }
    # Create a new instance of the item
    library_item1 = LibraryItem.new(item1)
    assert_not library_item1.valid? # false

    # TITLE First the new item info
    item2 = {
      'title' => 'Sent i november',
      'creator_first_name' => 'Tove',
      'creator_surname' => 'Jansson'
    }
    # Create a new instance of the item
    library_item2 = LibraryItem.new(item2)
    assert_not library_item2.valid? # false

  end

  test "#add_media will not add invalid LibraryItem instances to DDB" do
    # ISBN First the new item info
    item1 = {
      'isbn' => 9119275714,
      'creator_first_name' => 'Tove',
      'creator_surname' => 'Jansson'
    }
    # Create a new instance of the item, it is invalid (tested earlier)
    library_item1 = LibraryItem.new(item1)

    #Add it to DynamoDB using the method
    library_item1.add_media

    #Query item to check if it was added
    #Set up query
    query = {
      table_name: "LibraryItems",
      key_condition_expression: "isbn = :isbn",
      expression_attribute_values: {
        ":isbn" => item1['isbn']
      }
    }
    # RUN QUERY
    dynamodb = Aws::DynamoDB::Client.new
    begin
      results = dynamodb.query(query)
      assert_equal(results.items.empty?, true)
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "#add_media test: Unable to query table:"
      puts "#{error.message}"
      assert false, "Unable to query table for #{item1['isbn']}"
    end


    # TITLE First the new item info
    item2 = {
      'title' => 'Sent i november',
      'creator_first_name' => 'Tove',
      'creator_surname' => 'Jansson'
    }
    # Create a new instance of the item, it is invalid (tested earlier)
    library_item2 = LibraryItem.new(item2)

    #Add it to DynamoDB using the method
    library_item2.add_media

    #Query item to check if it was added
    #Set up query params
    params = {
      table_name: 'LibraryItems',
      index_name: 'title-upcase-index',
      select: 'ALL_PROJECTED_ATTRIBUTES',
      key_condition_expression: 'title_upcase = :title_upcase',
      expression_attribute_values: {
        ':title_upcase' => item2['title'].upcase
      }
    }

    # RUN QUERY
    begin
      response = dynamodb.query(params)
      # puts "GSI Query suceessful"
      # items != [] ? (puts items) : (puts "No items were found")
      assert response.items.empty?
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to query table:"
      puts "#{error.message}"
      assert false, "Unable to query table for #{item['title']}"
    end

  end #test



end
