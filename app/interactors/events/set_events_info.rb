class Events::SetEventsInfo < ActiveInteraction::Base
  PUBLISHED_REVIEW_STATUS = 'published'.freeze
  AVAILABLE_TICKET_STATUS = 'available'.freeze

  array :event_ids do
    integer
  end

  def execute
    event_ids.index_with { default_info }.tap do |events_info|
      set_attendances_info(events_info)
      set_tickets_info(events_info)
      set_reviews_info(events_info)
      set_sponsors_info(events_info)
    end
  end

  private

  def default_info
    {
      attendees_count: 0,
      checked_in_count: 0,
      available_tickets_count: 0,
      reviews_count: 0,
      average_rating: nil,
      sponsors_total_amount: 0,
      sponsors: []
    }
  end

  def set_attendances_info(events_info)
    Attendance.where(event_id: event_ids).group(:event_id).count.each do |event_id, count|
      events_info[event_id][:attendees_count] = count
    end

    Attendance.where(event_id: event_ids).where.not(checked_in_at: nil).group(:event_id).count.each do |event_id, count|
      events_info[event_id][:checked_in_count] = count
    end
  end

  def set_tickets_info(events_info)
    Ticket.where(event_id: event_ids, status: AVAILABLE_TICKET_STATUS).group(:event_id).count.each do |event_id, count|
      events_info[event_id][:available_tickets_count] = count
    end
  end

  def set_reviews_info(events_info)
    Review
      .where(event_id: event_ids, status: PUBLISHED_REVIEW_STATUS)
      .group(:event_id)
      .pluck(:event_id, Arel.sql('COUNT(*)'), Arel.sql('AVG(rating)'))
      .each do |event_id, reviews_count, average_rating|
        events_info[event_id][:reviews_count] = reviews_count
        events_info[event_id][:average_rating] = average_rating
      end
  end

  def set_sponsors_info(events_info)
    EventSponsor.where(event_id: event_ids).group(:event_id).sum(:amount).each do |event_id, amount|
      events_info[event_id][:sponsors_total_amount] = amount
    end

    Sponsor
      .joins(:event_sponsors)
      .where(event_sponsors: { event_id: event_ids })
      .select('sponsors.*, event_sponsors.event_id AS event_info_event_id')
      .order(:id)
      .each do |sponsor|
        event_id = sponsor.read_attribute(:event_info_event_id)
        events_info[event_id][:sponsors] << sponsor
      end
  end
end
