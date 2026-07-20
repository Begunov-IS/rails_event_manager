class Events::Index < ActiveInteraction::Base
  array :category_ids, default: [] do
    integer
  end

  string :city, default: nil
  integer :owner_id, default: nil
  time :from_date, :to_date, default: nil
  boolean :with_available_tickets, :with_checked_in_users, default: false
  string :sort_by, default: "from_date"
  integer :page, default: 1
  integer :per_page, default: 20

  validates :sort_by, inclusion: { in: Events::SortPaginate::SORT_FIELDS }
  validates :page, numericality: { greater_than: 0 }
  validates :per_page, numericality: { greater_than: 0 }

  def execute
    find_events
    sort_paginate_events
    set_events_info
    preload_events

    {
      events: events,
      events_info: events_info,
      pagination_info: pagination_info
    }
  end

  private

  attr_reader :events, :events_info, :pagination_info

  def find_events
    @events = Events::FindEvents.run!(
      category_ids: category_ids,
      city: city,
      owner_id: owner_id,
      from_date: from_date,
      to_date: to_date,
      with_available_tickets: with_available_tickets,
      with_checked_in_users: with_checked_in_users
    )
  end

  def sort_paginate_events
    result = Events::SortPaginate.run!(
      events: events,
      sort_by: sort_by,
      page: page,
      per_page: per_page
    )

    @events = result[:events]
    @pagination_info = result[:pagination_info]
  end

  def set_events_info
    @events_info = Events::SetEventsInfo.run!(event_ids: events.pluck(:id))
  end

  def preload_events
    @events = events.includes(:owner, :category, :venue)
  end
end
