require "rails_helper"

RSpec.describe "POST /login", type: :request do
  let!(:user) { create(:user, email: "ivan@example.com", password: "password123") }
  let(:url) { "/login" }

  context "success" do
    before do
      post_json url, params: {
        email: "ivan@example.com",
        password: "password123"
      }
    end

    it "returns ok" do
      expect(response).to have_http_status(:ok)
    end

    it "returns access token and user" do
      expect(json.fetch("success")).to eq(true)
      expect(json.fetch("token")).to be_present
      expect(json.fetch("user")).to eq(
        {
          "id" => user.id,
          "name" => user.name,
          "email" => "ivan@example.com"
        }
      )
    end
  end

  context "when password is invalid" do
    before do
      post_json url, params: {
        email: "ivan@example.com",
        password: "wrong-password"
      }
    end

    it "returns unauthorized" do
      expect(response).to have_http_status(:unauthorized)
    end

    it "returns error message" do
      expect(json).to eq(
        {
          success: false,
          errors: [
            {
              key: "base",
              messages: [ "invalid email or password" ]
            }
          ]
        }.as_json
      )
    end
  end

  context "when email is unknown" do
    before do
      post_json url, params: {
        email: "unknown@example.com",
        password: "password123"
      }
    end

    it "returns unauthorized" do
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
