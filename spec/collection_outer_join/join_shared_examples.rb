shared_examples 'joins data' do |function_name|

  it 'returns all data from parent and child collections' do
    expected = (1..10).map do |i|
      {id: i,
       children: (1..10).map do
         {id: i,
          name: 'name '+i.to_s}
       end
      }
    end
    result = plsql.collection_outer_join.send function_name, 10, 100
    expect( result ).to match_array expected
  end

end

shared_examples 'unsorted' do |function_name|

  it 'returns unsorted data' do
    result = plsql.collection_outer_join.send function_name, 2000, 20000
    expect( result ).not_to eq result.sort{ |a,b| a[:id] <=> b[:id] }
  end

end

shared_examples 'sorted' do |function_name|

  it 'returns sorted data' do
    result = plsql.collection_outer_join.send function_name, 2000, 20000
    expect( result ).to eq result.sort{ |a,b| a[:id] <=> b[:id] }
  end

end
