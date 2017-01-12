class LibraryItemsController < ApplicationController
  before_action :dynamodb_setup #, :require_login
  def index
    raise
      @library_items = LibraryItem.get_media(item_params)
  end










  private

  def item_params
    return params.require(:library_item).permit(:isbn, :datetime_created, :creator_first_name, :creator_last_name, :title)
  end

  def dynamodb_setup
    @client = Aws::DynamoDB::Client.new
    params[:table_name] = "LibraryItems"

  end
end
