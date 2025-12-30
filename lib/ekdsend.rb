# frozen_string_literal: true

require_relative "ekdsend/version"
require_relative "ekdsend/client"
require_relative "ekdsend/errors"
require_relative "ekdsend/resources/emails"
require_relative "ekdsend/resources/sms"
require_relative "ekdsend/resources/voice"

module EKDSend
  class << self
    # Create a new EKDSend client
    #
    # @param api_key [String] Your EKDSend API key
    # @param options [Hash] Configuration options
    # @return [EKDSend::Client]
    def new(api_key, **options)
      Client.new(api_key, **options)
    end
  end
end
