class Ticket < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :event

  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :status, presence: true, inclusion: { in: %w[available booked cancelled] }
  validates :event_id, presence: true
end
