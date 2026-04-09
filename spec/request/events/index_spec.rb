require 'rails_helper'

RSpec.describe 'GET /events', type: :request do
  let!(:category) { create(:category) }
  let!(:user) { create(:user) }
  let!(:event1) { create(:event, owner: user, category: category, from_date: 3.days.from_now, to_date: 3.days.from_now + 2.hours) }
  let!(:event2) { create(:event, owner: user, category: nil, from_date: 10.days.from_now, to_date: 10.days.from_now + 2.hours) }

  let(:url) { '/events' }

  context 'success' do
    before { get url, headers: json_headers }

    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all events' do
      expect(json.size).to eq(2)
    end
  end

  context 'filter by category_id' do
    before { get "#{url}?category_id=#{category.id}", headers: json_headers }

    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns filtered events' do
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(event1.id)
    end
  end

  context 'filter by from_date' do
    before { get "#{url}?from_date=#{5.days.from_now.iso8601}", headers: json_headers }

    it 'returns only events after the date' do
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(event2.id)
    end
  end

  context 'filter by from_date and to_date' do
    before { get "#{url}?from_date=#{1.day.from_now.iso8601}&to_date=#{5.days.from_now.iso8601}", headers: json_headers }

    it 'returns events within range' do
      expect(json.size).to eq(1)
      expect(json.first['id']).to eq(event1.id)
    end
  end
end
