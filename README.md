# EKDSend Ruby SDK

The official Ruby SDK for the EKDSend API. Send emails, SMS, and voice calls with ease.

[![Gem Version](https://badge.fury.io/rb/ekdsend.svg)](https://badge.fury.io/rb/ekdsend)
[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%203.0-red.svg)](https://www.ruby-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ekdsend'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install ekdsend
```

## Quick Start

```ruby
require 'ekdsend'

client = EKDSend.new('ek_live_xxxxxxxxxxxxx')

# Send an email
email = client.emails.send(
  from: 'hello@yourdomain.com',
  to: 'user@example.com',
  subject: 'Hello from EKDSend!',
  html: '<h1>Welcome!</h1><p>Thanks for joining us.</p>'
)

puts "Email sent: #{email[:id]}"
```

## Configuration

```ruby
require 'ekdsend'

client = EKDSend.new(
  'ek_live_xxxxxxxxxxxxx',
  base_url: 'https://es.ekddigital.com/v1',  # Optional
  timeout: 30,                               # Request timeout in seconds
  max_retries: 3,                            # Auto-retry on failures
  debug: true                                # Enable debug logging
)
```

## Email API

### Send Email

```ruby
email = client.emails.send(
  from: 'hello@yourdomain.com',
  to: ['user1@example.com', 'user2@example.com'],
  subject: 'Weekly Newsletter',
  html: '<h1>Newsletter</h1><p>Your weekly update.</p>',
  text: "Newsletter\n\nYour weekly update.",
  cc: 'cc@example.com',
  bcc: ['bcc1@example.com', 'bcc2@example.com'],
  reply_to: 'support@yourdomain.com',
  tags: ['newsletter', 'weekly'],
  metadata: { campaign_id: 'spring-2024' }
)
```

### With Attachments

```ruby
require 'base64'

pdf_content = Base64.strict_encode64(File.read('report.pdf'))

email = client.emails.send(
  from: 'reports@yourdomain.com',
  to: 'manager@company.com',
  subject: 'Monthly Report',
  html: '<p>Please find the report attached.</p>',
  attachments: [
    {
      filename: 'report.pdf',
      content: pdf_content,
      content_type: 'application/pdf'
    }
  ]
)
```

### Schedule Email

```ruby
require 'time'

send_time = (Time.now + 86400).utc.iso8601  # 24 hours from now

email = client.emails.send(
  from: 'hello@yourdomain.com',
  to: 'user@example.com',
  subject: 'Reminder',
  html: "<p>Don't forget your meeting tomorrow!</p>",
  scheduled_at: send_time
)

# Cancel scheduled email
cancelled = client.emails.cancel(email[:id])
```

### Retrieve & List Emails

```ruby
# Get specific email
email = client.emails.get('em_xxxxxxxxxxxxx')
puts "Status: #{email[:status]}"

# List emails with filters
result = client.emails.list(
  limit: 50,
  status: 'delivered',
  from_date: '2024-01-01T00:00:00Z',
  tags: ['transactional']
)

result[:data].each do |email|
  puts "#{email[:id]}: #{email[:subject]} - #{email[:status]}"
end
```

## SMS API

### Send SMS

```ruby
sms = client.sms.send(
  to: '+14155551234',
  message: 'Your verification code is: 123456',
  from: '+14155559999',
  metadata: { type: 'verification' }
)

puts "SMS sent: #{sms[:id]}"
```

### Schedule SMS

```ruby
require 'time'

send_time = (Time.now + 7200).utc.iso8601  # 2 hours from now

sms = client.sms.send(
  to: '+14155551234',
  message: 'Your appointment is in 1 hour!',
  scheduled_at: send_time
)
```

### Retrieve & List SMS

```ruby
# Get specific SMS
sms = client.sms.get('sms_xxxxxxxxxxxxx')

# List SMS messages
result = client.sms.list(limit: 25, status: 'delivered')

result[:data].each do |msg|
  puts "#{msg[:id]}: #{msg[:to]} - #{msg[:status]}"
end
```

## Voice API

### Make a Call with Text-to-Speech

```ruby
call = client.calls.create(
  to: '+14155551234',
  from: '+14155559999',
  tts_message: 'Hello! This is an important message from EKDSend.',
  voice: 'alloy',        # alloy, echo, fable, onyx, nova, shimmer
  language: 'en-US',
  record: true,
  machine_detection: true
)

puts "Call initiated: #{call[:id]}"
```

### Make a Call with Audio File

```ruby
call = client.calls.create(
  to: '+14155551234',
  from: '+14155559999',
  audio_url: 'https://example.com/message.mp3'
)
```

### Call Management

```ruby
# Get call status
call = client.calls.get('call_xxxxxxxxxxxxx')
puts "Call status: #{call[:status]}, Duration: #{call[:duration]}s"

# List calls
result = client.calls.list(limit: 20, status: 'completed')

# Hang up active call
hung_up = client.calls.hangup('call_xxxxxxxxxxxxx')

# Get call recording
recording = client.calls.get_recording('call_xxxxxxxxxxxxx')
puts "Recording URL: #{recording[:url]}"
```

## Error Handling

```ruby
require 'ekdsend'

client = EKDSend.new('ek_live_xxxxxxxxxxxxx')

begin
  email = client.emails.send(
    from: 'hello@yourdomain.com',
    to: 'invalid-email',
    subject: 'Test',
    html: '<p>Hello</p>'
  )
rescue EKDSend::AuthenticationError => e
  puts "Invalid API key: #{e.message}"
rescue EKDSend::ValidationError => e
  puts "Validation failed: #{e.message}"
  puts "Errors: #{e.errors}"
rescue EKDSend::RateLimitError => e
  puts "Rate limited. Retry after #{e.retry_after} seconds"
rescue EKDSend::NotFoundError => e
  puts "Resource not found: #{e.message}"
rescue EKDSend::EKDSendError => e
  puts "API error: #{e.message} (Code: #{e.error_code})"
  puts "Request ID: #{e.request_id}"
end
```

## Framework Integration

### Ruby on Rails

```ruby
# config/initializers/ekdsend.rb
EKDSEND_CLIENT = EKDSend.new(Rails.application.credentials.ekdsend_api_key)

# app/mailers/application_mailer.rb
class EkdsendMailer
  def self.client
    EKDSEND_CLIENT
  end
  
  def self.send_welcome_email(user)
    client.emails.send(
      from: 'welcome@yourdomain.com',
      to: user.email,
      subject: "Welcome, #{user.name}!",
      html: ApplicationController.render(
        template: 'mailers/welcome',
        locals: { user: user }
      )
    )
  end
end

# In controller
class UsersController < ApplicationController
  def create
    @user = User.create!(user_params)
    EkdsendMailer.send_welcome_email(@user)
    render json: { status: 'ok' }
  end
end
```

### Sinatra

```ruby
require 'sinatra'
require 'ekdsend'

configure do
  set :ekdsend, EKDSend.new(ENV['EKDSEND_API_KEY'])
end

post '/send-email' do
  email = settings.ekdsend.emails.send(
    from: 'hello@yourdomain.com',
    to: params[:to],
    subject: params[:subject],
    html: params[:html]
  )
  
  json email_id: email[:id]
end
```

## Requirements

- Ruby 3.0+
- Faraday 1.0+

## Development

```bash
# Clone the repository
git clone https://github.com/ekddigital/ekdsend-ruby.git
cd ekdsend-ruby

# Install dependencies
bundle install

# Run tests
bundle exec rspec

# Run linter
bundle exec rubocop
```

## License

MIT License - see [LICENSE](LICENSE) for details.

## Links

- [Documentation](https://es.ekddigital.com/docs)
- [API Reference](https://es.ekddigital.com/docs/api-reference)
- [GitHub](https://github.com/ekddigital/ekdsend-ruby)
- [RubyGems](https://rubygems.org/gems/ekdsend)
