require 'nokogiri'
require 'uri'
PARLIAMENT_SITE = 'data.parliament.uk'

class Committee
  attr_reader :id, :name, :committee_type

  def initialize(xml)
    @id = xml.attr('id')
    @name = xml.at_xpath('c:committeeName').text
    @committee_type = xml.at_xpath('c:committeeType').text
  end

  def lords_member_path
    "/resources/members/api/committees/#{URI.escape(name)}/#{id}/members/lords"
  end

  def commons_member_path
    "/resources/members/api/committees/#{URI.escape(name)}/#{id}/members/commons"
  end
end

class CommitteeFetcher

  def self.fetch
    xml = Nokogiri.XML(make_http_request('/resources/members/api/committees'))
    xml.xpath('//c:committee').map do |committee_xml|
      Committee.new(committee_xml)
    end
  end

  def self.create_committee(xml)

  end

private
  def self.make_http_request(path)
    Net::HTTP.get_response(PARLIAMENT_SITE, path, 80).body
  end
end
