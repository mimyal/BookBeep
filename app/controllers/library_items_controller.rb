class LibraryItemsController < ApplicationController
  before_action :dynamodb_setup #, :require_login
  def index
    # First validate the search params

    # Build query params from search
    if params[:search_key] == 'isbn' # || params[:search_key] == 'datetime_created'
      @info[params[:search_key]] = params[:search_value].to_i
    else
      @info[params[:search_key]] = params[:search_value]
    end

    @library_items = LibraryItem.get_media(@info) #WEAK PARAMS
    # raise
    if @library_items.empty?
      flash[:notice] = 'The search returned no items'
      redirect_to main_path
    end
  end










  private

  # def item_params
  #   return params.permit(@info)
  #   # return params.require(:library_item).permit(:isbn, :datetime_created, :creator_first_name, :creator_last_name, :title)
  # end

  def dynamodb_setup
    @client = Aws::DynamoDB::Client.new
    @info = {table_name: "LibraryItems"}

  end
end
