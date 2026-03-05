class User < ApplicationRecord
  has_many :events, foreign_key: :owner_id, dependent: :delete_all
  has_many :tickets, dependent: :delete_all
  has_many :attendances, dependent: :delete_all
  has_many :attended_events, through: :attendances, source: :event
  has_many :reviews, dependent: :delete_all
  has_many :notifications, dependent: :delete_all

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
