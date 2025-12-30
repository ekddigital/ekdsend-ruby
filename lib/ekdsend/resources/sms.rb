# frozen_string_literal: true

module EKDSend
  module Resources
    # SMS API resource
    class SMS
      def initialize(client)
        @client = client
      end

      # Send an SMS message
      #
      # @param to [String] Recipient phone number (E.164 format: +1234567890)
      # @param message [String] SMS message content (max 1600 chars)
      # @param from [String] Sender phone number (optional)
      # @param scheduled_at [String] ISO8601 timestamp for scheduling (optional)
      # @param webhook_url [String] URL for delivery callbacks (optional)
      # @param metadata [Hash] Custom metadata (optional)
      # @return [Hash] SMS object with id and status
      def send(to:, message:, from: nil, scheduled_at: nil, webhook_url: nil, metadata: nil)
        payload = {
          to: to,
          message: message
        }

        payload[:from] = from if from
        payload[:scheduled_at] = scheduled_at if scheduled_at
        payload[:webhook_url] = webhook_url if webhook_url
        payload[:metadata] = metadata if metadata

        response = @client.request(:post, "/sms", payload)
        response[:data]
      end

      # Get an SMS by ID
      #
      # @param sms_id [String] The SMS ID to retrieve
      # @return [Hash] SMS object
      def get(sms_id)
        response = @client.request(:get, "/sms/#{sms_id}")
        response[:data]
      end

      # List SMS messages with pagination and filtering
      #
      # @param limit [Integer] Number of messages to return (max 100)
      # @param offset [Integer] Pagination offset
      # @param status [String] Filter by status (optional)
      # @param from_date [String] Filter from date ISO8601 (optional)
      # @param to_date [String] Filter to date ISO8601 (optional)
      # @return [Hash] Paginated list with :data, :total, :limit, :offset
      def list(limit: 20, offset: 0, status: nil, from_date: nil, to_date: nil)
        params = {
          limit: limit,
          offset: offset
        }

        params[:status] = status if status
        params[:from_date] = from_date if from_date
        params[:to_date] = to_date if to_date

        @client.request(:get, "/sms", params)
      end

      # Cancel a scheduled SMS
      #
      # @param sms_id [String] The SMS ID to cancel
      # @return [Hash] Updated SMS object
      def cancel(sms_id)
        response = @client.request(:delete, "/sms/#{sms_id}")
        response[:data]
      end
    end
  end
end
