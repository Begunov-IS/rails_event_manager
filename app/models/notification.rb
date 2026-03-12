class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  TYPES = ['ticket_confirmed', 'event_cancelled', 'new_review']

  validates :message, presence: true
  validates :notification_type, presence: true, inclusion: { in: TYPES }
end
