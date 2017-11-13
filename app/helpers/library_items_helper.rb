module LibraryItemsHelper

# Controller had no access, and it's not tested anyhow
  def sorting_by_date(items)
    sorted_items = items.sort_by { |item|
      item.datetime_created
    }
    return sorted_items.reverse
  end

  def params_to_text(search_param)
    if params[:search_key] == 'creator_surname'
      return 'Author'
    elsif params[:search_key] == 'title'
      return 'Title'
    else
      return 'ISBN'
    end
  end

end
