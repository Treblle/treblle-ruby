class Treblle
  def initialize app
    @app = app
  end

  def call(env)
    request = ActionDispatch::Request.new env
    started_on = Time.now
    begin
      status, headers, response = @app.call(env)
      puts '*' * 100
      to_parse = response.clone
      to_parse = to_parse.try(:body) if to_parse.respond_to?(:body)

      # return [status, headers, response] unless to_parse.respond_to?(:reduce)
      # string_response = to_parse.reduce('') { |str, res| res += str }
      begin
        json_response = JSON.parse(to_parse)
      rescue JSON::ParserError
        return [status, headers, response]
      end
      # puts json_response
      log(env, status, started_on, Time.now, request, headers, json_response)
    rescue Exception => exception
      puts 'IN EXCEPTION'
      status = determine_status_code_from_exception(exception)
      log(env, status, started_on, Time.now, request, headers, nil, exception)
      raise exception
    end

    [status, headers, response]
  end

  def log(env, status, started_on, ended_on, request, headers, json_response, exception = nil)
    url = env['REQUEST_URI']
    path = env['PATH_INFO']
    user = try_current_user(env)
    time_spent = ended_on - started_on
    user_agent = env['HTTP_USER_AGENT']
    ip = env['action_dispatch.remote_ip'].calculate_ip
    request_method = env['REQUEST_METHOD']
    http_host = env['HTTP_HOST']
    api_key = ENV.fetch('TREBLLE_API_KEY') { '' }
    project_id = ENV.fetch('TREBLLE_PROJECT_ID') { '' }
    version = '0.6'
    sdk = 'ruby'

    data = {
      server: {
        ip: '',
        timezone: Time.zone.name,
        software: '',
        signature: '',
        protocol: '',
        os: {
        }
      },
      language: {
        name: 'ruby',
        version: RUBY_VERSION
      },
      request: {
        timestamp: started_on.to_formatted_s(:db),
        ip: ip,
        url: url,
        user_agent: user_agent,
        method: request_method,
        headers: headers,
        body: request.request_parameters
      },
      response: {
        headers: '',
        code: status,
        size: json_response&.size,
        load_time: time_spent,
        body: json_response,
        errors: [
          {
            source: exception && 'onError',
            type: exception&.class,
            message: exception&.message,
            file: '',
            line: ''
          }
        ]
      }
    }

    puts api_key
    puts project_id
    puts version
    puts sdk


    # puts status
    # puts ip
    # puts request_method
    # puts url
    # puts path
    # puts user
    # puts time_spent
    # puts user_agent
    # puts http_host
    # puts exception&.class
    # puts exception&.message
    # puts json_response
    # puts '%' * 100
    puts data.to_json
  rescue Exception => exception
    Rails.logger.error(exception.message)
  end

  def determine_status_code_from_exception(exception)
    exception_wrapper = ActionDispatch::ExceptionWrapper.new(nil, exception)
    exception_wrapper.status_code
  rescue
    500
  end

  def try_current_user(env)
    controller = env['action_controller.instance']
    return unless controller.respond_to?(:current_user, true)
    return unless [-1, 0].include?(controller.method(:current_user).arity)
    controller.__send__(:current_user)
  end
end
