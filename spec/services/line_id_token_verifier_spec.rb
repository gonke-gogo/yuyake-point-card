require "rails_helper"

RSpec.describe LineIdTokenVerifier do
  subject(:verifier) { described_class.new(channel_id: "test-channel-id") }

  describe "#call" do
    it "returns a successful result when LINE verifies the token" do
      stub_request(:post, LineIdTokenVerifier::VERIFY_URL)
        .with(body: hash_including(id_token: "valid-token", client_id: "test-channel-id"))
        .to_return(
          status: 200,
          body: { sub: "U123", name: "テスト太郎", picture: "https://example.com/avatar.png" }.to_json,
        )

      result = verifier.call("valid-token")

      expect(result).to be_success
      expect(result.line_user_id).to eq("U123")
      expect(result.display_name).to eq("テスト太郎")
      expect(result.avatar_url).to eq("https://example.com/avatar.png")
    end

    it "returns a failed result when LINE rejects the token" do
      stub_request(:post, LineIdTokenVerifier::VERIFY_URL)
        .to_return(status: 400, body: { error: "invalid_request" }.to_json)

      result = verifier.call("invalid-token")

      expect(result).not_to be_success
    end

    it "returns a failed result for a blank token without calling LINE" do
      result = verifier.call("")

      expect(result).not_to be_success
      expect(a_request(:post, LineIdTokenVerifier::VERIFY_URL)).not_to have_been_made
    end
  end
end
