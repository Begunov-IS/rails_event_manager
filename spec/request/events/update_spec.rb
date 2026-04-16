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

    it 'returns unprocessable entity with errors' do
      put_json url, params: params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json).to eq(
        {
          'errors' => {
            'title' => ["can't be blank"]
          }
        }
      )
    end
  end

  context 'when params are empty' do
    let(:params) { { event: {} } }

    it 'does not change event' do
      initial_attributes = event.reload.attributes.slice(
        'title',
        'location',
        'from_date',
        'to_date',
        'owner_id',
        'category_id',
        'venue_id'
      )

      put_json url, params: params

      expect(response).to have_http_status(:ok)
      expect(event.reload.attributes.slice(
        'title',
        'location',
        'from_date',
        'to_date',
        'owner_id',
        'category_id',
        'venue_id'
      )).to eq(initial_attributes)
    end
  end
end
