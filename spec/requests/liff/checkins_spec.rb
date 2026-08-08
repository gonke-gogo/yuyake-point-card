require "rails_helper"

RSpec.describe "Liff checkins", type: :request do
  def login_as(visitor)
    result = LineIdTokenVerifier::Result.new(success?: true, line_user_id: visitor.line_user_id, display_name: visitor.display_name)
    allow(LineIdTokenVerifier).to receive(:new).and_return(instance_double(LineIdTokenVerifier, call: result))
    post liff_session_path, params: { id_token: "dummy-token" }
  end

  describe "POST /liff/events/:event_id/checkin" do
    it "redirects to the entry (login) page when not logged in" do
      event = create(:event)

      post liff_event_checkin_path(event)

      expect(response).to redirect_to(liff_entry_path)
    end

    it "grants a stamp for a logged-in visitor" do
      visitor = create(:visitor)
      event = create(:event)
      login_as(visitor)

      expect {
        post liff_event_checkin_path(event)
      }.to change { visitor.stamps.count }.by(1)

      expect(response).to redirect_to(liff_mypage_path)
    end

    it "does not grant a second stamp for the same event" do
      visitor = create(:visitor)
      event = create(:event)
      login_as(visitor)
      create(:stamp, visitor: visitor, event: event)

      expect {
        post liff_event_checkin_path(event)
      }.not_to change { visitor.stamps.count }

      follow_redirect!
      expect(response.body).to include("すでにチェックイン済み")
    end
  end

  describe "GET /liff/events/:event_id/checkin/new" do
    it "redirects to the entry (login) page when not logged in" do
      event = create(:event)

      get new_liff_event_checkin_path(event)

      expect(response).to redirect_to(liff_entry_path)
    end

    it "renders the check-in confirmation page for a logged-in visitor" do
      visitor = create(:visitor)
      event = create(:event)
      login_as(visitor)

      get new_liff_event_checkin_path(event)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(event.title)
    end
  end

  describe "location check" do
    let(:visitor) { create(:visitor) }
    let(:event) { create(:event, venue_lat: 36.391208, venue_lng: 139.060406, allowed_radius_meters: 100) }

    before { login_as(visitor) }

    it "grants a stamp and records the check-in location when within the allowed radius" do
      expect {
        post liff_event_checkin_path(event), params: { lat: 36.391208, lng: 139.060406 }
      }.to change { visitor.stamps.count }.by(1)

      stamp = visitor.stamps.last
      expect(stamp.checkin_lat.to_f).to eq(36.391208)
      expect(stamp.checkin_lng.to_f).to eq(139.060406)
      expect(response).to redirect_to(liff_mypage_path)
    end

    it "rejects a check-in far outside the allowed radius" do
      expect {
        # roughly 2km north of the venue
        post liff_event_checkin_path(event), params: { lat: 36.409208, lng: 139.060406 }
      }.not_to change { visitor.stamps.count }

      expect(response).to redirect_to(new_liff_event_checkin_path(event))
      follow_redirect!
      expect(response.body).to include("会場付近でチェックインしてください")
    end

    it "rejects a check-in with no location data when the venue has coordinates configured" do
      expect {
        post liff_event_checkin_path(event)
      }.not_to change { visitor.stamps.count }

      expect(response).to redirect_to(new_liff_event_checkin_path(event))
    end

    it "skips the location check (fail-open) when the event has no venue coordinates" do
      no_coords_event = create(:event, venue_lat: nil, venue_lng: nil)

      expect {
        post liff_event_checkin_path(no_coords_event)
      }.to change { visitor.stamps.count }.by(1)

      expect(response).to redirect_to(liff_mypage_path)
    end
  end
end
