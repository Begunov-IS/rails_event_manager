class Event < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :category, optional: true
  has_many :tickets, dependent: :delete_all

  validates :title, presence: true
  validates :location, presence: true
  validates :from_date, presence: true
  validates :to_date, presence: true
  validates :owner_id, presence: true
  validate :end_date_after_start_date

  def end_date_after_start_date
    return if from_date.blank? || to_date.blank?

    if to_date <= from_date
      errors.add(:to_date, "должна быть позже даты начала")
    end
  end
end
