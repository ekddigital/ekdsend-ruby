# frozen_string_literal: true

module EKDSend
  module Resources
    # Voice API resource
    class Voice
      def initialize(client)
        @client = client
      end

      # Create a voice call
      #
      # @param to [String] Recipient phone number (E.164 format)
      # @param from [String] Caller ID phone number (must be verified)
      # @param tts_message [String] Text-to-speech message (optional)
      # @param audio_url [String] URL to audio file (optional)
      # @param voice [String] TTS voice (alloy, echo, fable, onyx, nova, shimmer)
      # @param language [String] TTS language code (default: en-US)
      # @param record [Boolean] Enable call recording (default: false)
      # @param machine_detection [Boolean] Enable machine detection (default: false)
      # @param webhook_url [String] URL for call status callbacks (optional)
      # @param metadata [Hash] Custom metadata (optional)
      # @return [Hash] VoiceCall object with id and status
      def create(to:, from:, tts_message: nil, audio_url: nil, voice: "alloy", language: "en-US",
                 record: false, machine_detection: false, webhook_url: nil, metadata: nil)
        raise ArgumentError, "Either tts_message or audio_url is required" if tts_message.nil? && audio_url.nil?

        payload = {
          to: to,
          from: from,
          voice: voice,
          language: language,
          record: record,
          machine_detection: machine_detection
        }

        payload[:tts_message] = tts_message if tts_message
        payload[:audio_url] = audio_url if audio_url
        payload[:webhook_url] = webhook_url if webhook_url
        payload[:metadata] = metadata if metadata

        response = @client.request(:post, "/calls", payload)
        response[:data]
      end

      # Get a call by ID
      #
      # @param call_id [String] The call ID to retrieve
      # @return [Hash] VoiceCall object
      def get(call_id)
        response = @client.request(:get, "/calls/#{call_id}")
        response[:data]
      end

      # List calls with pagination and filtering
      #
      # @param limit [Integer] Number of calls to return (max 100)
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

        @client.request(:get, "/calls", params)
      end

      # Hang up an active call
      #
      # @param call_id [String] The call ID to hang up
      # @return [Hash] Updated VoiceCall object
      def hangup(call_id)
        response = @client.request(:delete, "/calls/#{call_id}")
        response[:data]
      end

      # Get recording for a call
      #
      # @param call_id [String] The call ID
      # @return [Hash] Recording object with :url, :duration, :created_at
      def get_recording(call_id)
        response = @client.request(:get, "/calls/#{call_id}/recording")
        response[:data]
      end
    end
  end
end
