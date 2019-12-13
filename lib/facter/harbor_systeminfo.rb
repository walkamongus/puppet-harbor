# frozen_string_literal: true

require 'net/http'
require 'openssl'
require 'json'
require 'yaml'

Facter.add(:harbor_systeminfo) do
  confine { File.exist? '/opt/harbor/harbor.yml' }
  setcode do
    cnf  = YAML.safe_load(File.open('/opt/harbor/harbor.yml'))
    url  = "http://#{cnf['hostname']}/api/systeminfo"
    uri  = URI.parse(url)
    begin
      resp = Net::HTTP.new(uri.host).request(Net::HTTP::Get.new(uri))
      unless resp['location'].nil?
        uri = URI.parse(resp['location'])
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        req = Net::HTTP::Get.new(uri.request_uri)
        resp = https.request(req)
      end
      data = JSON.parse(resp.body)
    rescue Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
           Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError
      data = {}
    end
    data
  end
end
