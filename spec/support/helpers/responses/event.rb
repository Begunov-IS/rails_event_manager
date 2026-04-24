module Helpers
  module Responses
    module Event
      PUBLISHED_REVIEW_STATUSES = %w[published].freeze

      def event_base_response(event)
        {
          id: event.id,
          title: event.title,
          location: event.location,
          from_date: event.from_date.as_json,
          to_date: event.to_date.as_json,
          created_at: event.created_at.as_json,
          updated_at: event.updated_at.as_json,
          owner: owner_response(event.owner),
          category: category_response(event.category),
          venue: venue_response(event.venue, include_capacity: true)
        }.as_json
      end

      def event_index_response(event)
        published_reviews = event.reviews.select { |review| PUBLISHED_REVIEW_STATUSES.include?(review.status) }

        {
          id: event.id,
          title: event.title,
          location: event.location,
          from_date: event.from_date.as_json,
          to_date: event.to_date.as_json,
          category: category_response(event.category),
          owner: owner_response(event.owner),
          venue: venue_response(event.venue),
          attendees_count: event.attendances.size,
          checked_in_count: event.attendances.count { |attendance| attendance.checked_in_at.present? },
          available_tickets_count: event.tickets.count { |ticket| ticket.status == 'available' },
          reviews_count: published_reviews.size,
          average_rating: average_rating(published_reviews),
          sponsors_total_amount: event.event_sponsors.sum { |event_sponsor| event_sponsor.amount.to_f },
          sponsors: event.sponsors.sort_by(&:id).map { |sponsor| sponsor_response(sponsor) }
        }.as_json
      end

      def success_response(resource_key, resource, meta: nil)
        {
          success: true,
          resource_key => resource,
          meta: meta
        }.compact.as_json
      end

      def failure_response(*errors)
        {
          success: false,
          errors: errors.flatten
        }.as_json
      end

      def error_response(key, messages)
        {
          key: key,
          messages: Array(messages)
        }.as_json
      end

      def events_index_response(events, page:, per_page:, total_items:)
        success_response(
          :events,
          events.map { |event| event_index_response(event) },
          meta: {
            page: page,
            per_page: per_page,
            total_items: total_items
          }
        )
      end

      private

      def average_rating(reviews)
        return if reviews.empty?

        reviews.sum(&:rating).to_f / reviews.size
      end

      def owner_response(owner)
        {
          id: owner.id,
          name: owner.name,
          email: owner.email
        }
      end

      def category_response(category)
        return if category.nil?

        {
          id: category.id,
          title: category.title
        }
      end

      def venue_response(venue, include_capacity: false)
        return if venue.nil?

        {
          id: venue.id,
          name: venue.name,
          city: venue.city,
          address: venue.address,
          capacity: include_capacity ? venue.capacity : nil
        }.compact
      end

      def sponsor_response(sponsor)
        {
          id: sponsor.id,
          name: sponsor.name,
          email: sponsor.email
        }
      end
    end
  end
end
