#!/usr/bin/env ruby

require_relative 'lib/bca_tree'

TEMP_URL = "http://ctsondemand.com/TournamentHome.aspx?TournamentID=f3f5d8fb-21c6-4283-bee8-5e41d49f5661"

def bca_tree
  BcaTree.new(TEMP_URL).parse_and_write
end

bca_tree
