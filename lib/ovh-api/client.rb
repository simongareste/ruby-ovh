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
      conf = YAML.load_file('conf.yml')

      @application_key    = application_key || conf['application_key']
      @application_secret = application_secret || conf['application_secret']
      @consumer_key       = consumer_key || conf['consumer_key']
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
      @consumer_key = JSON.parse(resp.body)['consumerKey']

      resp
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
