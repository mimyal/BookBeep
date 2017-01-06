
class LibraryItem
  include Aws::Record
  include Dynamoid::Document
  def self.get_media(isbn)
    client = Aws::DynamoDB::Client.new
    table_name = 'Library'

    params = {
      table_name: table_name,
      key_condition_expression: "isbn",
      expression_attribute_values: {
        "isbn" => isbn
      }
    }
    begin
      data = client.query(params)
      puts "Query succeeded."
      data.items.each{|item|
        puts "#{item["creator_first_name"]} #{item[creator_last_name]}: #{item[title]}"
      }
      return data # should be nil if not available
    rescue  Aws::DynamoDB::Errors::ServiceError => error
      puts "Unable to query table:"
      puts "#{error.message}"
    end
  end

  def self.add_media(isbn, title, creator_first_name = nil, creator_last_name = nil)
#
#     client = Aws::DynamoDB::Client.new
#
#     item = {
#       isbn: isbn, # primary Partition key
#       datetime_created: Time.now, # primary Sort key
#       title: title,
#       creator_first_name: creator_first_name,
#       creator_last_name: creator_last_name
#     }
#
#
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
