require 'net/http'
require 'rubygems'
require 'xmlsimple'

class Jenkins
  def initialize(username, password)
    @username = username
    @password = password
  end

  # Get the api response for a uri
  def getJobApi (options)
    uri = options[:job] + "?depth=" + options[:depth].to_s
    job_uri = URI.parse(uri)
    http = Net::HTTP.new(job_uri.host, job_uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(job_uri.request_uri)
    request.basic_auth @username, @password
    response = http.request(request)
    job_xml=XmlSimple.xml_in(response.body)
    return job_xml
  end
end
