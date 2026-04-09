module Helpers
  module Responses
    module Event
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
    end
  end
end
