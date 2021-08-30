require 'socket'

class DataBuilder
  DEFAULT_SENSITIVE_FIELDS = Set[
    'card_number',
    'cardNumber',
    'cc',
    'ccv',
    'credit_score',
    'creditScore',
    'password',
    'password_confirmation',
    'passwordConfirmation',
    'pwd',
    'secret',
    'ssn'
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
    # url = env['REQUEST_URI']
    # path = env['PATH_INFO']
    # http_host = env['HTTP_HOST']
    time_spent = ended_at - started_at
    user_agent = env['HTTP_USER_AGENT']
    ip = env['action_dispatch.remote_ip'].calculate_ip
    request_method = env['REQUEST_METHOD']
    project_id = ENV.fetch('TREBLLE_PROJECT_ID') { '' }

    data = {
      api_key: ENV.fetch('TREBLLE_API_KEY') { '' },
      project_id: project_id,
      version: Treblle::TREBLLE_VERSION,
      sdk: 'ruby',
      data: {
        server: {
          ip: server_ip,
          timezone: Time.zone.name,
          software: request_headers.try(:[], 'SERVER_SOFTWARE'),
          signature: '',
          protocol: request_headers.try(:[], 'SERVER_PROTOCOL'),
          os: {}
        },
        language: {
          name: 'ruby',
          version: RUBY_VERSION
        },
        request: {
          timestamp: started_at.to_formatted_s(:db),
          ip: ip,
          url: request.original_url,
          user_agent: user_agent,
          method: request_method,
          headers: request_headers,
          body: without_sensitive_attrs(request.query_parameters)
        },
        response: {
          headers: headers || {},
          code: status,
          size: json_response&.to_json&.bytesize || 0,
          load_time: time_spent,
          body: without_sensitive_attrs(json_response),
          errors: build_error_object(exception)
        }
      }
    }

    data.to_json
  end

  private

  def without_sensitive_attrs(obj)
    return {} unless obj.present?

    sensitive_attrs = DEFAULT_SENSITIVE_FIELDS
    obj.each do |k, v|
      value = v || k
      if value.is_a?(Hash) || value.is_a?(Array)
        without_sensitive_attrs(value)
      elsif sensitive_attrs.include?(k.to_s)
        obj[k] = '*' * v.to_s.length
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
        file: exception.backtrace.try(:first),
      }
    ]
  end

  def server_ip
    Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
  end

  def request_headers
    @request_headers ||= request.headers.env.reject { |key| key.to_s.include?('.') }
  end
end
