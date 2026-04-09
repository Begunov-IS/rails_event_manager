require 'rails_helper'

RSpec.describe 'DELETE /events/:id', type: :request do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, owner: user) }

  let(:url) { "/events/#{event.id}" }

  context 'success' do
    before { del_json url }

    it 'returns no content' do
      expect(response).to have_http_status(:no_content)
    end

    it 'deletes event from database' do
      expect(Event.find_by(id: event.id)).to be_nil
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
