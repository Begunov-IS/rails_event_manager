require 'rails_helper'

RSpec.describe 'GET /events/:id', type: :request do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, owner: user) }

  let(:url) { "/events/#{event.id}" }

  context 'success' do
    before { get url, headers: json_headers }

    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns event' do
      expect(json).to eq(event_base_response(event.reload))
    end
  end

  context 'when event not found' do
    let(:url) { '/events/999' }

    before { get url, headers: json_headers }

    it 'returns not found' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns error message' do
      expect(json).to eq({ 'error' => 'event not found' })
    end
  end
end
