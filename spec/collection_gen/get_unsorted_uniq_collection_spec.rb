require 'install.rb'

describe 'Get unique collection' do

  it 'returns a collection of given size with unique elements' do
    size = 100
    result = plsql.collection_gen.get_unsorted_uniq_collection(size)
    expect( result.size ).to eq size
    expect( result.uniq ).to match_array result
  end

  it 'returns empty collection if size is null' do
    expect( plsql.collection_gen.get_unsorted_uniq_collection(NULL) ).to eq []
  end

  it 'returns empty collection if size is negative' do
    expect( plsql.collection_gen.get_unsorted_uniq_collection(-1) ).to eq []
  end

end
