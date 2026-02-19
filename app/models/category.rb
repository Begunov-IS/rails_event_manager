class Category < ApplicationRecord
  has_many :events, dependent: :nullify

  validates :title, presence: true
end
