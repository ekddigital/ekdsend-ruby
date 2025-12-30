# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "json"

module EKDSend
  # Main client for interacting with the EKDSend API
  class Client
    DEFAULT_BASE_URL = "https://es.ekddigital.com/v1"
    DEFAULT_TIMEOUT = 30
    DEFAULT_MAX_RETRIES = 3

    attr_reader :emails, :sms, :calls

    # Initialize a new EKDSend client
    #
    # @param api_key [String] Your EKDSend API key (ek_live_xxx or ek_test_xxx)
    # @param base_url [String] API base URL (optional)
    # @param timeout [Integer] Request timeout in seconds (optional)
    # @param max_retries [Integer] Maximum retry attempts (optional)
    # @param debug [Boolean] Enable debug logging (optional)
    def initialize(api_key, base_url: DEFAULT_BASE_URL, timeout: DEFAULT_TIMEOUT, max_retries: DEFAULT_MAX_RETRIES, debug: false)
      raise ArgumentError, "API key is required" if api_key.nil? || api_key.empty?

      unless api_key.start_with?("ek_live_") || api_key.start_with?("ek_test_")
        raise ArgumentError, "Invalid API key format. Must start with 'ek_live_' or 'ek_test_'"
      end

      @api_key = api_key
      @base_url = base_url.chomp("/")
      @timeout = timeout
      @max_retries = max_retries
      @debug = debug

      @connection = build_connection

      # Initialize API resources
      @emails = Resources::Emails.new(self)
      @sms = Resources::SMS.new(self)
      @calls = Resources::Voice.new(self)
    end

    # Make an HTTP request to the API
    #
    # @param method [Symbol] HTTP method (:get, :post, :delete)
    # @param path [String] API endpoint path
    # @param params [Hash] Query parameters for GET, body for POST
    # @return [Hash] Parsed response data
    def request(method, path, params = {})
      log_request(method, path, params) if @debug

      response = case method
                 when :get
                   @connection.get(path, params)
                 when :post
                   @connection.post(path) do |req|
                     req.body = params.to_json
                   end
                 when :delete
                   @connection.delete(path)
                 end

      handle_response(response)
    rescue Faraday::Error => e
      handle_faraday_error(e)
    end

    private

    def build_connection
      Faraday.new(url: @base_url) do |conn|
        conn.request :retry, max: @max_retries, interval: 0.5, backoff_factor: 2,
                             retry_statuses: [429, 500, 502, 503, 504],
                             retry_if: ->(env, _exception) { should_retry?(env) }

        conn.headers["Authorization"] = "Bearer #{@api_key}"
        conn.headers["Content-Type"] = "application/json"
        conn.headers["Accept"] = "application/json"
        conn.headers["User-Agent"] = "ekdsend-ruby/#{VERSION}"

        conn.options.timeout = @timeout
        conn.adapter Faraday.default_adapter
      end
    end

    def should_retry?(env)
      return false if env.status == 401 || env.status == 400
      true
    end

    def handle_response(response)
      request_id = response.headers["x-request-id"]
      body = parse_body(response.body)

      log_response(response.status, body) if @debug

      unless response.success?
        handle_error(response.status, body, request_id)
      end

      body
    end

    def parse_body(body)
      return {} if body.nil? || body.empty?
      JSON.parse(body, symbolize_names: true)
    rescue JSON::ParserError
      {}
    end

    def handle_error(status, body, request_id)
      error = body[:error] || {}
      message = error[:message] || "API request failed"
      code = error[:code] || "UNKNOWN_ERROR"

      case status
      when 400
        raise ValidationError.new(message, error[:details] || {}, request_id)
      when 401
        raise AuthenticationError.new(message, request_id)
      when 404
        raise NotFoundError.new(message, code, request_id)
      when 429
        retry_after = (error[:retry_after] || 60).to_i
        raise RateLimitError.new(message, retry_after, request_id)
      else
        raise EKDSendError.new(message, status, code, request_id)
      end
    end

    def handle_faraday_error(error)
      raise EKDSendError.new(error.message, 500, "CONNECTION_ERROR")
    end

    def log_request(method, path, params)
      puts "[EKDSend] #{method.upcase} #{path}"
      puts "[EKDSend] Request: #{params.to_json}" unless params.empty?
    end

    def log_response(status, body)
      puts "[EKDSend] Response (#{status}): #{body.to_json}"
    end
  end
end
