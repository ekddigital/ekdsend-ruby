# frozen_string_literal: true

module EKDSend
  module Resources
    # Email API resource
    class Emails
      def initialize(client)
        @client = client
      end

      # Send an email
      #
      # @param from [String] Sender email address (must be verified)
      # @param to [String, Array<String>] Recipient email(s)
      # @param subject [String] Email subject line
      # @param html [String] HTML content (optional)
      # @param text [String] Plain text content (optional)
      # @param cc [String, Array<String>] CC recipient(s) (optional)
      # @param bcc [String, Array<String>] BCC recipient(s) (optional)
      # @param reply_to [String] Reply-to address (optional)
      # @param attachments [Array<Hash>] Attachments (optional)
      # @param headers [Hash] Custom email headers (optional)
      # @param tags [Array<String>] Tags for categorization (optional)
      # @param metadata [Hash] Custom metadata (optional)
      # @param scheduled_at [String] ISO8601 timestamp for scheduling (optional)
      # @return [Hash] Email object with id and status
      def send(from:, to:, subject:, html: nil, text: nil, cc: nil, bcc: nil, reply_to: nil,
               attachments: nil, headers: nil, tags: nil, metadata: nil, scheduled_at: nil)
        # Normalize recipients to arrays
        to = Array(to)
        cc = Array(cc) if cc
        bcc = Array(bcc) if bcc

        payload = {
          from: from,
          to: to,
          subject: subject
        }

        payload[:html] = html if html
        payload[:text] = text if text
        payload[:cc] = cc if cc
        payload[:bcc] = bcc if bcc
        payload[:reply_to] = reply_to if reply_to
        payload[:attachments] = attachments if attachments
        payload[:headers] = headers if headers
        payload[:tags] = tags if tags
        payload[:metadata] = metadata if metadata
        payload[:scheduled_at] = scheduled_at if scheduled_at

        response = @client.request(:post, "/emails", payload)
        response[:data]
      end

      # Get an email by ID
      #
      # @param email_id [String] The email ID to retrieve
      # @return [Hash] Email object
      def get(email_id)
        response = @client.request(:get, "/emails/#{email_id}")
        response[:data]
      end

      # List emails with pagination and filtering
      #
      # @param limit [Integer] Number of emails to return (max 100)
      # @param offset [Integer] Pagination offset
      # @param status [String] Filter by status (optional)
      # @param from_date [String] Filter from date ISO8601 (optional)
      # @param to_date [String] Filter to date ISO8601 (optional)
      # @param tags [Array<String>] Filter by tags (optional)
      # @return [Hash] Paginated list with :data, :total, :limit, :offset
      def list(limit: 20, offset: 0, status: nil, from_date: nil, to_date: nil, tags: nil)
        params = {
          limit: limit,
          offset: offset
        }

        params[:status] = status if status
        params[:from_date] = from_date if from_date
        params[:to_date] = to_date if to_date
        params[:tags] = tags.join(",") if tags

        @client.request(:get, "/emails", params)
      end

      # Cancel a scheduled email
      #
      # @param email_id [String] The email ID to cancel
      # @return [Hash] Updated email object
      def cancel(email_id)
        response = @client.request(:delete, "/emails/#{email_id}")
        response[:data]
      end
    end
  end
end
