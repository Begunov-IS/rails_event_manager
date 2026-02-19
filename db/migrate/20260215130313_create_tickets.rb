class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :status, null: false, default: 'available'
      t.references :user, null: true, foreign_key: true
      t.references :event, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tickets, :status
  end
end
