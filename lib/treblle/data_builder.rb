require 'socket'

class DataBuilder
  DEFAULT_SENSITIVE_FIELDS = Set[
    "password",
    "pwd",
    "secret",
    "password_confirmation",
    "passwordConfirmation",
    "cc",
    "card_number",
    "cardNumber",
    "ccv",
    "ssn",
    "credit_score",
    "creditScore",
  ].freeze

  attr_accessor :env, :status, :started_at, :ended_at, :request, :headers, :json_response, :exception

  def initialize(params)
    @env = params[:env]
    @status = params[:status]
    @started_at = params[:started_at]
    @ended_at = params[:ended_at]
    @request = params[:request]
    @headers = params[:headers]
    @json_response = params[:json_response]
    @exception = params[:exception]
  end

  def call
    url = env['REQUEST_URI']
    path = env['PATH_INFO']
    user = try_current_user(env)
    time_spent = ended_at - started_at
    user_agent = env['HTTP_USER_AGENT']
    ip = env['action_dispatch.remote_ip'].calculate_ip
    request_method = env['REQUEST_METHOD']
    http_host = env['HTTP_HOST']
    project_id = ENV.fetch('TREBLLE_PROJECT_ID') { '' }
    version = '0.6'
    sdk = 'ruby'

    data = {
      api_key: ENV.fetch('TREBLLE_API_KEY') { '' },
      project_id: project_id,
      version: version,
      sdk: sdk,
      data: {
        server: {
          ip: server_ip,
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
          timestamp: started_at.to_formatted_s(:db),
          ip: ip,
          url: url,
          user_agent: user_agent,
          method: request_method,
          headers: request.headers.env.reject { |key| key.to_s.include?('.') },
          body: without_sensitive_attrs(request.query_parameters)
        },
        response: {
          headers: headers,
          code: status,
          size: json_response&.size,
          load_time: time_spent,
          body: without_sensitive_attrs(json_response),
          errors: build_error_object(exception)
        }
      }
    }

    # puts api_key
    # puts project_id
    # puts version
    # puts sdk


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
    # puts data.to_json
    return data.to_json
  end

  private

  def without_sensitive_attrs(obj)
    sensitive_attrs = DEFAULT_SENSITIVE_FIELDS
    obj.each do |k,v|
      value = v || k
      if value.is_a?(Hash) || value.is_a?(Array)
        without_sensitive_attrs(value)
      else
        if sensitive_attrs.include?(k.to_s)
          obj[k] = '*' * v.to_s.length
        end
      end
    end
    obj
  end

  def sensitive_attrs
    @sensitive_attrs ||= user_sensitive_fields.merge(DEFAULT_SENSITIVE_FIELDS)
  end

  def user_sensitive_fields
    fields = ENV.fetch('TREBLLE_SENSITIVE_FIELDS') { '' }.gsub(/\s+/, '')
    fields.split(',').to_set
  end

  def build_error_object(exception)
    return [] unless exception.present?

    [
      {
        source: 'onError',
        type: exception.class,
        message: exception.message,
        file: '',
        line: ''
      }
    ]
  end

  def try_current_user(env)
    controller = env['action_controller.instance']
    return unless controller.respond_to?(:current_user, true)
    return unless [-1, 0].include?(controller.method(:current_user).arity)
    controller.__send__(:current_user)
  end

  def server_ip
    Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
  end
end
