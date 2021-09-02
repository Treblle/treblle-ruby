# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'treblle/data_builder'

# Treblle middleware for request interception and gathering.
class Treblle
  TREBLLE_URI = 'https://rocknrolla.treblle.com'
  TREBLLE_VERSION = '0.6'

  def initialize(app)
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new(env)
    started_at = Time.now

    begin
      status, headers, response = @app.call(env)
      to_parse = response.clone
      to_parse = to_parse.try(:body) if to_parse.respond_to?(:body)

      begin
        json_response = JSON.parse(to_parse)
      rescue JSON::ParserError, TypeError
        # continue with original values when unable to parse reponse to json
        return [status, headers, response]
      end

      params = {
        ended_at: Time.now,
        env: env,
        headers: headers,
        json_response: json_response,
        request: request,
        started_at: started_at,
        status: status
      }
      capture(params)
    rescue Exception => e
      status = status_code_for_exception(e)
      params = {
        ended_at: Time.now,
        env: env,
        exception: e,
        headers: headers,
        request: request,
        started_at: started_at,
        status: status
      }
      # send error payload to treblle, but raise exception as well
      capture(params)
      raise e
    end

    [status, headers, response]
  end

  # Creates data to send in a format that Treblle expects and does the sending in a new thread
  # for perfomance reasons.
  # @param [Object] params
  def capture(params)
    data = DataBuilder.new(params).call
    return if data&.bytesize.to_i > 2.megabytes # ignore the capture for unnaturally large requests

    Thread.new do
      send_to_treblle(data)
    end
  rescue Exception => e
    Rails.logger.error(e.message)
  end

  def send_to_treblle(data)
    uri = URI(TREBLLE_URI)
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req['x-api-key'] = ENV.fetch('TREBLLE_API_KEY') { '' }
    req.body = data
    puts data
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
    res.try(:body)
  end

  def status_code_for_exception(exception)
    exception_wrapper = ActionDispatch::ExceptionWrapper.new(nil, exception)
    exception_wrapper.status_code
  rescue
    500
  end
end
