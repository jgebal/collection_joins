require 'install.rb'

describe 'Get unique collection' do

  it 'returns a collection of 10000 unique elements' do
    result = plsql.collection_sorter.get_unique_collection
    expect( result.size ).to eq 10000
    expect( result.uniq ).to eq result
  end

  it 'returns a collection of given size with unique elements' do
    size = 100
    result = plsql.collection_sorter.get_unique_collection(size)
    expect( result.size ).to eq size
    expect( result.uniq ).to eq result
  end

  it 'returns empty collection if size is null' do
    expect( plsql.collection_sorter.get_unique_collection(NULL) ).to eq []
  end

  it 'returns empty collection if size is negative' do
    expect( plsql.collection_sorter.get_unique_collection(-1) ).to eq []
  end

end
