require File.expand_path("../../test_helper", __FILE__)
# require 'test_helper'

class LibraryItemTest < ActiveSupport::TestCase
  test "should find model tests" do
    assert true
  end
end

# For testing wrapper
# migration = Aws::Record::TableMigration.new(MyModel)
# migration.create!(
#   provisioned_throughput: {
#     read_capacity_units: 5,
#     write_capacity_units: 2
#   }
# )
# migration.wait_until_available
