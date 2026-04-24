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
    it 'returns created' do
      post_json url, params: params

      expect(response).to have_http_status(:created)
    end

    it 'returns event' do
      post_json url, params: params

      event = Event.last
      expect(json).to eq(success_response(:event, event_base_response(event)))
    end

    it 'creates event in database' do
      expect { post_json url, params: params }.to change { Event.count }.by(1)
    end
  end

  context 'when params invalid' do
    let(:params) { { event: { title: '', location: '' } } }

    it 'returns unprocessable entity with errors' do
      post_json url, params: params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to eq(
        failure_response(
          error_response('from_date', ['is required']),
          error_response('to_date', ['is required']),
          error_response('owner_id', ['is required'])
        )
      )
    end
  end
end
