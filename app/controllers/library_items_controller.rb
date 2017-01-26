class LibraryItemsController < ApplicationController
  before_action :dynamodb_setup #, :require_login

  def index
    # Build query params from search
    if params[:search_key] == 'isbn'
      @info[params[:search_key]] = params[:search_value].to_i
    else
      @info[params[:search_key]] = params[:search_value]
    end

    # For when the List all button is pressed
    unless params[:search_key] == 'isbn' || params[:search_key] == 'title' || params[:search_key] == 'creator_surname'
      items = LibraryItem.all
    else
      items = LibraryItem.get_media(@info)
    end

    if items.empty?
      flash[:notice] = 'Book Beep returned no items for this search'
      redirect_to main_path
      return
    end

    #Sort the media (not tested)
    sorted_items = items.sort_by { |item|
      item.datetime_created
    }
    @library_items = sorted_items.reverse

  end

  # Redirect to here from main#index if the add new item form is filled in
  def create
    isbn = params['isbn'].gsub(/[^0-9,.]/, "").to_i
    # Check for no/invalid entry
    if isbn%100000000 < 1
      flash[:notice] = "This is not a valid ISBN"
      redirect_to main_path
      return
    end
    @library_item = LibraryItem.libris_search(isbn)

    if @library_item.nil?
      flash[:notice] = "This ISBN was not found in Libris: #{params['isbn']}"
      redirect_to main_path # what is the difference between render/redirect?
      return
    end

    if @library_item.valid?
      #SUCCESS
      @library_item = @library_item.add_media
      if @library_item.nil?
        flash[:notice] = "The item could not be added to Book Beep."
        redirect_to main_path
        return
      end
      flash[:notice] = "BEEP! '#{@library_item.title }' was successfully added to Book Beep"
      params[:search_key] = 'isbn'
      params[:search_value] = @library_item.isbn.to_s
      redirect_to library_items_path(params)
      return
    else
      #FAILURE
      flash[:notice] = "This item is not valid to enter by this method"
      redirect_to main_path
      return
    end
  end

  def destroy
    # YAY SUCCESS
    #PARAMS FOR ONE ITEM SEARCH - COMPLETE PRIMARY KEY NEEDED
    @info['isbn'] = params['isbn'].to_i
    @info['datetime_created'] = params['datetime_created'].to_i
    # Get the item to be destroyed
    @library_item = LibraryItem.get_media(@info)[0]
    @info['title'] = @library_item.title
    @library_item.destroy_media # do I need to do a if save! kindofthing here?
    # Does this list the whole database because of params @todo
    flash[:notice] = "Deleted item from database: '#{@info['title']}'"
    redirect_to library_items_path(params) #WEAK PARAMS
  end







  private

  def index_params
    # return params.permit(@info)
    # return params.permit(:isbn, :datetime_created, :creator_first_name, :creator_surname, :title)
    return params.permit(:search_key, :search_value, :isbn, :creator_surname, :title)
  end

  def dynamodb_setup
    @client = Aws::DynamoDB::Client.new
    @info = {table_name: "LibraryItems"}

  end
end
