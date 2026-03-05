class Review < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :review_text, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :status, presence: true, inclusion: { in: ['pending', 'published'] }
  validates :user_id, uniqueness: { scope: :event_id }
end
