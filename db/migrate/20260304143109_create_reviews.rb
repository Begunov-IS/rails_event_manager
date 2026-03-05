class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.text :review_text, null: false
      t.integer :rating, null: false
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :reviews, [:user_id, :event_id], unique: true
    add_index :reviews, :status
  end
end
