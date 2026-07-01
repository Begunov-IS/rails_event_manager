require "rails_helper"

RSpec.describe Auth::Register do
  it "creates a user from valid inputs" do
    result = described_class.run!(
      name: "Ivan",
      email: "ivan@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    expect(result).to be_persisted
    expect(result.email).to eq("ivan@example.com")
  end
end
