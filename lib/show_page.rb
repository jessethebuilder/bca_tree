class ShowPage
  def initialize(link, mech)
    @mech = mech
    @show_url = link
    @final = {}
    @final[:results] = {}
  end

  def get_show_page
    @mech.get(@show_url)
  end

  def parse
    bracket_urls(get_show_page).each do |url|
      parse_bracket_page(url)
    end

    parse_player_info!

    @final
  end

  def parse_player_info!
    link = get_show_page.link_with(:href => /PlayerSearch\.aspx\?TournamentID=/)
    @final[:total_entries] = link.text
    link.click
    parse_player_table!
  end

  def parse_player_table!
    table = @mech.page.search('table')[2]
    rows = table.search('tr')[2..-1]
    parse_team_rows!(rows) if team_rows?(rows)
  end

  def parse_team_rows!(rows)
    @final[:teams] = {}
    rows.each do |r|
      cols = r.search('td')
      team = cols[4].text.strip
      name = "#{cols[2].text.strip} #{cols[3].text.strip}"
      @final[:teams][team] = [] unless @final[:teams].has_key?(team)
      @final[:teams][team] << name
    end
  end

  def team_rows?(rows)
    same = 0
    3.times do |i|
      name = rows[i].search('td')[3].text
      team = rows[i].search('td')[4].text
      same += 1 if team.split('/').include?(name)
    end

    same != 3
  end

  def bracket_urls(page)
    links = page.links_with(:href => /BracketViewer\.aspx\?BracketID=/)
    links.map{ |l| page.uri.merge(l.uri) }
  end

  def parse_bracket_page(url)
    @bracket_page = @mech.get(url)

    bracket_rounds.each do |round|
      id = round.attributes["id"]
      if id && id.value =~ /header\z/
        parse_header_round(round)
      end
    end
  end

  def parse_header_round(round)
    match = round.text.match( /\$(.+?\.\d{2})/)
    cash = match ? match[1].gsub(',', '').to_i : nil
    parse_cash_round(round, cash) if cash
  end

  def parse_cash_round(round, cash)
    key = round.text.match(/^(.+?)\u00A0/)[1]
    @final[:results][key] = {:payout => cash} unless @final[:results].has_key?(key)
    parse_cash_winners(round, key)
  end

  def parse_cash_winners(round, key)
    klass = round.attributes["class"].value
    winner_rounds = @bracket_page.css(".#{klass}")

    arr = []
    winner_rounds.each do |w|
      unless w == round
        winners = w.search('a').map{ |l| l.text }
        arr << winners
      end
      @final[:results][key][:winners] = [] unless @final[:results][key].has_key?(:winners)
      @final[:results][key][:winners] << arr.flatten
    end

    order_winners!
    sanatize_winners!
  end

  def bracket_rounds
    @bracket_page.xpath('//div[starts-with(@class, "round")]')
  end

  def order_winners!
    @final[:results].each do |k, v|
      v[:order] = 0 if k =~ /1st Place/
      v[:order] = 1 if k =~ /2nd Place/
      v[:order] = 2 if k =~ /3rd Place/
      v[:order] = 3 if k =~ /4th Place/
      match = k.match(/Loser ties (\d+)-/)
      v[:order] = match[1].to_i if match
    end
  end

  def sanatize_winners!
    highers = []
    @final[:results].sort_by{ |k, v| v[:order] }.each do |key, v|
      # puts v
      winners = v[:winners].flatten.delete_if{ |win| win.match(/Winner of loser bracket/) }
      winners = winners.delete_if{ |win| win.match /Loser from W\d+-\d+/ }
      winners = winners - highers
      winners.uniq!
      @final[:results][key][:winners] = winners.flatten
      highers << winners
      highers.flatten!
    end
  end
end
