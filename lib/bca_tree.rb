require 'mechanize'
require 'nokogiri'
require 'json'

require_relative 'show_page'
require_relative 'wbca_scribe'

class BcaTree
  def initialize(url)
    @started_at = Time.now
    @index_url = url
    @mech = Mechanize.new
    goto_index_page
    @title = @mech.page.css('.title').text
    set_place_and_date
  end

  def set_place_and_date
    val = @mech.page.css('div table:nth-child(2) h4').text.strip
    lines = val.split(/\n/)
    @place = lines[0]
    @date = "#{lines[2].strip} to #{lines[4].strip}"
  end

  def parse_and_write
    file_name = "#{@title}.html".downcase.gsub(/[- ]/, '_')
    html = WbcaScribe.new(parse_index, @title, @date, @place).build_html
    F.write("#{file_name}", html)
    F.write("c:/wamp/www/sandbox/index.html", html)
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
    #   # if key == "Women's Open Teams"
    #   puts "Parsing #{key}....."
    #
    #   h[key] = ShowPage.new(url, @mech).parse
    #   puts "#{key} parsed!\n\n"
    # # end
    # end
    #
    # puts "All pages parsed.\n\n"
    # puts "Preparing to output HTML...."

    # to ensure I am getting stings for keys
    f = F.new("#{@title}.json".downcase.gsub(/[- ]/, '_'))
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
