class AddCheckinLocationToStamps < ActiveRecord::Migration[8.1]
  def change
    add_column :stamps, :checkin_lat, :decimal, precision: 9, scale: 6
    add_column :stamps, :checkin_lng, :decimal, precision: 9, scale: 6
  end
end
