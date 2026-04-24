require 'rails_helper'

RSpec.describe 'GET /events', type: :request do
  let(:base_time) { Time.zone.parse('2026-04-20 10:00:00') }
  let!(:category_music) { create(:category) }
  let!(:category_tech) { create(:category) }
  let!(:owner_one) { create(:user) }
  let!(:owner_two) { create(:user) }
  let!(:venue_moscow) { create(:venue, city: 'Moscow') }
  let!(:venue_spb) { create(:venue, city: 'Saint Petersburg') }

  let!(:event1) do
    create(
      :event,
      title: 'Charlie Event',
      owner: owner_one,
      category: category_music,
      venue: venue_moscow,
      from_date: base_time + 1.day,
      to_date: base_time + 1.day + 2.hours
    )
  end

  let!(:event2) do
    create(
      :event,
      title: 'Alpha Event',
      owner: owner_one,
      category: category_tech,
      venue: venue_spb,
      from_date: base_time + 2.days,
      to_date: base_time + 2.days + 2.hours
    )
  end

  let!(:event3) do
    create(
      :event,
      title: 'Bravo Event',
      owner: owner_two,
      category: category_music,
      venue: venue_moscow,
      from_date: base_time + 3.days,
      to_date: base_time + 3.days + 2.hours
    )
  end

  let!(:event1_attendee_one) { create(:user, email: 'event1-attendee-one@example.com') }
  let!(:event1_attendee_two) { create(:user, email: 'event1-attendee-two@example.com') }
  let!(:event2_attendee) { create(:user, email: 'event2-attendee@example.com') }
  let!(:event3_attendee) { create(:user, email: 'event3-attendee@example.com') }

  let!(:event1_attendance_one) { create(:attendance, event: event1, user: event1_attendee_one, checked_in_at: base_time + 1.day + 30.minutes) }
  let!(:event1_attendance_two) { create(:attendance, event: event1, user: event1_attendee_two) }
  let!(:event2_attendance) { create(:attendance, event: event2, user: event2_attendee) }
  let!(:event3_attendance) { create(:attendance, event: event3, user: event3_attendee, checked_in_at: base_time + 3.days + 15.minutes) }

  let!(:event1_available_ticket) { create(:ticket, event: event1, status: 'available') }
  let!(:event1_booked_ticket) { create(:ticket, event: event1, status: 'booked') }
  let!(:event2_cancelled_ticket) { create(:ticket, event: event2, status: 'cancelled') }
  let!(:event3_available_ticket) { create(:ticket, event: event3, status: 'available') }

  let!(:event1_review_one) { create(:review, event: event1, user: event1_attendee_one, rating: 5) }
  let!(:event1_review_two) { create(:review, event: event1, user: event1_attendee_two, rating: 3) }
  let!(:event2_pending_review) { create(:review, event: event2, user: event2_attendee, rating: 4, status: 'pending') }
  let!(:event3_review) { create(:review, event: event3, user: event3_attendee, rating: 4) }

  let!(:sponsor_one) { create(:sponsor) }
  let!(:sponsor_two) { create(:sponsor) }
  let!(:sponsor_three) { create(:sponsor) }

  let!(:event1_sponsor_one) { create(:event_sponsor, event: event1, sponsor: sponsor_one, amount: 100.0) }
  let!(:event1_sponsor_two) { create(:event_sponsor, event: event1, sponsor: sponsor_two, amount: 150.0) }
  let!(:event2_sponsor) { create(:event_sponsor, event: event2, sponsor: sponsor_three, amount: 75.0) }

  let(:url) { '/events' }

  context 'success' do
    before { get url, headers: json_headers }

    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all events' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event2.reload, event3.reload],
          page: 1,
          per_page: 20,
          total_items: 3
        )
      )
    end

    it 'does not count pending reviews in stats' do
      event_response = json.fetch('events').find { |item| item.fetch('id') == event2.id }

      expect(event_response).to include(
        'reviews_count' => 0,
        'average_rating' => nil
      )
    end
  end

  context 'filter by category_ids' do
    before { get url, params: { category_ids: [category_music.id] }, headers: json_headers }

    it 'returns filtered events' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event3.reload],
          page: 1,
          per_page: 20,
          total_items: 2
        )
      )
    end
  end

  context 'when legacy category_id is passed' do
    before { get url, params: { category_id: category_music.id }, headers: json_headers }

    it 'ignores it and keeps the new contract' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event2.reload, event3.reload],
          page: 1,
          per_page: 20,
          total_items: 3
        )
      )
    end
  end

  context 'filter by city' do
    before { get url, params: { city: 'Saint Petersburg' }, headers: json_headers }

    it 'returns only events from the city' do
      expect(json).to eq(
        events_index_response(
          [event2.reload],
          page: 1,
          per_page: 20,
          total_items: 1
        )
      )
    end
  end

  context 'filter by owner_id' do
    before { get url, params: { owner_id: owner_one.id }, headers: json_headers }

    it 'returns only owner events' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event2.reload],
          page: 1,
          per_page: 20,
          total_items: 2
        )
      )
    end
  end

  context 'filter by from_date and to_date' do
    before do
      get url,
          params: {
            from_date: (base_time + 2.days).iso8601,
            to_date: (base_time + 3.days + 2.hours).iso8601
          },
          headers: json_headers
    end

    it 'returns events within range' do
      expect(json).to eq(
        events_index_response(
          [event2.reload, event3.reload],
          page: 1,
          per_page: 20,
          total_items: 2
        )
      )
    end
  end

  context 'filter by available tickets' do
    before { get url, params: { with_available_tickets: true }, headers: json_headers }

    it 'returns only events with available tickets' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event3.reload],
          page: 1,
          per_page: 20,
          total_items: 2
        )
      )
    end
  end

  context 'filter by checked in users' do
    before { get url, params: { with_checked_in_users: true }, headers: json_headers }

    it 'returns only events with checked in users' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event3.reload],
          page: 1,
          per_page: 20,
          total_items: 2
        )
      )
    end
  end

  context 'sort by title' do
    before { get url, params: { sort_by: 'title' }, headers: json_headers }

    it 'returns events sorted by title' do
      expect(json).to eq(
        events_index_response(
          [event2.reload, event3.reload, event1.reload],
          page: 1,
          per_page: 20,
          total_items: 3
        )
      )
    end
  end

  context 'sort by reviews_count' do
    before { get url, params: { sort_by: 'reviews_count' }, headers: json_headers }

    it 'returns events sorted by reviews count' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event3.reload, event2.reload],
          page: 1,
          per_page: 20,
          total_items: 3
        )
      )
    end
  end

  context 'sort by average_rating' do
    before { get url, params: { sort_by: 'average_rating' }, headers: json_headers }

    it 'returns events sorted by average rating' do
      expect(json).to eq(
        events_index_response(
          [event1.reload, event3.reload, event2.reload],
          page: 1,
          per_page: 20,
          total_items: 3
        )
      )
    end
  end

  context 'pagination' do
    before { get url, params: { page: 2, per_page: 1 }, headers: json_headers }

    it 'returns events for requested page' do
      expect(json).to eq(
        events_index_response(
          [event2.reload],
          page: 2,
          per_page: 1,
          total_items: 3
        )
      )
    end
  end

  context 'when sort_by is invalid' do
    before { get url, params: { sort_by: 'unknown' }, headers: json_headers }

    it 'returns validation error' do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to eq(failure_response(error_response('sort_by', ['is not included in the list'])))
    end
  end

  context 'when page is invalid' do
    before { get url, params: { page: 0 }, headers: json_headers }

    it 'returns validation error' do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to eq(failure_response(error_response('page', ['must be greater than 0'])))
    end
  end

  context 'when per_page is invalid' do
    before { get url, params: { per_page: 0 }, headers: json_headers }

    it 'returns validation error' do
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to eq(failure_response(error_response('per_page', ['must be greater than 0'])))
    end
  end
end
