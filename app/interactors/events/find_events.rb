class Events::FindEvents < ActiveInteraction::Base
  array :category_ids, default: [] do
    integer
  end

  string :city, default: nil
  integer :owner_id, default: nil
  time :from_date, :to_date, default: nil
  boolean :with_available_tickets, :with_checked_in_users, default: false

  def execute
    events = Event.all
    events = filter_by_category_ids(events)
    events = filter_by_city(events)
    events = filter_by_owner(events)
    events = filter_by_from_date(events)
    events = filter_by_to_date(events)
    events = filter_by_available_tickets(events)
    filter_by_checked_in_users(events)
  end

  private

  def filter_by_category_ids(events)
    return events if category_ids.empty?

    events.where(category_id: category_ids)
  end

  def filter_by_city(events)
    return events if city.blank?

    events.joins(:venue).where(venues: { city: city })
  end

  def filter_by_owner(events)
    return events if owner_id.nil?

    events.where(owner_id: owner_id)
  end

  def filter_by_from_date(events)
    return events if from_date.nil?

    events.where("events.from_date >= ?", from_date)
  end

  def filter_by_to_date(events)
    return events if to_date.nil?

    events.where("events.to_date <= ?", to_date)
  end

  def filter_by_available_tickets(events)
    return events unless with_available_tickets

    events.where(id: Ticket.where(status: Events::SetEventsInfo::AVAILABLE_TICKET_STATUS).select(:event_id))
  end

  def filter_by_checked_in_users(events)
    return events unless with_checked_in_users

    events.where(id: Attendance.where.not(checked_in_at: nil).select(:event_id))
  end
end
