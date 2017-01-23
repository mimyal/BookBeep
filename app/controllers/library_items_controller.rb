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
      @library_items = LibraryItem.all
    else
      @library_items = LibraryItem.get_media(@info) #WEAK PARAMS
    end

    if @library_items.empty?
      flash[:notice] = 'Book Beep returned no items for this search'
      redirect_to main_path
    end
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
    @library_item = LibraryItem.libris_search(isbn) #WEAK PARAMS

    if @library_item.nil?
      flash[:notice] = "This ISBN was not found in Libris"
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
      flash[:notice] = "BEEP! The item was successfully added to Book Beep"
      params[:search_key] = 'isbn'
      params[:search_value] = @library_item.isbn.to_s
      redirect_to library_items_path(params) # WEAK PARAMS
      return
    else
      #FAILURE
      flash[:notice] = "This item is not valid to enter by this method"
      redirect_to main_path
      return
    end
  end

  def destroy
    @info['isbn'] = params['isbn'].to_i
    @info['datetime_created'] = params['datetime_created'].to_i
    # Get the item to be destroyed
    @library_item = LibraryItem.get_media(@info)[0]
    @library_item.destroy_media # do I need to do a if save! kindofthing here?
    redirect_to library_items_path(params) #WEAK PARAMS
  end

  private

  # def item_params
  #   return params.permit(@info)
  #   # return params.require(:library_item).permit(:isbn, :datetime_created, :creator_first_name, :creator_surname, :title)
  # end

  def dynamodb_setup
    @client = Aws::DynamoDB::Client.new
    @info = {table_name: "LibraryItems"}

  end
end
