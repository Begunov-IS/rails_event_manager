class Events::SortPaginate < ActiveInteraction::Base
  PUBLISHED_REVIEW_STATUS = "published".freeze
  SORT_FIELDS = %w[from_date title reviews_count average_rating].freeze

  object :events, class: ActiveRecord::Relation
  string :sort_by, default: "from_date"
  integer :page, default: 1
  integer :per_page, default: 20

  validates :sort_by, inclusion: { in: SORT_FIELDS }
  validates :page, numericality: { greater_than: 0 }
  validates :per_page, numericality: { greater_than: 0 }

  def execute
    sort_events
    paginate_events

    {
      events: events,
      pagination_info: pagination_info
    }
  end

  private

  attr_reader :pagination_info

  def sort_events
    @events = send("sort_by_#{sort_by}")
  end

  def sort_by_from_date
    events.order(:from_date, :id)
  end

  def sort_by_title
    events.order(:title, :id)
  end

  def sort_by_reviews_count
    events
      .left_joins(:reviews)
      .group("events.id")
      .order(Arel.sql("COUNT(reviews.id) FILTER (WHERE reviews.status = #{quoted_published_status}) DESC, events.id ASC"))
  end

  def sort_by_average_rating
    events
      .left_joins(:reviews)
      .group("events.id")
      .order(Arel.sql("AVG(reviews.rating) FILTER (WHERE reviews.status = #{quoted_published_status}) DESC NULLS LAST, events.id ASC"))
  end

  def paginate_events
    @events = events.page(page).per(per_page)
    @pagination_info = {
      page: events.current_page,
      per_page: events.limit_value,
      total_items: events.total_count
    }
  end

  def quoted_published_status
    ActiveRecord::Base.connection.quote(PUBLISHED_REVIEW_STATUS)
  end
end
