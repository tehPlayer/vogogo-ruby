module Vogogo
  class Client
    attr_accessor :uri, :http, :status

    API_URI = 'https://api.vogogo.com/v3/'

    include Vogogo::Notifications::Events
    include Vogogo::Risk::Customers
    include Vogogo::Risk::IndustryTypes
    include Vogogo::Risk::Occupations
    include Vogogo::Risk::SupportedCountries
    # include Vogogo::Risk::PhoneNumbers
    # include Vogogo::Risk::Documents

    def initialize(secret = nil)
      @secret = secret || ENV['VOGOGO_SECRET']
    end

    protected
      def connection(method)
        @uri = URI.parse(API_URI + "#{method}")
        @http = Net::HTTP.new(uri.host, uri.port)
        @http.use_ssl = true
      end

      def request_method(method_name, params = {})
        case method_name
          when 'put'
            request = Net::HTTP::Put.new(@uri.request_uri)
          when 'post'
            request = Net::HTTP::Post.new(@uri.request_uri)
          when 'get'
            request = Net::HTTP::Get.new(@uri.request_uri)
        end
        request["content-type"] = "application/json"
        request.basic_auth(@secret, '')
        request.body = params.to_json
        response = @http.request(request)

        case response.code.to_i
        when 200 then nil
        when 401 then raise Vogogo::ClientError.new("401 Unauthorized")
        when 400 then raise Vogogo::ClientError.new("400 Bad Request")
        when 500 then raise Vogogo::ClientError.new("500 Internal Sever Error")
        when 501 then raise Vogogo::ClientError.new("501 Not implemented")
        else raise Vogogo::ClientError.new("Response status code: #{response.code}")
        end

        JSON.parse(response.body)
      end
  end

  class ClientError < StandardError; end
end
