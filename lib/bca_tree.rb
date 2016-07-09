require 'mechanize'
require 'nokogiri'
# require 'farm_shed'

require_relative 'walker.rb'
require_relative 'show_page.rb'

class BcaTree
  def initialize(url)
    @index_url = url
    @mech = Mechanize.new
  end

  def parse
    get_and_parse_index
  end

  def get_and_parse_index
    parse_index(index_page)
  end

  def parse_index(page)
    h = {}
    get_index_links(page).each do |link|
      url = page.uri.merge(link.uri)
      key = link.text.strip
      # puts key
      if key == "Women's Open Teams"
      h[key] = ShowPage.new(url, @mech).parse[:results]
      end
    end
    h
  end

  def get_index_links(page)
    links = page.links_with(:href => /DivisionHome\.aspx\?DivisionID=/)
  end

  def index_page
     @mech.get(@index_url)
  end
end
