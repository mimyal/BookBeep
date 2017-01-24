module LibraryItemsHelper

# Controller had no access, and it's not tested anyhow
  def sorting_by_date(items)
    sorted_items = items.sort_by { |item|
      item.datetime_created
    }
    return sorted_items.reverse
  end

end
