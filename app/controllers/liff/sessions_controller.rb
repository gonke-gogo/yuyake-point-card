module Liff
  class SessionsController < ApplicationController
    include Liff::SafeReturnTo

    layout "liff"

    def create
      result = LineIdTokenVerifier.new.call(params[:id_token])

      if result.success?
        visitor = find_or_create_visitor(result)
        session[:visitor_id] = visitor.id
        redirect_to(safe_return_to || liff_mypage_path)
      else
        redirect_to liff_entry_path, alert: "ログインに失敗しました。もう一度お試しください。"
      end
    end

    private

    def find_or_create_visitor(result)
      visitor = Visitor.find_or_initialize_by(line_user_id: result.line_user_id)
      # LINE only includes "name" in the ID token when the profile scope was
      # granted; fall back to a generic label rather than fail the login.
      visitor.display_name = result.display_name.presence || visitor.display_name.presence || "ゲスト"
      visitor.avatar_url = result.avatar_url
      visitor.save!
      visitor
    end
  end
end
