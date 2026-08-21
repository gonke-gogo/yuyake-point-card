require "rails_helper"

RSpec.describe "Admin paper card visitor creation", type: :request do
  let(:admin_user) { create(:admin_user) }

  before { sign_in admin_user }

  it "creates a visitor with an auto-assigned card_number and no line_user_id" do
    expect {
      post admin_visitors_path, params: { visitor: { display_name: "紙カード花子" } }
    }.to change(Visitor, :count).by(1)

    visitor = Visitor.last
    expect(visitor.display_name).to eq("紙カード花子")
    expect(visitor.line_user_id).to be_nil
    expect(visitor.card_number).to match(/\A\d{6}\z/)
  end

  it "shows the card number prominently on the visitor page after creation" do
    post admin_visitors_path, params: { visitor: { display_name: "紙カード花子" } }
    visitor = Visitor.last

    expect(response).to redirect_to(admin_visitor_path(visitor))
    follow_redirect!

    expect(response.body).to include(visitor.card_number)
    expect(response.body).to include("card-number-display")
  end

  it "shows the card number in the success flash message" do
    post admin_visitors_path, params: { visitor: { display_name: "紙カード花子" } }
    follow_redirect!

    expect(response.body).to include(Visitor.last.card_number)
    expect(response.body).to include("会員カードを発行しました")
  end

  it "requires a display_name" do
    expect {
      post admin_visitors_path, params: { visitor: { display_name: "" } }
    }.not_to change(Visitor, :count)
  end

  it "assigns unique, incrementing card numbers to successive paper-card visitors" do
    post admin_visitors_path, params: { visitor: { display_name: "一人目" } }
    first = Visitor.last

    post admin_visitors_path, params: { visitor: { display_name: "二人目" } }
    second = Visitor.last

    expect(first.card_number).not_to eq(second.card_number)
    expect(second.card_number.to_i).to be > first.card_number.to_i
  end

  it "ignores a client-submitted card_number/line_user_id on creation (system-assigned only)" do
    post admin_visitors_path, params: {
      visitor: { display_name: "テスト", card_number: "999999", line_user_id: "Uhack" }
    }

    visitor = Visitor.last
    expect(visitor.card_number).not_to eq("999999")
    expect(visitor.line_user_id).to be_nil
  end
end
