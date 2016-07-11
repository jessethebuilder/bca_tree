require 'erb'

class WbcaScribe
  def initialize(data_hash, title, date, place)
    @data = data_hash
    @title = title
    @date = date
    @place = place
  end

  def build_html
    ERB.new(F.read('views/final.html.erb')).result(self.get_binding)
  end

  def parse_player(player)
    player.gsub(/ \(\d+\)/, '')
  end

  def parse_place(place)
    if /(Loser: )?(\d\w{2}) Place/ =~ place
      $2
    else
      /\ALoser ties (\d+-\d+)/ =~ place
      parse_multi_places($1)
    end
  end

  def parse_multi_places(places)
    p = places.split('-')
    "#{ordinalize(p[0])}/#{ordinalize(p[1])}"
  end

  def parse_team_name(team, teams)
    teams.each do |k, v|
      return k if k[0..12] == team[0..12]
    end
  end

  def get_binding
    binding()
  end

  def total_payout(results)
    winnings = []
    results.each do |k, v|
      v['winners'].each do
        winnings << v['payout']
      end
    end

    winnings.inject(0){ |n, sum| n + sum }
  end

  LEAGUE_ACRONYMS = {
    'CPL' => 'Cascade Pool League',
   	'INL' => "Inland BCA",
    'LTD' => "Player's Club Limited",
    'COB' => "Central Oregon BCA",
    'LINC' => "Lincoln City",
    'SLC' => "South Lincoln County",
    'CWY' => " Central Washington - Yakima",
    'LCC' => " Lower Columbia Clatsop",
    'SWI' => " Southwest Idaho BCA",
    'CC' => "Cherry City",
    'LCP' => " Lower Columbia Penn.",
    'TC' => "Thurston County BCA",
    'EV' => "Emerald Valley",
    'MID' => "Mid Valley BCA",
    'TIO' => "Tioga BCA Pool League",
    'GTE' => "Good Time Ernie's Inhouse League",
    'MTV' => "Mountain View Pool League",
    'UMP' => "Umpqua Valley",
    'HIH' => "Harvey's Inn House",
    'NPL' => "Northwest Player's League",
    'WWA' => "Western Washington United BCA",
    'ING' => "Inglis Valley BCA",
    'PCGP' => "Player's Club Grants Pass"
  }
end
