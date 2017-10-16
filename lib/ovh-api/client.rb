require "net/https"
require "uri"
require 'json'
require 'yaml'
require 'digest/sha1'

# Main module
module OVHApi
  # Main class
  class Client

    HOST = 'eu.api.ovh.com'
    attr_reader :application_key, :application_secret, :consumer_key

    def initialize(application_key: nil, application_secret: nil, consumer_key: nil)
      begin
        conf = YAML.load_file('config/ovh-api.yml')
        @application_key    = application_key || conf['application_key']
        @application_secret = application_secret || conf['application_secret']
        @consumer_key       = consumer_key || conf['consumer_key']
      rescue SystemCallError
      end

      @application_key    = application_key
      @application_secret = application_secret
      @consumer_key       = consumer_key

      raise OVHApiNotConfiguredError.new(
        "Either instantiate Client.new with application_key and application_secret, or create a YAML file in config/ovh-api.yml with those values set") if @application_key.nil? || @application_secret.nil?

    end

    # Request a consumer key
    #
    # @param [Hash] access_rules
    # @return [Hash] the JSON response
    def request_consumerkey(access_rules)
      uri = ::URI.parse("https://#{HOST}")
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      headers = {
        'X-Ovh-Application' => @application_key,
        'Content-type'      => 'application/json'
      }

      resp = http.post('/1.0/auth/credential', access_rules.to_json, headers)
      begin
        body_hash = JSON.parse(resp.body)
        @consumer_key = body_hash['consumerKey']

        return resp, body_hash["validationUrl"]
      rescue JSON::ParserError
        return resp
      end
    end

    # Generate signature
    #
    # @param url [String]
    # @param method [String]
    # @param timestamp [String]
    # @param body [String]
    #
    def get_signature(url, method, timestamp, body = "")
      signature = "$1$#{Digest::SHA1.hexdigest("#{application_secret}+#{consumer_key}+#{method}+https://#{HOST}/1.0#{url}+#{body}+#{timestamp}")}"
      signature
    end

    # Make a get request to the OVH api
    #
    # @param url [String]
    # @return [Net::HTTPResponse] response
    def get(url)

      request(url, 'GET', '')

    end

    # Make a post request to the OVH api
    #
    # @param url [String]
    # @param body [String]
    # @return [Net::HTTPResponse] response
    def post(url, body)

      request(url, 'POST', body)

    end

    # Make a put request to the OVH api
    #
    # @param url [String]
    # @param body [String]
    # @return [Net::HTTPResponse] response
    def put(url, body)

      request(url, 'PUT', body)
    end


    # Make a delete request to the OVH api
    #
    # @param url [String]
    # @return [Net::HTTPResponse] response
    def delete(url)

      request(url, 'DELETE', '')

    end

    def request(url, method, body)

      raise OVHApiNotConfiguredError.new(
        "You cannot call Client#request without a consumer_key, please use the Client#request_consumerkey method to get one, and validate it with you credential by following the link, and/or save the consumer_key value in the YAML file in config/ovh-api.yml") if @consumer_key.nil?

      uri = ::URI.parse("https://#{HOST}")
      http = ::Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      timestamp = Time.now.to_i

      headers = {
        'Host'              => HOST,
        'Accept'            => 'application/json',
        'Content-Type'      => 'application/json',
        'X-Ovh-Application' => application_key,
        'X-Ovh-Timestamp'   => timestamp.to_s,
        'X-Ovh-Signature'   => get_signature(url, method, timestamp.to_s, body),
        'x-Ovh-Consumer'    => consumer_key
      }

      http.send_request(method, "/1.0#{url}", body, headers)
    end
  end
end
