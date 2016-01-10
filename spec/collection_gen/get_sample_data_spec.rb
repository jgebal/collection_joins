require 'install.rb'

describe 'Get sample from collection' do

  it 'returns 10 percent size collection of random elements' do
    result = plsql.collection_gen.get_sample_data( 1000, 10 )
    expect( result.size ).to eq 1000
    expect( result.uniq ).to eq result
  end

end
