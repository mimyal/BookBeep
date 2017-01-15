require 'httparty'

class LibrisWrapper
  BASE_URL = "http://libris.kb.se/xsearch"
  FORMAT = "&format=json"
  # No keys needed

  attr_reader :data

# Method returns an instance of LibraryItem
# Method returns NIL if the search is unsuccessful/ISBN not found
  def self.get_book(isbn) #string
    url = BASE_URL + "?q=#{isbn}" + FORMAT
    @data = HTTParty.get(url).parsed_response # parsed?
    if @data['xsearch']['records'] == 0
      return nil
    else
      # check if @dataISBN is same numbers as arg isbn
      identifier = @data['xsearch']['list'][0]['identifier'] # this is the URL page for the book
      title = @data['xsearch']['list'][0]['title']
      creator = @data['xsearch']['list'][0]['creator']
      if creator.nil?
        author_last = nil
        author_first = nil
      else
        author_last = creator.split(', ')[0]
        author_first = creator.split(', ')[1]
      end
      info = {
        'isbn' => isbn.to_i,
        # 'datetime_created' => Time.now.to_datetime.strftime('%Q').to_i,
        'title' => title,
        'creator_last_name' => author_last,
        'creator_first_name' => author_first,
        'uri_id' => identifier # all BB db items will have a value for this
      }
      library_item = LibraryItem.new(info)
      # @todo NOT IMPLEMENTED: Check for valid - test?
      # if !library_item.valid?
      #   return nil
      # end
      return library_item

    end

  end

end
