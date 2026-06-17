require "rails_helper"

RSpec.describe "POST /register", type: :request do
  let(:url) { "/register" }
  let(:params) do
    {
      user: {
        name: "Ivan",
        email: "ivan@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    }
  end

  context "success" do
    it "returns created" do
      post_json url, params: params

      expect(response).to have_http_status(:created)
    end

    it "creates user in database" do
      expect { post_json url, params: params }.to change { User.count }.by(1)
    end

    it "returns created user without password fields" do
      post_json url, params: params

      user = User.last
      expect(json).to eq(
        {
          success: true,
          user: {
            id: user.id,
            name: "Ivan",
            email: "ivan@example.com"
          }
        }.as_json
      )
    end
  end

  context "when params are invalid" do
    let(:params) do
      {
        user: {
          name: "",
          email: "",
          password: "password123",
          password_confirmation: "different"
        }
      }
    end

    it "returns validation errors" do
      post_json url, params: params

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json.fetch("success")).to eq(false)
      expect(json.fetch("errors")).to include(
        {
          "key" => "name",
          "messages" => [ "Name can't be blank" ]
        },
        {
          "key" => "email",
          "messages" => [ "Email can't be blank" ]
        },
        {
          "key" => "password_confirmation",
          "messages" => [ "Password confirmation doesn't match Password" ]
        }
      )
    end
  end
end
