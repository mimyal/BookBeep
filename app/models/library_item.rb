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
    @title = info[title]

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
    item = LibraryItem.new(info)

    client = Aws::DynamoDB::Client.new

    title = info[title] # I will want title required on creation

    ##### #LATER PROBLEM
    # unless info[author] == nil
    #   if info[author].split.length == 2
    #     creator_first_name = info[author].split.first
    #     creator_last_name = info[author].split.last
    #   end
    # end

    item = {
      isbn: isbn, # primary Partition key
      datetime_created: Time.now.strftime("%Q").to_i, # primary Sort key
      title: title,
      # creator_first_name: creator_first_name,
      # creator_last_name: creator_last_name
    }


#     params = {
#       table_name: "Library",
#       item: item
# }
#
#     begin
#       data = client.put_item(params) # add new item into DynamoDB
#       puts "Added item: #{title}"
#
#     rescue  Aws::DynamoDB::Errors::ServiceError => error
#       puts "Unable to add item:"
#       puts "#{error.message}"
#     end
#     return data
  end

end
