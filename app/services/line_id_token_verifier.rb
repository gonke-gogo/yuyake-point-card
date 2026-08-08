# Verifies a LIFF-issued LINE ID token by calling LINE's verify endpoint.
# https://developers.line.biz/en/reference/line-login/#verify-id-token
class LineIdTokenVerifier
  VERIFY_URL = "https://api.line.me/oauth2/v2.1/verify"

  Result = Struct.new(:success?, :line_user_id, :display_name, :avatar_url, :error, keyword_init: true)

  def initialize(channel_id: Rails.application.credentials.dig(:line, :channel_id))
    @channel_id = channel_id
  end

  def call(id_token)
    return Result.new(success?: false, error: "blank_token") if id_token.blank?

    response = connection.post(VERIFY_URL) do |req|
      req.body = { id_token: id_token, client_id: channel_id }
    end

    return Result.new(success?: false, error: "verification_failed") unless response.success?

    payload = JSON.parse(response.body)
    Result.new(
      success?: true,
      line_user_id: payload["sub"],
      display_name: payload["name"],
      avatar_url: payload["picture"],
    )
  rescue Faraday::Error, JSON::ParserError
    Result.new(success?: false, error: "verification_error")
  end

  private

  attr_reader :channel_id

  def connection
    Faraday.new do |f|
      f.request :url_encoded
      f.adapter Faraday.default_adapter
    end
  end
end
