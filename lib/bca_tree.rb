require 'mechanize'
require 'nokogiri'
require 'json'

require_relative '../modules/f'

require_relative 'show_page'
require_relative 'wbca_scribe'

class BcaTree
  def initialize(url)
    @started_at = Time.now
    @index_url = url
    @mech = Mechanize.new
    goto_index_page
    @title = @mech.page.css('.title').text
  end

  def parse_and_write
    file_name = "#{@title}.html".downcase.gsub(/[- ]/, '_')
    html = WbcaScribe.new(parse_index, @title).build_html
    F.write("#{file_name}", html)
    puts "Pages Parsed and HTML generated in
         #{(Time.now - @started_at).round(2)} seconds."
  end

  def parse_index
    # h = {}
    # time = Time.now
    # get_index_links.each do |link|
    #   url = @mech.page.uri.merge(link.uri)
    #   key = link.text.strip
    #
    #   puts "Parsing #{key}....."
    #
    #   h[key] = ShowPage.new(url, @mech).parse
    #   puts "#{key} parsed!\n\n"
    # end
    #
    # puts "All pages parsed.\n\n"
    # puts "Preparing to output HTML...."

    #debug
    f = F.new('temp.json')
    # f.write(JSON.pretty_generate(h))
    h = JSON.parse(f.read)

    h
  end

  def get_index_links
    links = @mech.page.links_with(:href => /DivisionHome\.aspx\?DivisionID=/)
  end

  def goto_index_page
     @mech.get(@index_url)
  end
end
