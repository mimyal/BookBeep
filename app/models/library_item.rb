# Requires here.
class LibraryItem
  include Aws::Record
  include Dynamoid::Document

  attr_reader :isbn

  integer_attr :isbn, hash_key: true
  string_attr  :datetime_created, range_key: true
  boolean_attr :active, database_attribute_name: "is_active_flag"

  def initialize(info)
    @isbn = info[isbn]
    @title = info[title] # Title required on creation (add validations)


    # @client = Aws::DynamoDB::Client.new

  end

  def self.get_media(isbn)
    client = Aws::DynamoDB::Client.new
    table_name = "LibraryItems"

    params = {
      table_name: table_name,
      key_condition_expression: "isbn = :isbn", # because the db does not want to recompile the query if it already has it
      expression_attribute_values: {
        ":isbn" => isbn
      }
    }
    # puts params[:expression_attribute_values]
    begin
      data = client.query(params)
      puts "Method get_media query succeeded."
      data.items.each{|item|
        # puts "The isbn is: #{item["isbn"]}"
        # puts "#{item["creator_first_name"]} #{item[creator_last_name]}: #{item[title]}"
      }
      return data.items unless data.items.empty? # should be nil if not available
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to query table:"
      puts "#{error.message}"
    end
  end

  def self.add_media(info)
    #Create a new instance of LibraryItem
    @library_item = LibraryItem.new(info)

    #Create a new client to access DynamoDB
    client = Aws::DynamoDB::Client.new

    # Prepare params for inserting the instance into db
    item = {
      isbn: isbn, # primary Partition key
      datetime_created: Time.now.strftime("%Q").to_i, # primary Sort key
      title: title,
      # creator_first_name: creator_first_name,
      # creator_last_name: creator_last_name
    }
    params = {
      table_name: "Library",
      item: item
    }

    # Accessing DynamoDB to add the new item
#     begin
#       data = client.put_item(params) # add new item into DynamoDB
#       puts "Added item: #{title}"
#
#     rescue  Aws::DynamoDB::Errors::ServiceError => error
#       puts "Unable to add item:"
#       puts "#{error.message}"
#     end
#     return data
  return @library_item
  end

end
