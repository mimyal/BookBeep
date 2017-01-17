class LibraryItemsController < ApplicationController
  before_action :dynamodb_setup #, :require_login

  def index
    @item = {}

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
    raise
    #PARAMS FOR ONE ITEM SEARCH - COMPLETE PRIMARY KEY NEEDED
    # @info['isbn']
    # @info['datetime_created']
    @library_item = @library_item.get_media(@info)[0]
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
