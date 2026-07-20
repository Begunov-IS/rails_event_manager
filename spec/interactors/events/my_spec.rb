require 'rails_helper'

RSpec.describe 'Events::My' do
  describe '.run!' do
    let(:user) { create(:user) }
    let(:another_user) { create(:user) }
    let(:category) { create(:category) }
    let(:venue) { create(:venue) }
    let!(:user_event) { create(:event, owner: user, category: category, venue: venue) }
    let!(:another_user_event) { create(:event, owner: another_user) }

    it 'returns current user events with associations needed for rendering' do
      expect(Events.const_defined?(:My, false)).to eq(true)

      events = Events::My.run!(user: user).to_a

      expect(events).to eq([user_event])
      expect(events.first.association(:owner)).to be_loaded
      expect(events.first.association(:category)).to be_loaded
      expect(events.first.association(:venue)).to be_loaded
    end
  end
end
