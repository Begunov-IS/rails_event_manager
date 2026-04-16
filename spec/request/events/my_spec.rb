require 'rails_helper'

RSpec.describe 'GET /events/my', type: :request do
  let!(:user) { create(:user) }
  let!(:another_user) { create(:user) }
  let!(:user_event) { create(:event, owner: user) }
  let!(:another_user_event) { create(:event, owner: another_user) }

  let(:url) { '/events/my' }

  context 'when user authenticated' do
    before { get url, headers: json_headers.merge('X-User-Id' => user.id.to_s) }

    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns only current user events' do
      expect(json).to eq([event_base_response(user_event.reload)])
    end
  end

  context 'when user is not authenticated' do
    before { get url, headers: json_headers }

    it 'returns unauthorized' do
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns error message' do
      expect(json).to eq({ 'error' => 'unauthorized' })
    end
  end
end
