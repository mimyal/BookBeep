class LibraryItemsController < ApplicationController
  before_action :dynamodb_setup #, :require_login
  def index
    # First validate the search params
    #ISBN
    #Title
    #Last Name

    # Build query params from search
    if params[:search_key] == 'isbn'
      @info[params[:search_key]] = params[:search_value].to_i
    else
      @info[params[:search_key]] = params[:search_value]
    end

    @library_items = LibraryItem.get_media(@info) #WEAK PARAMS
    # raise
    if @library_items.empty?
      flash[:notice] = 'Book Beep returned no items for this search'
      redirect_to main_path
    end
  end

  # Redirect to here from main#index if the add new item form is filled in
  def create
    isbn = params['isbn'].to_i
    @library_item = LibraryItem.libris_search(isbn) #WEAK PARAMS

    if @library_item.nil?
      flash[:notice] = "This ISBN was not found in Libris"
      redirect_to main_path
    end

    # QUERY IF THE ISBN ALREADY EXISTS IN DATABASE - before asking Libris for the other details?
    results = @library_item.check_copies
    if !results.empty?
      results.items.each do |listing|
        if !listing['title'] == @library_item.title
          # @todo IN PROGRESS
          # Don't add to database, render #index with params @library_item.isbn
          # add form to add new?
          return
        end #if
      end #do
    end #if

    #SUCCESS
    # Add to database through model
    # This will work, but it will query the database an extra time for information we already should have
    flash[:notice] == "The item was successfully added to Book Beep"
    redirect_to library_items_path({params[:search_key]: 'isbn', params[:search_value]: @library_item.isbn})

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
