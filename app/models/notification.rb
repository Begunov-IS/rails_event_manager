class Notification < ApplicationRecord
  belongs_to :user

  TYPES = ['ticket_confirmed', 'event_cancelled', 'new_review']

  validates :message, presence: true
  validates :notification_type, presence: true, inclusion: { in: TYPES }
end
