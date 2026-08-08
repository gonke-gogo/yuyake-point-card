module Liff
  class EntryController < ApplicationController
    include Liff::SafeReturnTo

    layout "liff"

    def show
      @return_to = safe_return_to
    end
  end
end
