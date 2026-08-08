module Liff
  class BaseController < ApplicationController
    layout "liff"

    before_action :require_visitor_session!

    private

    def current_visitor
      @current_visitor ||= Visitor.find_by(id: session[:visitor_id])
    end
    helper_method :current_visitor

    def require_visitor_session!
      redirect_to liff_entry_path unless current_visitor
    end
  end
end
