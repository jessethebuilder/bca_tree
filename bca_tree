#!/usr/bin/env ruby

require_relative 'modules/f'
require_relative 'modules/utilities'
require_relative 'lib/bca_tree'


def bca_tree
  BcaTree.new(ENV['BASE_URL']).parse_and_write
end

F.file_to_env('config.anysoft')
bca_tree
