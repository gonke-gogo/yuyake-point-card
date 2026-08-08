module Liff
  class MypageController < Liff::BaseController
    def show
      @stamps = current_visitor.stamps.includes(:event).order(checked_in_at: :desc)
      @rank = current_visitor.rank
      @next_rank = Rank.ordered.where("min_stamps > ?", @stamps.size).first
    end
  end
end
