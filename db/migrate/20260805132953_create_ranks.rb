class CreateRanks < ActiveRecord::Migration[8.1]
  def change
    create_table :ranks do |t|
      t.string :name, null: false
      t.integer :min_stamps, null: false
      t.text :benefit_description
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :ranks, :min_stamps, unique: true
  end
end
