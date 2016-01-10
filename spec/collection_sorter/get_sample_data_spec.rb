require 'install.rb'

describe 'Get sample from collection' do

  it 'returns ~10 percent size collection of random elements' do
    result = plsql.collection_sorter.get_sample_data( plsql.collection_sorter.get_unique_collection( 1000 ), 10 )
    expect( result.size ).to be_within(10).of(100)
    expect( result.uniq ).to eq result
  end

end
