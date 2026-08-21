module Liff
  # NFC-tag entry point that doesn't hardcode an event: resolves "today's"
  # published event and hands off to the per-event checkin flow, so the
  # physical tag URL never needs to change between events.
  class CheckinController < Liff::BaseController
    def show
      event = Event.published.where(held_on: Date.current).order(created_at: :desc).first

      if event
        redirect_to new_liff_event_checkin_path(event)
      else
        redirect_to liff_mypage_path, alert: "本日開催中のイベントが見つかりませんでした。会場スタッフにお声がけください。"
      end
    end
  end
end
