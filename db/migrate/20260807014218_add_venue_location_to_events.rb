class AddVenueLocationToEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :events, :venue_lat, :decimal, precision: 9, scale: 6
    add_column :events, :venue_lng, :decimal, precision: 9, scale: 6
    add_column :events, :allowed_radius_meters, :integer, null: false, default: 100
  end
end
