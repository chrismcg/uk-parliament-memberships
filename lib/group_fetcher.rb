require 'open-uri'
require 'nokogiri'

module Parliament
  class Group
    attr_reader :name, :url
    def initialize(name, url)
      @name = name
      @url = url
    end

    def members
      html = Nokogiri.HTML(open(@url))
      government_names = html.css('tr:nth-child(13) td:nth-child(2) p')
      opposition_names = html.css('tr:nth-child(13) td:nth-child(3) p')
      other_names = html.css('tr:nth-child(13) td:nth-child(4) p')
      all_names_html = government_names + opposition_names + other_names
      all_names = all_names_html.map(&:text).map { |s| s.gsub(/ ?(\u2013|-) ?(Con|LD|Lab)$/, '') }.reject { |s| s[0].ord == 160 }
      all_names.map do |name|
        if name =~ /(\u2013|-) ?(Con|LD|Lab)/
          name.split(/(\u2013|-) ?(Con|LD|Lab)/).reject { |n| n =~ /(\u2013|-)/ || n =~ /(Con|LD|Lab)/ }.map(&:rstrip)
        else
          name
        end
      end.flatten
    end
  end

  class GroupFetcher
    def self.fetch
      base_url = 'http://www.publications.parliament.uk/pa/cm/cmallparty/register/'
      html = Nokogiri.HTML(open('http://www.publications.parliament.uk/pa/cm/cmallparty/register/contents.htm'))
      html.css('p.contentsLink a').map do |e|
        Group.new e.text, base_url + e.attr('href')
      end
    end
  end
end
