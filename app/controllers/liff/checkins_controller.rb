module Liff
  class CheckinsController < Liff::BaseController
    def new
      @event = Event.find(params[:event_id])
    end

    def create
      event = Event.find(params[:event_id])

      unless event.within_venue_radius?(params[:lat], params[:lng])
        redirect_to new_liff_event_checkin_path(event), alert: "会場付近でチェックインしてください"
        return
      end

      stamp = current_visitor.stamps.new(
        event: event,
        checked_in_at: Time.current,
        source: :line_checkin,
        checkin_lat: params[:lat],
        checkin_lng: params[:lng],
      )

      if stamp.save
        flash[:stamp_acquired] = true
        redirect_to liff_mypage_path, notice: "チェックインしました"
      else
        redirect_to liff_mypage_path, alert: "本日はすでにチェックイン済みです"
      end
    rescue ActiveRecord::RecordNotUnique
      redirect_to liff_mypage_path, alert: "本日はすでにチェックイン済みです"
    end
  end
end
