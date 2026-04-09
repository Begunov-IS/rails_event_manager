require 'rails_helper'

RSpec.describe 'PATCH /events/:id', type: :request do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, owner: user) }

  let(:url) { "/events/#{event.id}" }

  let(:params) do
    {
      event: {
        title: 'Новое название'
      }
    }
  end

  context 'success' do
    before { put_json url, params: params }

    it 'returns ok' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns updated event' do
      expect(json['title']).to eq('Новое название')
    end

    it 'updates event in database' do
      expect(event.reload.title).to eq('Новое название')
    end
  end

  context 'when event not found' do
    let(:url) { '/events/999' }

    before { put_json url, params: params }

    it 'returns not found' do
      expect(response).to have_http_status(:not_found)
    end

    it 'returns error message' do
      expect(json).to eq({ 'error' => 'event not found' })
    end
  end

  context 'when params invalid' do
    let(:params) { { event: { title: '' } } }

    before { put_json url, params: params }

    it 'returns unprocessable entity' do
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns errors' do
      expect(json).to have_key('errors')
    end
  end
end
