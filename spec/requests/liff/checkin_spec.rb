require "rails_helper"

RSpec.describe "Liff today's-event checkin resolver", type: :request do
  def login_as(visitor)
    result = LineIdTokenVerifier::Result.new(success?: true, line_user_id: visitor.line_user_id, display_name: visitor.display_name)
    allow(LineIdTokenVerifier).to receive(:new).and_return(instance_double(LineIdTokenVerifier, call: result))
    post liff_session_path, params: { id_token: "dummy-token" }
  end

  describe "GET /liff/checkin" do
    it "redirects to the entry (login) page when not logged in" do
      get liff_checkin_path

      expect(response).to redirect_to(liff_entry_path)
    end

    it "redirects into today's published event's checkin flow" do
      visitor = create(:visitor)
      today_event = create(:event, held_on: Date.current, status: :published)
      login_as(visitor)

      get liff_checkin_path

      expect(response).to redirect_to(new_liff_event_checkin_path(today_event))
    end

    it "ignores events held on other days" do
      visitor = create(:visitor)
      create(:event, held_on: Date.yesterday, status: :published)
      login_as(visitor)

      get liff_checkin_path

      expect(response).to redirect_to(liff_mypage_path)
      follow_redirect!
      expect(response.body).to include("本日開催中のイベント")
    end

    it "ignores draft events even if held today" do
      visitor = create(:visitor)
      create(:event, held_on: Date.current, status: :draft)
      login_as(visitor)

      get liff_checkin_path

      expect(response).to redirect_to(liff_mypage_path)
    end

    it "picks the most recently created event when several are published today" do
      visitor = create(:visitor)
      create(:event, held_on: Date.current, status: :published)
      newer_event = create(:event, held_on: Date.current, status: :published)
      login_as(visitor)

      get liff_checkin_path

      expect(response).to redirect_to(new_liff_event_checkin_path(newer_event))
    end
  end
end
