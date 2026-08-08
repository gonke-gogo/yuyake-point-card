class CreateStamps < ActiveRecord::Migration[8.1]
  def change
    create_table :stamps do |t|
      t.references :visitor, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.datetime :checked_in_at, null: false
      t.integer :source, null: false, default: 0
      t.bigint :granted_by_admin_user_id

      t.timestamps
    end
    add_index :stamps, [:visitor_id, :event_id], unique: true
    add_foreign_key :stamps, :admin_users, column: :granted_by_admin_user_id
    add_index :stamps, :granted_by_admin_user_id
  end
end
