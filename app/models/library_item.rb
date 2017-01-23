require 'aws-sdk'

class LibraryItem
  include ActiveModel::Validations
  # include Aws::Record

  validates :isbn, presence: true #, length: { is: (9 || 12) } # Primary Partition Key (Libris seem to have some unexpected length ISBNs)
  # validates :datetime_created, presence: true # Primary Sort Key
  validates :title, presence: true # Global Secondary Index

  attr_accessor :isbn, :datetime_created, :title, :creator_surname, :creator_first_name, :uri_id

  def initialize(info)
    @isbn = info['isbn']
    @datetime_created = info['datetime_created']
    @title = info['title']
    @creator_surname = info['creator_surname']
    @creator_first_name = info['creator_first_name']
    @uri_id = info['uri_id']
  end

  # Method returns an instance of LibraryItem, if successful
  # Method returns NIL if the search is unsuccessful/ISBN not found
  def self.libris_search(isbn)
    @library_item = LibrisWrapper.get_book(isbn)
    return @library_item
  end

  def self.all
    @library = []
    client = Aws::DynamoDB::Client.new
    table_name = "LibraryItems"

    results = client.scan({table_name: table_name})

    results.items.each do |listing|
      item = LibraryItem.new(listing)
      @library << item
    end
    return @library
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
      params = {
        table_name: table_name,
        key: {
          'isbn' => info['isbn'],
          'datetime_created' => info['datetime_created']
        }
      }
      response = client.get_item(params)
      if response.item != nil
        library_item = LibraryItem.new(response.item)
        @library << library_item
        # return @library # this is always of length one at this point
      else
        # return []
      end
      @library # Which is at length 1 or at [] at this point
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
          index_name: 'title-upcase-index',
          select: 'ALL_PROJECTED_ATTRIBUTES',
          key_condition_expression: 'title_upcase = :title_upcase',
          expression_attribute_values: {
            ':title_upcase' => info['title'].mb_chars.upcase.to_s # UPCASE
          }
        }
        # puts "HERE HERE #{info['title']}"
      end
      # Fifth search for GSI creator_surname
      if info['creator_surname'] != nil
        params = {
          table_name: table_name,
          index_name: 'surname-upcase-index',
          select: 'ALL_PROJECTED_ATTRIBUTES',
          key_condition_expression: 'creator_surname_upcase = :creator_surname_upcase',
          expression_attribute_values: {
            ':creator_surname_upcase' => info['creator_surname'].mb_chars.upcase.to_s # UPCASE
          }
        }
      end
      # Check that params is not empty
      if params.empty?
        # puts "PARAMS EMPTY for #{info}"
        return @library # = [] # data.items = [] if nothing was found
      end
      # STEP 2: RUN QUERY
      begin
        # raise
        data = client.query(params)
        # puts "Method get_media query succeeded."
        if data.items.empty?
          # puts "DATA>ITEMS EMPTY for #{info}"
          return @library # = [] # data.items = [] if nothing was found
        end
        data.items.each { |listing|
          info['isbn'] = listing['isbn']
          info['datetime_created'] = listing['datetime_created']
          info['title'] = listing['title']
          info['creator_first_name'] = listing['creator_first_name']
          info['creator_surname'] = listing['creator_surname']
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

  # Returns nil for unsuccessful adding, and self for a successfully added object to DynamoDB
  def add_media
    #Create a new client to access DynamoDB
    client = Aws::DynamoDB::Client.new

    # Ensure valid item
    if @isbn == nil || @title == nil
      return nil
    end

    # Prepare params for inserting the instance into db
    item = {
      'isbn' => @isbn.to_i, # primary Partition key
      'title' => @title,
      'title_upcase' => @title.mb_chars.upcase.to_s,
      'datetime_created' => Time.now.to_datetime.strftime('%Q').to_i, # primary Sort key
    }
    if !@creator_first_name.nil?
      item['creator_first_name'] = @creator_first_name
    end
    if !@creator_surname.nil?
      item['creator_surname'] = @creator_surname
      item['creator_surname_upcase'] = @creator_surname.mb_chars.upcase.to_s
    end

    params = {
      table_name: "LibraryItems",
      item: item
    }

    # Accessing DynamoDB to add the new item
    begin
      client.put_item(params) # add new item into DynamoDB
      return self
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to add item:"
      puts "#{error.message}"
      return nil
    end
  end

  def destroy_media
    client = Aws::DynamoDB::Client.new
    params = {
      table_name: "LibraryItems",
      key: {
        'isbn' => self.isbn,
        'datetime_created' => self.datetime_created
      }
    }
    client.delete_item(params)
  end #destroy_media

end
