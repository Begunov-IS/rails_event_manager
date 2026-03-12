class Review < ApplicationRecord
  belongs_to :user
  belongs_to :event

  validates :review_text, presence: true
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :status, presence: true, inclusion: { in: ['pending', 'published'] }
  validates :user_id, uniqueness: { scope: :event_id }
  validate :user_attended_event

  private

  def user_attended_event
    unless Attendance.exists?(user_id: user_id, event_id: event_id)
      errors.add(:base, 'пользователь не посещал это мероприятие')
    end
  end
end
