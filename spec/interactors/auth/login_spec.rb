require "rails_helper"

RSpec.describe Auth::Login do
  let!(:user) { create(:user, email: "ivan@example.com", password: "password123") }

  it "returns user and token when credentials are valid" do
    result = described_class.run!(email: "ivan@example.com", password: "password123")

    expect(result[:user]).to eq(user)
    expect(result[:token]).to be_present
  end

  it "adds an error when credentials are invalid" do
    outcome = described_class.run(email: "ivan@example.com", password: "wrong-password")

    expect(outcome.errors.full_messages).to include("invalid email or password")
  end
end
