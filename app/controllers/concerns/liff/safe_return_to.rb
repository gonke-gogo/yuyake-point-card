module Liff::SafeReturnTo
  extend ActiveSupport::Concern

  private

  # Only allow redirecting back into our own Liff:: namespace after login,
  # to avoid this becoming an open redirect.
  def safe_return_to(param = params[:return_to])
    param if param.present? && param.start_with?("/liff/")
  end
end
