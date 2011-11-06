require 'net/http'
require 'nokogiri'
require 'uri'

module Parliament
  PARLIAMENT_SITE = 'data.parliament.uk'
  class Lord
    attr_reader :id, :name

    def initialize(xml)
      @id = xml.attr('id')
      @name = [
        xml.at_xpath('m:rank').text,
        xml.at_xpath('m:firstName').text,
        xml.at_xpath('m:lastName').text
      ].join(' ')
      title = xml.at_xpath('m:longTitle').text
      @name += " (#{title})" if title != ""
    end

    def to_s
      name
    end
  end

  class Member
    attr_reader :id, :name

    def self.members
      @members ||= MemberFetcher.fetch_all
    end

    def self.fetch(id)
      members[id]
    end

    def initialize(id, name)
      @id = id
      @name = name
    end

    def to_s
      name
    end
  end

  class MemberFetcher
    def self.fetch_all
      members = {}
      Nokogiri.XML(make_http_request('/resources/members/api/commons/')).xpath('//m:commonsMember').each do |member_xml|
        id = member_xml.attr('id')
        first_name = member_xml.at_xpath('m:firstName').text
        last_name = member_xml.at_xpath('m:lastName').text
        members[id] = Member.new(id, "#{first_name} #{last_name}")
      end
      members
    end

    def self.make_http_request(path)
      Net::HTTP.get_response(PARLIAMENT_SITE, path, 80).body
    end
  end

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

    def members
      lords = Nokogiri.XML(make_http_request(lords_member_path)).xpath('//m:peer').map do |lord_xml|
        Lord.new(lord_xml)
      end

      commons = Nokogiri.XML(make_http_request(commons_member_path)).xpath('//m:commonsMember').map do |member_xml|
        Member.fetch(member_xml.attr('id'))
      end

      lords + commons
    rescue
      []
    end

  private
    def make_http_request(path)
      Net::HTTP.get_response(PARLIAMENT_SITE, path, 80).body
    end
  end

  class CommitteeFetcher

    def self.fetch
      xml = Nokogiri.XML(make_http_request('/resources/members/api/committees'))
      xml.xpath('//c:committee').map do |committee_xml|
        Committee.new(committee_xml)
      end
    end

  private
    def self.make_http_request(path)
      Net::HTTP.get_response(PARLIAMENT_SITE, path, 80).body
    end
  end
end
