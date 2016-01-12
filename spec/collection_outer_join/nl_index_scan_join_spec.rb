require 'install.rb'
require_relative 'join_shared_examples'

describe 'Nested loops join of collections with index collection scan' do

  describe 'Nested loops join of collections with full collection scan' do

    include_examples 'joins data', :nl_index_scan_join
    include_examples 'unsorted', :nl_index_scan_join

  end

end
