require 'rails_helper'

RSpec.describe 'DELETE /events/:id', type: :request do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, owner: user) }

  let(:url) { "/events/#{event.id}" }

  context 'success' do
    it 'returns no content' do
      del_json url

      expect(response).to have_http_status(:no_content)
    end

    it 'deletes event from database' do
      del_json url

      expect(Event.find_by(id: event.id)).to be_nil
    end

    it 'deletes dependent associations' do
      attendee = create(:user)
      sponsor = Sponsor.create!(name: 'Test sponsor', email: 'sponsor@example.com')

      Ticket.create!(event: event, user: attendee, price: 100, status: 'booked')
      EventSponsor.create!(event: event, sponsor: sponsor, amount: 1000)
      Attendance.create!(event: event, user: attendee, checked_in_at: Time.current)
      Review.create!(
        event: event,
        user: attendee,
        review_text: 'Отлично',
        rating: 5,
        status: 'published'
      )

      expect { del_json url }
        .to change { Event.count }.by(-1)
        .and change { Ticket.count }.by(-1)
        .and change { EventSponsor.count }.by(-1)
        .and change { Attendance.count }.by(-1)
        .and change { Review.count }.by(-1)
    end
  end

  context 'when event not found' do
    let(:url) { '/events/999' }

    before { del_json url }

    it 'returns not found' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns error message' do
      expect(json).to eq({ 'error' => 'event not found' })
    end
  end
end
