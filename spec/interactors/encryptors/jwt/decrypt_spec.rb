require "rails_helper"

RSpec.describe Encryptors::Jwt::Decrypt do
  it "returns decoded payload for valid token" do
    token = Encryptors::Jwt::Encrypt.run!(payload: { user_id: 123 })

    result = described_class.run!(token: token)

    expect(result.fetch("user_id")).to eq(123)
  end

  it "adds an error for invalid token" do
    outcome = described_class.run(token: "invalid-token")

    expect(outcome.errors).to be_present
    expect(outcome.errors.full_messages).to include("Token is invalid")
  end
end
