# frozen_string_literal: true

module EKDSend
  # Base error class for EKDSend API errors
  class EKDSendError < StandardError
    attr_reader :status_code, :error_code, :request_id

    def initialize(message, status_code = 500, error_code = "UNKNOWN_ERROR", request_id = nil)
      super(message)
      @status_code = status_code
      @error_code = error_code
      @request_id = request_id
    end
  end

  # Raised when authentication fails (401)
  class AuthenticationError < EKDSendError
    def initialize(message, request_id = nil)
      super(message, 401, "AUTHENTICATION_ERROR", request_id)
    end
  end

  # Raised when request validation fails (400)
  class ValidationError < EKDSendError
    attr_reader :errors

    def initialize(message, errors = {}, request_id = nil)
      super(message, 400, "VALIDATION_ERROR", request_id)
      @errors = errors
    end
  end

  # Raised when rate limit is exceeded (429)
  class RateLimitError < EKDSendError
    attr_reader :retry_after

    def initialize(message, retry_after = 60, request_id = nil)
      super(message, 429, "RATE_LIMIT_EXCEEDED", request_id)
      @retry_after = retry_after
    end
  end

  # Raised when resource is not found (404)
  class NotFoundError < EKDSendError
    def initialize(message, error_code = "NOT_FOUND", request_id = nil)
      super(message, 404, error_code, request_id)
    end
  end
end
