class Events::Index < ActiveInteraction::Base
  SORT_MAPPINGS = {
    'from_date' => 'events.from_date ASC, events.id ASC',
    'title' => 'events.title ASC, events.id ASC',
    'reviews_count' => 'reviews_count DESC, events.id ASC',
    'average_rating' => 'average_rating DESC NULLS LAST, events.id ASC'
  }.freeze

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

  validates :sort_by, inclusion: { in: SORT_MAPPINGS.keys }
  validates :page, numericality: { greater_than: 0 }
  validates :per_page, numericality: { greater_than: 0 }

  def execute
    scope = find_events
    scope = sort_events(scope)
    scope = paginate_events(scope)
    scope = preload_scope(scope)

    {
      events: scope,
      pagination_info: set_pagination_info(scope)
    }
  end

  private

  def find_events
    scope = events_scope

    scope = filter_by_category_ids(scope)
    scope = filter_by_city(scope)
    scope = filter_by_owner(scope)
    scope = filter_by_from_date(scope)
    scope = filter_by_to_date(scope)
    scope = filter_by_available_tickets(scope)
    filter_by_checked_in_users(scope)
  end

  def events_scope
    Event
      .joins(attendances_stats_join)
      .joins(tickets_stats_join)
      .joins(reviews_stats_join)
      .joins(sponsors_stats_join)
      .select(select_columns)
  end

  def sort_events(scope)
    scope.order(Arel.sql(SORT_MAPPINGS.fetch(sort_by)))
  end

  def paginate_events(scope)
    scope.page(page).per(per_page)
  end

  def preload_scope(scope)
    scope.includes(:owner, :category, :venue, :sponsors)
  end

  def set_pagination_info(scope)
    {
      page: scope.current_page,
      per_page: scope.limit_value,
      total_items: scope.total_count
    }
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

    events.where('tickets_stats.available_tickets_count > 0')
  end

  def filter_by_checked_in_users(events)
    return events unless with_checked_in_users

    events.where('attendances_stats.checked_in_count > 0')
  end

  def select_columns
    <<~SQL.squish
      events.*,
      COALESCE(attendances_stats.attendees_count, 0) AS attendees_count,
      COALESCE(attendances_stats.checked_in_count, 0) AS checked_in_count,
      COALESCE(tickets_stats.available_tickets_count, 0) AS available_tickets_count,
      COALESCE(reviews_stats.reviews_count, 0) AS reviews_count,
      reviews_stats.average_rating AS average_rating,
      COALESCE(sponsors_stats.sponsors_total_amount, 0) AS sponsors_total_amount
    SQL
  end

  def attendances_stats_join
    <<~SQL.squish
      LEFT JOIN (
        SELECT
          attendances.event_id,
          COUNT(*) AS attendees_count,
          COUNT(attendances.checked_in_at) AS checked_in_count
        FROM attendances
        GROUP BY attendances.event_id
      ) attendances_stats ON attendances_stats.event_id = events.id
    SQL
  end

  def tickets_stats_join
    <<~SQL.squish
      LEFT JOIN (
        SELECT
          tickets.event_id,
          COUNT(*) FILTER (WHERE tickets.status = 'available') AS available_tickets_count
        FROM tickets
        GROUP BY tickets.event_id
      ) tickets_stats ON tickets_stats.event_id = events.id
    SQL
  end

  def reviews_stats_join
    <<~SQL.squish
      LEFT JOIN (
        SELECT
          reviews.event_id,
          COUNT(*) FILTER (WHERE reviews.status = 'published') AS reviews_count,
          AVG(reviews.rating) FILTER (WHERE reviews.status = 'published') AS average_rating
        FROM reviews
        GROUP BY reviews.event_id
      ) reviews_stats ON reviews_stats.event_id = events.id
    SQL
  end

  def sponsors_stats_join
    <<~SQL.squish
      LEFT JOIN (
        SELECT
          event_sponsors.event_id,
          SUM(event_sponsors.amount) AS sponsors_total_amount
        FROM event_sponsors
        GROUP BY event_sponsors.event_id
      ) sponsors_stats ON sponsors_stats.event_id = events.id
    SQL
  end
end
