require 'install.rb'

describe 'Get duplicated collection' do

  it 'returns collection of given size with given number of duplicates per key' do
    result = plsql.collection_gen.get_unsorted_nuniq_collection( 1000, 10 )
    expect( result.size ).to eq 1000
    expect( result.uniq.size ).to eq 100
  end

end
