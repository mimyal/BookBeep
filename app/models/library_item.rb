require 'aws-sdk'

class LibraryItem
  include ActiveModel::Validations
  # include Aws::Record

  validates :isbn, presence: true #, length: { is: (9 || 12) } # Primary Partition Key (Libris seem to have some unexpected length ISBNs)
  validates :datetime_created, presence: true # Primary Sort Key
  validates :title, presence: true # Global Secondary Index

  attr_accessor :isbn, :datetime_created, :title, :creator_last_name, :creator_first_name

  def initialize(info)
    # CHECK that if the ISBN is already in the BB database, the title matches the existing record before creation


    @isbn = info['isbn']
    @datetime_created = info['datetime_created']
    @title = info['title'] # Title required on creation (add validations)
    @creator_last_name = info['creator_last_name']
    @creator_first_name = info['creator_first_name']
    @uri_id = info['uri_id']
  end

# Method returns an instance of LibraryItem, if successful
# Method returns NIL if the search is unsuccessful/ISBN not found
  def self.libris_search(isbn)
    @library_item = LibrisWrapper.get_book(isbn)
    return @library_item
  end

  # To list all items in BookBeep DynamoDB
  def self.all
    # NOT TESTED
    # client = Aws::DynamoDB::Client.new
    # table_name = "LibraryItems"
    # response = client.scan(table_name: table_name)
    # library =  response.items
    # # next put these into a collection of LibraryItem /s
  end

  # Method that will return a collection of library items depending on isbn, title or last name (partition key, GSIs)
  def self.get_media(info)
    client = Aws::DynamoDB::Client.new
    table_name = "LibraryItems"
    params = {}
    @library = [] # here is the return collection of instances of LibraryItem

    # STEP 1: SET UP THE PARAMS
    # First search for a specific item using the isbn AND datetime_created
    # if we know what item we want (we know the primary key)
    if info['isbn'] != nil && info['datetime_created'] != nil
      # NOT YET IN TESTS
      # params = {
      #   table_name: table_name,
      #   key: {
      #   'isbn' => info['isbn'],
      #   'datetime_created' => info['datetime_created']
      # }}
      # response = client.get_item(params)
      # puts 'Ensure this is the item wanted:' + response.item
      # puts 'What to do with response.item? Build a new instance of LibraryItem'
      # if response.item != nil
      #   @library << response.item
      # else
      #   return nil
      # end
    else # If we're looking for items
      # Second search for isbn only
      if info['isbn'] != nil # Partition key query
        params = {
          table_name: table_name,
          key_condition_expression: "isbn = :isbn", # because the db does not want to recompile the query if it already has it
          expression_attribute_values: {
            ":isbn" => info['isbn']
          }
        }
      end
      # Third search for datetime_created only
      if info[:datetime_created] != nil # Sort key query
        # NOT IMPLEMENTED
        # NO TESTS FOR THIS YET - should look the same as for info, but then we dont get a range
        # This is only used in case we are looking for a range, might be a much easier way to do this querywise
        # Return a collection within the date range
      end
      # Forth search for GSI title
      if info['title'] != nil
        params = {
          table_name: table_name,
          index_name: 'title-index',
          select: 'ALL_PROJECTED_ATTRIBUTES',
          key_condition_expression: 'title = :title',
          expression_attribute_values: {
            ':title' => info['title']
          }
        }
      end
      # Fifth search for GSI creator_last_name
      if info['creator_last_name'] != nil
        params = {
          table_name: table_name,
          index_name: 'last-name-index',
          select: 'ALL_PROJECTED_ATTRIBUTES',
          key_condition_expression: 'creator_last_name = :creator_last_name',
          expression_attribute_values: {
            ':creator_last_name' => info['creator_last_name']
          }
        }
      end
      # Check that params is not empty
      if params.empty?
        return @library # = [] # data.items = [] if nothing was found
      end
      # STEP 2: RUN QUERY
      begin
        # raise
        data = client.query(params)
        # puts "Method get_media query succeeded."
        if data.items.empty?
          return @library # = [] # data.items = [] if nothing was found
        end
        data.items.each { |listing|
          info['isbn'] = listing['isbn']
          info['datetime_created'] = listing['datetime_created']
          info['title'] = listing['title']
          info['creator_first_name'] = listing['creator_first_name']
          info['creator_last_name'] = listing['creator_last_name']
          @library << LibraryItem.new(info)
        }
      rescue  Aws::DynamoDB::Errors::ServiceError => error
        puts "Unable to query table:"
        puts "#{error.message}"
        # puts "The parameters were: #{params}"
        return @library
      end # query for collection/lists of items
    end #if
    return @library
  end

  def self.add_media(info)
    #Create a new client to access DynamoDB
    client = Aws::DynamoDB::Client.new

    # Prepare params for inserting the instance into db
    # Gives no flexibility to add other data than these two (and they must be present)
    item = {
      'isbn' => info['isbn'].to_i, # primary Partition key
      'title' => info['title'],
      'datetime_created' => Time.now.to_datetime.strftime('%Q').to_i, # primary Sort key
    }
    if !info['creator_first_name'].nil?
      item['creator_first_name'] = info['creator_first_name']
    end
    if !info['creator_last_name'].nil?
      item['creator_last_name'] = info['creator_last_name']
    end

    params = {
      table_name: "LibraryItems",
      item: item
    }
    # @todo NO TEST FOR THIS YET
    # if @library_item.valid?

    @library_item = LibraryItem.new(item)

      # Accessing DynamoDB to add the new item
      begin
        client.put_item(params) # add new item into DynamoDB
      rescue  Aws::DynamoDB::Errors::ServiceError => error
        puts "Unable to add item:"
        puts "#{error.message}"
        flash[:notice] = "Unable to add item:" + "#{error.message}" # don't know if this works
      end
      return @library_item
    # end
    return info
  end

  def add_media
    #Create a new client to access DynamoDB
    client = Aws::DynamoDB::Client.new

    # Prepare params for inserting the instance into db
    # Gives no flexibility to add other data than these two (and they must be present)
    item = {
      'isbn' => @isbn.to_i, # primary Partition key
      'title' => @title,
      'datetime_created' => Time.now.to_datetime.strftime('%Q').to_i, # primary Sort key
    }
    if !@creator_first_name.nil?
      item['creator_first_name'] = @creator_first_name
    end
    if !@creator_last_name.nil?
      item['creator_last_name'] = @creator_last_name
    end

    params = {
      table_name: "LibraryItems",
      item: item
    }

    # @todo NO TEST FOR THIS YET
    # if @library_item.valid?

    # Might not be the done thing, instead change what needs to be changed?
    @library_item = LibraryItem.new(item)

      # Accessing DynamoDB to add the new item
      begin
        client.put_item(params) # add new item into DynamoDB
      rescue  Aws::DynamoDB::Errors::ServiceError => error
        puts "Unable to add item:"
        puts "#{error.message}"
        flash[:notice] = "Unable to add item:" + "#{error.message}" # don't know if this works
      end
      return @library_item
    # end
    return info
  end

# @todo test test
  # QUERY IF ISBN ALREADY EXISTS IN DATABASE
  # return list of objects, if any, or []
  def check_copies
  #   # Set up query
  #   query = {
  #     table_name: "LibraryItems",
  #     key_condition_expression: "isbn = :isbn",
  #     expression_attribute_values: {
  #       ":isbn" => item['isbn']
  #     }
  #   }
  #   # Run query
  #   begin
  #     results = dynamodb.query(query)
  #   rescue  Aws::DynamoDB::Errors::ServiceError => error
  #     puts "#add_media test: Unable to query table:"
  #     puts "#{error.message}"
  #   end
  #
  #
  end

end
