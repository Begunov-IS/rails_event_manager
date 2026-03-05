class Event < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :category, optional: true
  belongs_to :venue, optional: true
  has_many :tickets, dependent: :delete_all
  has_many :event_sponsors, dependent: :delete_all
  has_many :sponsors, through: :event_sponsors
  has_many :attendances, dependent: :delete_all
  has_many :attendees, through: :attendances, source: :user
  has_many :reviews, dependent: :delete_all

  validates :title, :location, :from_date, :to_date, :owner_id, presence: true
  validate :end_date_after_start_date

  def end_date_after_start_date
    return if from_date.blank? || to_date.blank?

    if to_date <= from_date
      errors.add(:to_date, "должна быть позже даты начала")
    end
  end
end
