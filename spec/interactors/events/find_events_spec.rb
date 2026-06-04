require 'rails_helper'

RSpec.describe Events::FindEvents do
  let!(:moscow_venue) { create(:venue, city: 'Moscow') }
  let!(:spb_venue) { create(:venue, city: 'Saint Petersburg') }
  let!(:music_category) { create(:category) }
  let!(:tech_category) { create(:category) }
  let!(:owner) { create(:user) }

  let!(:matching_event) do
    create(:event, category: music_category, owner: owner, venue: moscow_venue, from_date: 1.day.from_now, to_date: 2.days.from_now)
  end

  let!(:other_event) do
    create(:event, category: tech_category, venue: spb_venue, from_date: 3.days.from_now, to_date: 4.days.from_now)
  end

  it 'returns events matching the requested filters' do
    result = described_class.run!(
      category_ids: [ music_category.id ],
      city: 'Moscow',
      owner_id: owner.id,
      from_date: matching_event.from_date - 1.hour,
      to_date: matching_event.to_date + 1.hour
    )

    expect(result).to contain_exactly(matching_event)
  end

  it 'ignores filters that are not provided' do
    result = described_class.run!

    expect(result).to contain_exactly(matching_event, other_event)
  end
end
