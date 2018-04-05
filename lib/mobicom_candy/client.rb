require 'net/http'
require 'json'

module MobicomCandy
  # API Client Wrapper
  class Client
    # @param [String] token
    def initialize(token)
      @token = token
      @last_sent = nil
    end

    # @param [Integer] limit
    # @param [Integer] offset
    # @return [MobicomCandy::Entity]
    def transaction(limit = 10, offset = 0)
      get('transaction', limit: limit, offset: offset)
    end

    # @param [String] customer_id
    # @param [String] system
    # @return [MobicomCandy::Entity]
    def customer(customer_id, system)
      post('customer', customer: customer_id, 'customer.system' => system)
    end

    # @param [String] customer_id
    # @param [String] system
    # @param [Decimal] amount
    # @param [String] description
    # @return [MobicomCandy::Entity]
    def reward(customer_id, system, amount, description)
      post('reward',
           'customer' => {
             value: customer_id,
             system: system
           },
           amount: amount,
           description: description
      )
    end

    # @param [String] customer_id
    # @param [String] system
    # @param [Decimal] amount
    # @param [String] description
    # @param [String] sms_prefix
    # @param [String] sms_suffix
    # @param [String] product
    # @param [String] product_type
    # @return [MobicomCandy::Entity]
    def sell(customer_id, system, amount, description: nil, sms_prefix: nil, sms_suffix: nil, product: nil, product_type: nil)
      post('sell',
           'customer' => {
             value: customer_id,
             system: system
           },
           amount: amount,
           description: description,
           smsPrefix: sms_prefix,
           smsSuffix: sms_suffix,
           product: product,
           productType: product_type
      )
    end

    # @param [String] customer_id
    # @param [String] system
    # @param [Decimal] amount
    # @param [String] tancode
    # @return [MobicomCandy::Entity]
    def sell_confirm(customer_id, system, amount, tancode)
      post('sellconfirm', 'customer.value' => customer_id, 'customer.system' => system, amount: amount, tancode: tancode)
    end

    # @param [String] customer_id
    # @param [String] system
    # @param [Decimal] amount
    # @param [String] pin
    # @param [String] description
    # @param [String] sms_prefix
    # @param [String] sms_suffix
    # @param [String] product
    # @param [String] product_type
    # @return [MobicomCandy::Entity]
    def sell_card(customer_id, system, amount, pin, description: nil, sms_prefix: nil, sms_suffix: nil, product: nil, product_type: nil)
      post('sellcard',
           'customer' => {
             value: customer_id,
             system: system
           },
           amount: amount,
           pin: pin,
           description: description,
           smsPrefix: sms_prefix,
           smsSuffix: sms_suffix,
           product: product,
           productType: product_type
      )
    end

    private
    # @param fn [String] API Endpoint
    # @param [Hash] params
    # @return [MobicomCandy::Entity]
    def post(fn, params = {})
      request("/resource/partner/v1/#{fn}", params: params, type: POST)
    end

    # @param fn [String] API Endpoint
    # @param [Hash] params
    # @return [MobicomCandy::Entity]
    def get(fn, params = {})
      request("/resource/partner/v1/#{fn}", params: params, type: GET)
    end

    # @param [String] path
    # @param [Hash] params
    # @param [Enum] type
    # @param [Function] block
    def request(path, params: nil, type: GET, &block)
      sleep(1) if @last_sent && @last_sent > (Time.now - 1000)
      @last_sent = Time.now
      uri = URI('https://' + host + path)
      unless type::REQUEST_HAS_BODY || params.nil? || params.empty?
        uri.query = Params.encode(params)
      end
      message = type.new(uri.request_uri)
      message['Content-Type'] = 'application/json'
      if type::REQUEST_HAS_BODY
        if json_body?
          message.body = JSON.generate(params)
        else
          message.form_data = params
        end
      end
      message['Authorization'] = "Bearer #{@token}"
      http = Net::HTTP.new(uri.host, Net::HTTP.https_default_port)
      http.use_ssl = true
      response = http.request(message)
      parse(response, &block)
    end

    GET = Net::HTTP::Get
    POST = Net::HTTP::Post

    def json_body?
      true
    end

    def host
      'api.candy.mn'
    end

    # @param [String] response
    # @param [Object] block
    def parse(response, &block)
      case response
        when Net::HTTPNoContent
          :no_content
        when Net::HTTPSuccess
          parse_success(response, &block)
        when Net::HTTPUnauthorized
          raise AuthenticationError, "#{response.code} response with: #{response.body}"
        when Net::HTTPClientError
          raise ClientError, "#{response.code} response with: #{response.body}"
        when Net::HTTPServerError
          raise ServerError, "#{response.code} response with: #{response.body}"
        else
          raise Error, "#{response.code} response from #{host}"
      end
    end

    def parse_success(response)
      if response['Content-Type'].split(';').first == 'application/json'
        JSON.parse(response.body, object_class: MobicomCandy::Entity)
      elsif block_given?
        yield response
      else
        response.body
      end
    end
  end
end
