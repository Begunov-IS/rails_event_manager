require 'rails_helper'

RSpec.describe Events::SortPaginate do
  let!(:later_event) { create(:event, title: 'Bravo', from_date: 2.days.from_now) }
  let!(:earlier_event) { create(:event, title: 'Alpha', from_date: 1.day.from_now) }

  it 'sorts events with the method matching sort_by and returns pagination info' do
    result = described_class.run!(
      events: Event.all,
      sort_by: 'title',
      page: 1,
      per_page: 1
    )

    expect(result[:events]).to contain_exactly(earlier_event)
    expect(result[:pagination_info]).to eq(
      page: 1,
      per_page: 1,
      total_items: 2
    )
  end
end
