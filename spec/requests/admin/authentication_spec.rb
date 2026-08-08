require "rails_helper"

RSpec.describe "Admin authentication", type: :request do
  it "redirects unauthenticated visitors from /admin to the Devise login page" do
    get "/admin"

    expect(response).to redirect_to("/admin/login")
  end

  it "redirects unauthenticated visitors from admin resource pages too" do
    get "/admin/visitors"

    expect(response).to redirect_to("/admin/login")
  end
end
