# Fetches today's sunset / dusk time for a given location via the free
# sunrise-sunset.org API, cached for a day since the value only changes once
# per day. Used to drive the mypage sunset visual effect.
class SunsetInfoFetcher
  API_URL = "https://api.sunrise-sunset.org/json"

  Result = Struct.new(:success?, :sunset_at, :dusk_at, :error, keyword_init: true)

  def initialize(lat:, lng:, date: Date.current)
    @lat = lat
    @lng = lng
    @date = date
  end

  def call
    Rails.cache.fetch(cache_key, expires_in: 24.hours) { fetch }
  end

  private

  attr_reader :lat, :lng, :date

  def fetch
    response = connection.get(API_URL, lat: lat, lng: lng, date: date.iso8601, formatted: 0)
    return Result.new(success?: false, error: "fetch_failed") unless response.success?

    payload = JSON.parse(response.body)
    return Result.new(success?: false, error: "api_error") unless payload["status"] == "OK"

    results = payload["results"]
    Result.new(
      success?: true,
      sunset_at: Time.zone.parse(results["sunset"]),
      dusk_at: Time.zone.parse(results["civil_twilight_end"]),
    )
  rescue Faraday::Error, JSON::ParserError
    Result.new(success?: false, error: "fetch_error")
  end

  def cache_key
    "sunset_info:#{date.iso8601}:#{lat.to_f.round(2)}:#{lng.to_f.round(2)}"
  end

  def connection
    Faraday.new do |f|
      f.options.open_timeout = 2
      f.options.timeout = 3
      f.adapter Faraday.default_adapter
    end
  end
end
