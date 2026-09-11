require "rails_helper"

RSpec.describe SunsetInfoFetcher do
  subject(:fetcher) { described_class.new(lat: 36.39, lng: 139.06, date: Date.new(2026, 9, 8)) }

  describe "#call" do
    it "returns sunset and dusk times when the API succeeds" do
      stub_request(:get, SunsetInfoFetcher::API_URL)
        .with(query: hash_including(lat: "36.39", lng: "139.06", date: "2026-09-08"))
        .to_return(
          status: 200,
          body: {
            results: {
              sunset: "2026-09-08T09:23:00+00:00",
              civil_twilight_end: "2026-09-08T09:52:00+00:00"
            },
            status: "OK"
          }.to_json,
        )

      result = fetcher.call

      expect(result).to be_success
      expect(result.sunset_at).to eq(Time.zone.parse("2026-09-08T09:23:00+00:00"))
      expect(result.dusk_at).to eq(Time.zone.parse("2026-09-08T09:52:00+00:00"))
    end

    it "returns a failed result when the HTTP request fails" do
      stub_request(:get, SunsetInfoFetcher::API_URL)
        .with(query: hash_including(date: "2026-09-08"))
        .to_return(status: 500)

      result = fetcher.call

      expect(result).not_to be_success
    end

    it "returns a failed result when the API reports an error status" do
      stub_request(:get, SunsetInfoFetcher::API_URL)
        .with(query: hash_including(date: "2026-09-08"))
        .to_return(status: 200, body: { status: "INVALID_REQUEST" }.to_json)

      result = fetcher.call

      expect(result).not_to be_success
    end

    it "returns a failed result when the connection raises" do
      stub_request(:get, SunsetInfoFetcher::API_URL)
        .with(query: hash_including(date: "2026-09-08"))
        .to_raise(Faraday::ConnectionFailed)

      result = fetcher.call

      expect(result).not_to be_success
    end
  end
end
