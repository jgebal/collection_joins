require 'install.rb'
require_relative 'join_shared_examples'

describe 'Sort merge join of collections' do

  include_examples 'joins data', :sort_merge_join
  include_examples 'sorted', :sort_merge_join

end
