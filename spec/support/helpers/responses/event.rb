module Helpers
  module Responses
    module Event
      APPROVED_REVIEW_STATUSES = %w[approved published].freeze

      def event_base_response(event)
        {
          'id' => event.id,
          'title' => event.title,
          'location' => event.location,
          'from_date' => event.from_date.to_s,
          'to_date' => event.to_date.to_s,
          'created_at' => event.created_at.to_s,
          'updated_at' => event.updated_at.to_s,
          'owner' => {
            'id' => event.owner.id,
            'name' => event.owner.name,
            'email' => event.owner.email
          },
          'category' => event.category ? {
            'id' => event.category.id,
            'title' => event.category.title
          } : nil,
          'venue' => event.venue ? {
            'id' => event.venue.id,
            'name' => event.venue.name,
            'city' => event.venue.city,
            'address' => event.venue.address,
            'capacity' => event.venue.capacity
          } : nil
        }
      end

      def event_index_response(event)
        approved_reviews = event.reviews.select { |review| APPROVED_REVIEW_STATUSES.include?(review.status) }

        {
          'id' => event.id,
          'title' => event.title,
          'location' => event.location,
          'from_date' => event.from_date.to_s,
          'to_date' => event.to_date.to_s,
          'category' => event.category ? {
            'id' => event.category.id,
            'title' => event.category.title
          } : nil,
          'owner' => {
            'id' => event.owner.id,
            'name' => event.owner.name,
            'email' => event.owner.email
          },
          'venue' => event.venue ? {
            'id' => event.venue.id,
            'name' => event.venue.name,
            'city' => event.venue.city,
            'address' => event.venue.address
          } : nil,
          'attendees_count' => event.attendances.size,
          'checked_in_count' => event.attendances.count { |attendance| attendance.checked_in_at.present? },
          'available_tickets_count' => event.tickets.count { |ticket| ticket.status == 'available' },
          'reviews_count' => approved_reviews.size,
          'average_rating' => approved_reviews.any? ? (approved_reviews.sum(&:rating).to_f / approved_reviews.size) : nil,
          'sponsors_total_amount' => event.event_sponsors.sum { |event_sponsor| event_sponsor.amount.to_f },
          'sponsors' => event.sponsors.sort_by(&:id).map do |sponsor|
            {
              'id' => sponsor.id,
              'name' => sponsor.name,
              'email' => sponsor.email
            }
          end
        }
      end
    end
  end
end
