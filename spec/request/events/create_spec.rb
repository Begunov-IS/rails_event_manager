require 'rails_helper'

RSpec.describe 'POST /events', type: :request do
  let!(:user) { create(:user) }
  let(:url) { '/events' }

  let(:params) do
    {
      event: {
        title: Faker::Lorem.sentence(word_count: 3),
        location: Faker::Address.city,
        from_date: 2.days.from_now,
        to_date: 2.days.from_now + 3.hours,
        owner_id: user.id
      }
    }
  end

  context 'success' do
    before { post_json url, params: params }

    it 'returns created' do
      expect(response).to have_http_status(:created)
    end

    it 'returns event' do
      event = Event.last
      expect(json).to eq(event_base_response(event))
    end

    it 'creates event in database' do
      expect(Event.count).to eq(1)
    end
  end

  context 'when params invalid' do
    let(:params) { { event: { title: '', location: '' } } }

    before { post_json url, params: params }

    it 'returns unprocessable entity' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns errors' do
      expect(json).to have_key('errors')
    end
  end
end
