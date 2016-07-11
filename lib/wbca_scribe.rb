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
      return k if k[0..18] == team[0..18]
    end
  end

  def get_binding
    binding()
  end
end
