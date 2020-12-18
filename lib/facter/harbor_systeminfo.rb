# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'json'
require 'yaml'

Facter.add(:harbor_systeminfo) do
  confine { File.exist? '/opt/harbor/harbor.yml' }
  setcode do
    cnf  = YAML.safe_load(File.open('/opt/harbor/harbor.yml'))
    data = {}
    [
      "http://#{cnf['hostname']}/api/systeminfo",
      "https://#{cnf['hostname']}/api/systeminfo",
      "http://#{cnf['hostname']}/api/v2.0/systeminfo",
      "https://#{cnf['hostname']}/api/v2.0/systeminfo"
    ].each do |url|
      uri = URI.parse(url)
      client = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        client.use_ssl = true
        client.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        client.use_ssl = false
      end
      begin
        resp = client.request(Net::HTTP::Get.new(uri))
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
         Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
         Errno::ECONNREFUSED
      end
      unless resp.nil? || resp['location'].nil?
        uri = URI.parse(resp['location'])
        client = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          client.use_ssl = true
          client.verify_mode = OpenSSL::SSL::VERIFY_NONE
        else
          client.use_ssl = false
        end
        begin
          resp = client.request(Net::HTTP::Get.new(uri.request_uri))
        rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
           Errno::ECONNREFUSED
        end
      end
      unless resp.nil? || resp.code == "404"
        data = JSON.parse(resp.body)
        break
      end
    end
    data
  end
end
