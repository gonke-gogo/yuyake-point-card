class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.date :held_on, null: false
      t.string :venue
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
