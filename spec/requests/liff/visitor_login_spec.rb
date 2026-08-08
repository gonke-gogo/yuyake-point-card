require "rails_helper"

RSpec.describe "Liff visitor login flow", type: :request do
  def stub_verifier(result)
    verifier = instance_double(LineIdTokenVerifier, call: result)
    allow(LineIdTokenVerifier).to receive(:new).and_return(verifier)
  end

  it "logs the visitor in via a verified LINE ID token and reaches mypage" do
    get liff_entry_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("liff-bootstrap")

    stub_verifier(LineIdTokenVerifier::Result.new(
      success?: true,
      line_user_id: "U123456",
      display_name: "テスト太郎",
      avatar_url: "https://example.com/avatar.png",
    ))

    post liff_session_path, params: { id_token: "dummy-token" }

    expect(response).to redirect_to(liff_mypage_path)
    expect(Visitor.find_by(line_user_id: "U123456")).to be_present

    follow_redirect!
    expect(response).to have_http_status(:ok)
    expect(response.body).to include("マイページ")
  end

  it "honors a whitelisted return_to after login" do
    event = create(:event)
    stub_verifier(LineIdTokenVerifier::Result.new(success?: true, line_user_id: "U999", display_name: "太郎"))

    post liff_session_path, params: { id_token: "dummy-token", return_to: liff_event_checkin_path(event) }

    expect(response).to redirect_to(liff_event_checkin_path(event))
  end

  it "ignores an off-site return_to (no open redirect)" do
    stub_verifier(LineIdTokenVerifier::Result.new(success?: true, line_user_id: "U999", display_name: "太郎"))

    post liff_session_path, params: { id_token: "dummy-token", return_to: "https://evil.example.com" }

    expect(response).to redirect_to(liff_mypage_path)
  end

  it "redirects back to entry with an error when verification fails" do
    stub_verifier(LineIdTokenVerifier::Result.new(success?: false, error: "verification_failed"))

    post liff_session_path, params: { id_token: "bad-token" }

    expect(response).to redirect_to(liff_entry_path)
    follow_redirect!
    expect(response.body).to include("ログインに失敗しました")
  end
end
