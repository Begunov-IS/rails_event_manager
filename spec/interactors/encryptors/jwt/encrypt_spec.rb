require "rails_helper"

RSpec.describe Encryptors::Jwt::Encrypt do
  it "returns a JWT token for payload" do
    token = described_class.run!(payload: { user_id: 123 })

    expect(token).to be_present
    expect(token.split(".").size).to eq(3)
  end
end
