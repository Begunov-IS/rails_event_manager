class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.string :location, null: false
      t.datetime :from_date, null: false
      t.datetime :to_date, null: false
      t.references :owner, null: false, foreign_key: { to_table: :users }
      t.references :category, null: true, foreign_key: true

      t.timestamps
    end

    add_index :events, :from_date
  end
end
