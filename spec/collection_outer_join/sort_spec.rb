require 'install.rb'

describe 'sort' do

  it 'returns a sorted collection' do
    input    = [
      { id: 3, name: 'name ' },
      { id: 2, name: 'name ' },
      { id: 1, name: 'name ' },
      { id: 10, name: 'name ' },
      { id: 3, name: 'name ' },
    ]
    expected = [
      { id: 1, name: 'name ' },
      { id: 2, name: 'name ' },
      { id: 3, name: 'name ' },
      { id: 3, name: 'name ' },
      { id: 10, name: 'name ' },
    ]

    expect( plsql.collection_outer_join.sort_collection(input) ).to eq expected
  end
end
