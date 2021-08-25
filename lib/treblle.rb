require 'uri'
require 'net/http'
require 'treblle/data_builder'

class Treblle
  TREBLLE_URI = 'https://rocknrolla.treblle.com'.freeze

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
        return [status, headers, response]
      end

      params = {
        env: env,
        status: status,
        started_at: started_at,
        ended_at: Time.now,
        request: request,
        headers: headers,
        json_response: json_response
      }
      capture(params)
    rescue Exception => exception
      puts 'IN EXCEPTION'
      status = status_code_for_exception(exception)
      params = {
        env: env,
        status: status,
        started_at: started_at,
        ended_at: Time.now,
        request: request,
        headers: headers,
        exception: exception
      }
      capture(params)
      raise exception
    end

    [status, headers, response]
  end

  def capture(params)
    data = DataBuilder.new(params).call

    send_to_treblle(data)
  rescue Exception => exception
    Rails.logger.error(exception.message)
  end

  def send_to_treblle(data)
    uri = URI(TREBLLE_URI)
    req = Net::HTTP::Post.new(uri)
    req['Content-Type'] = 'application/json'
    req['x-api-key'] = ENV.fetch('TREBLLE_API_KEY') { '' }
    req.body = data
    puts data
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
      http.request(req)
    end
    puts res.try(:body)
  end

  def status_code_for_exception(exception)
    exception_wrapper = ActionDispatch::ExceptionWrapper.new(nil, exception)
    exception_wrapper.status_code
  rescue
    500
  end
end
