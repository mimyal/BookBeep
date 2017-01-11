require 'aws-sdk'

class LibraryItem
  # include Aws::Record
  # include Dynamoid::Document

  attr_reader :isbn, :title

# Don't remember why these were here
  # integer_attr :isbn, hash_key: true
  # string_attr  :datetime_created, range_key: true
  # boolean_attr :active, database_attribute_name: "is_active_flag"

  def initialize(info)
    @isbn = info[isbn]
    @title = info[title] # Title required on creation (add validations)

    # @client = Aws::DynamoDB::Client.new

  end


  # To list all items in BookBeep DynamoDB
  def self.all
    # NOT TESTED
    # client = Aws::DynamoDB::Client.new
    # table_name = "LibraryItems"
    # library = [] # not sure I need this
    # if info == nil
    #   response = client.scan(table_name: table_name)
    #   library =  response.items
    # end
    # # next put these into a collection of LibraryItem /s
  end

  # Method that will return a collection of library items depending on isbn, title or last name (partition key, GSIs)
  def self.get_media(info = nil)
    client = Aws::DynamoDB::Client.new
    table_name = "LibraryItems"
    item = {}
    params = {}
    library = [] # here is the return

    info.each { |key, value|
      item[key] = value # item[:isbn] = info[:isbn]
    }
    puts item

    # The get_media info can contain the keys: isbn (Partition), datetime_created (Sort), title (GSI) and (creator)last_name (GSI)

    # First search for the isbn AND datetime_created
    # if we know what item we want (we know the primary key)
    if item[:isbn] != nil && item[:datetime_created] != nil
      # NOT YET IN TESTS
      # params = {
      #   table_name: table_name,
      #   key: {
      #   'isbn' => item[:isbn],
      #   'datetime_created' => item[:datetime_created]
      # }}
      # response = client.get_item(params)
      # puts 'Ensure this is the item wanted:' + response.item
      # puts 'What to do with response.item? Build a new instance of LibraryItem'
      # if response.item != nil
      #   library << response.item
      # else
      #   return nil
      # end
    else # If we're looking for items
      # SET UP THE PARAMS
      # Second search for isbn only
      if item[:isbn] != nil # Partition key query
        params = {
          table_name: table_name,
          key_condition_expression: "isbn = :isbn", # because the db does not want to recompile the query if it already has it
          expression_attribute_values: {
            ":isbn" => item[:isbn]
          }
        }
      end
      # Third search for datetime_created only
      if item[:datetime_created] != nil
        # NOT IMPLEMENTED
        # NO TESTS FOR THIS YET - should look the same as for item, but then we dont get a range
        # This is only used in case we are looking for a range, might be a much easier way to do this querywise
        # Return a collection within the date range
      end
      # Forth search for GSI title
      if item[:title] != nil
        params = {
          table_name: 'LibraryItems',
          index_name: 'title-index',
          select: 'ALL_PROJECTED_ATTRIBUTES',
          key_condition_expression: 'title = :title',
          expression_attribute_values: {
            ':title' => item[:title]
          }
        }
      end
        # Fifth search for GSI creator_last_name
        if item[:creator_last_name] != nil
          params = {
            table_name: 'LibraryItems',
            index_name: 'last-name-index',
            select: 'ALL_PROJECTED_ATTRIBUTES',
            key_condition_expression: 'creator_last_name = :creator_last_name',
            expression_attribute_values: {
              ':creator_last_name' => item[:creator_last_name]
            }
          }
        end

      # Run query
      begin
        data = client.query(params)
        puts "Method get_media query succeeded."
        library = data.items
        library.each{|listing|
          # puts "The isbn is: #{listing["isbn"]}"
          # puts "#{listing["creator_first_name"]} #{listing[creator_last_name]}: #{listing[title]}"
        }
        # dont return library! I want to return the LibraryItem collection
        return data.items unless data.items.empty? # should be nil if not available
      rescue  Aws::DynamoDB::Errors::ServiceError => error
        puts "Unable to query table:"
        puts "#{error.message}"
        puts "The parameters were: #{params}"
        return nil
      end # query for collection/lists of items

    end #if


    # items array of objects
    # Return the whole model object: LibraryItem.new(response)
  end

  def self.add_media(info)
    #Create a new client to access DynamoDB
    client = Aws::DynamoDB::Client.new
#
    # Prepare params for inserting the instance into db
    # Gives no flexibility to add other data than these two (and they must be present)
    item = {
      isbn: info[:isbn], # primary Partition key
      title: info[:title],
      datetime_created: Time.now.to_datetime.strftime('%Q').to_i, # primary Sort key
      # creator_first_name: creator_first_name,
      # creator_last_name: creator_last_name
    }
    params = {
      table_name: "LibraryItems",
      item: item
    }

    # Accessing DynamoDB to add the new item
    begin
      client.put_item(params) # add new item into DynamoDB
      puts "Added item: #{info[:title]}"

    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to add item:"
      puts "#{error.message}"
    end

    return LibraryItem.new(item)
  end

end
