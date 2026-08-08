require "rails_helper"

RSpec.describe "Admin manual stamp grant", type: :request do
  let(:admin_user) { create(:admin_user) }
  let(:visitor) { create(:visitor, :paper_card) }
  let(:event) { create(:event) }

  before { sign_in admin_user }

  it "grants a stamp and records the granting admin" do
    expect {
      post grant_stamp_admin_visitor_path(visitor), params: { event_id: event.id }
    }.to change { visitor.stamps.count }.by(1)

    stamp = visitor.stamps.last
    expect(stamp.source).to eq("staff_manual")
    expect(stamp.granted_by).to eq(admin_user)
    expect(response).to redirect_to(admin_visitor_path(visitor))
  end

  it "does not grant a second stamp for the same event and shows a friendly error" do
    post grant_stamp_admin_visitor_path(visitor), params: { event_id: event.id }

    expect {
      post grant_stamp_admin_visitor_path(visitor), params: { event_id: event.id }
    }.not_to change { visitor.stamps.count }

    follow_redirect!
    expect(response.body).to include("既にこのイベントでチェックイン済みです")
  end
end
