class Events::Index < ActiveInteraction::Base
  PUBLISHED_REVIEW_STATUS = 'published'.freeze
  SORT_FIELDS = %w[from_date title reviews_count average_rating].freeze

  array :category_ids, default: [] do
    integer
  end

  string :city, default: nil
  integer :owner_id, default: nil
  time :from_date, :to_date, default: nil
  boolean :with_available_tickets, :with_checked_in_users, default: false
  string :sort_by, default: 'from_date'
  integer :page, default: 1
  integer :per_page, default: 20

  validates :sort_by, inclusion: { in: SORT_FIELDS }
  validates :page, numericality: { greater_than: 0 }
  validates :per_page, numericality: { greater_than: 0 }

  def execute
    find_events
    sort_events
    paginate_events
    set_pagination_info
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
    @events = Event.all
    @events = filter_by_category_ids(events)
    @events = filter_by_city(events)
    @events = filter_by_owner(events)
    @events = filter_by_from_date(events)
    @events = filter_by_to_date(events)
    @events = filter_by_available_tickets(events)
    @events = filter_by_checked_in_users(events)
  end

  def sort_events
    @events =
      case sort_by
      when 'from_date'
        events.order(:from_date, :id)
      when 'title'
        events.order(:title, :id)
      when 'reviews_count'
        sort_by_reviews_count
      when 'average_rating'
        sort_by_average_rating
      end
  end

  def sort_by_reviews_count
    events
      .left_joins(:reviews)
      .group('events.id')
      .order(Arel.sql("COUNT(reviews.id) FILTER (WHERE reviews.status = #{quoted_published_status}) DESC, events.id ASC"))
  end

  def sort_by_average_rating
    events
      .left_joins(:reviews)
      .group('events.id')
      .order(Arel.sql("AVG(reviews.rating) FILTER (WHERE reviews.status = #{quoted_published_status}) DESC NULLS LAST, events.id ASC"))
  end

  def paginate_events
    @events = events.page(page).per(per_page)
  end

  def set_pagination_info
    @pagination_info = {
      page: events.current_page,
      per_page: events.limit_value,
      total_items: events.total_count
    }
  end

  def set_events_info
    @events_info = Events::SetEventsInfo.run!(event_ids: events.pluck(:id))
  end

  def preload_events
    @events = events.includes(:owner, :category, :venue)
  end

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

    events.where('events.from_date >= ?', from_date)
  end

  def filter_by_to_date(events)
    return events if to_date.nil?

    events.where('events.to_date <= ?', to_date)
  end

  def filter_by_available_tickets(events)
    return events unless with_available_tickets

    events.where(id: Ticket.where(status: Events::SetEventsInfo::AVAILABLE_TICKET_STATUS).select(:event_id))
  end

  def filter_by_checked_in_users(events)
    return events unless with_checked_in_users

    events.where(id: Attendance.where.not(checked_in_at: nil).select(:event_id))
  end

  def quoted_published_status
    ActiveRecord::Base.connection.quote(PUBLISHED_REVIEW_STATUS)
  end
end
