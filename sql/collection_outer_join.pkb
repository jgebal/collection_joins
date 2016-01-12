create or replace package body collection_outer_join as

   --index type declarations
   type element_pos_indexes_t is table of binary_integer index by binary_integer;

   --   type collection_index_t is table of element_pos_indexes_t index by varchar2 (100);
   type collection_index_t is table of element_pos_indexes_t index by binary_integer;

   --private functions
   function build_collection_index( p_collection num_char_coll ) return collection_index_t is
      v_size            binary_integer := cardinality( p_collection );
      v_result          collection_index_t;
      --      v_index_key       varchar2(100);
      v_index_key       binary_integer;
      v_idx_element_pos binary_integer;
      begin
         for i in 1..v_size loop
            v_index_key := p_collection( i ).id;
            begin
               v_idx_element_pos := v_result( v_index_key ).last + 1;
               exception
               when no_data_found then
               v_idx_element_pos := 1;
            end;
            v_result( v_index_key )( v_idx_element_pos ) := i;
         end loop;
         return v_result;
      end;

   function get_children_full_scan( p_parent_id number, p_children num_char_coll ) return num_char_coll is
      v_children_count binary_integer := cardinality( p_children );
      v_result         num_char_coll := num_char_coll( );
      begin
         for i in 1 .. v_children_count loop
            if p_parent_id = p_children( i ).id then
               v_result.extend;
               v_result( v_result.last ) := p_children( i );
            end if;
         end loop;
         return v_result;
      end;

   function get_children_index_scan(
      p_index_branch element_pos_indexes_t, p_children num_char_coll
   ) return num_char_coll is
      v_result num_char_coll := num_char_coll( );
      begin
         if p_index_branch is not null then
            for i in 1 .. p_index_branch.count loop
               v_result.extend;
               v_result( v_result.last ) := p_children( p_index_branch( i ) );
            end loop;
         end if;
         return v_result;
      end;

   function get_children_sorted_scan(
      p_parent_id number, v_child_position in out nocopy binary_integer, p_children num_char_coll
   ) return num_char_coll is
      v_children_count binary_integer := cardinality( p_children );
      v_result         num_char_coll := num_char_coll( );
      begin
         while p_children.exists( v_child_position ) and p_parent_id >= p_children( v_child_position ).id loop
            if p_parent_id = p_children( v_child_position ).id then
               v_result.extend;
               v_result( v_result.last ) := p_children( v_child_position );
            end if;
            v_child_position := v_child_position + 1;
          end loop;
         return v_result;
      end;


   --public functions
   function sort_collection( p_collection num_char_coll ) return num_char_coll is
      v_index  collection_index_t;
      v_result num_char_coll := num_char_coll( );
      v_iter   binary_integer;
      begin
         v_index := build_collection_index( p_collection );
         v_iter := v_index.first;
         while v_iter is not null loop
            for i in 1 .. v_index( v_iter ).count loop
               v_result.extend( );
               v_result( v_result.last ) := p_collection( v_index( v_iter )( i ) );
            end loop;
            v_iter := v_index.next( v_iter );
         end loop;
         return v_result;
      end;

   function nl_full_scan_join( p_parents num_char_coll, p_children num_char_coll ) return num_char_join_coll is
      v_parents_count binary_integer := cardinality( p_parents );
      v_result        num_char_join_coll := num_char_join_coll( );
      begin
         for i in 1 .. v_parents_count loop
            v_result.extend;
            v_result( v_result.last ) :=
            num_char_join_obj( p_parents( i ).id, get_children_full_scan( p_parents( i ).id, p_children ) );
         end loop;
         return v_result;
      end;

   function nl_full_scan_join( p_size_outer binary_integer, p_size_inner binary_integer ) return num_char_join_coll is
      begin
         return nl_full_scan_join(
            collection_gen.get_unsorted_uniq_collection( p_size_outer ),
            collection_gen.get_unsorted_nuniq_collection( p_size_inner, ceil( p_size_inner / p_size_outer ) )
         );
      end;

   function nl_index_scan_join( p_parents num_char_coll, p_children num_char_coll ) return num_char_join_coll is
      v_parents_count binary_integer := cardinality( p_parents );
      v_index         collection_index_t;
      v_result        num_char_join_coll := num_char_join_coll( );
      begin
         v_index := build_collection_index( p_children );
         for i in 1 .. v_parents_count loop
            v_result.extend;
            v_result( v_result.last ) :=
            num_char_join_obj( p_parents( i ).id,
                               get_children_index_scan( v_index( p_parents( i ).id ), p_children ) );
         end loop;
         return v_result;
      end;

   function nl_index_scan_join( p_size_outer binary_integer, p_size_inner binary_integer ) return num_char_join_coll is
      begin
         return nl_index_scan_join(
            collection_gen.get_unsorted_uniq_collection( p_size_outer ),
            collection_gen.get_unsorted_nuniq_collection( p_size_inner, ceil( p_size_inner / p_size_outer ) )
         );
      end;

   function sort_merge_join( p_parents num_char_coll, p_children num_char_coll ) return num_char_join_coll is
      v_parents_sorted  num_char_coll;
      v_children_sorted num_char_coll;
      v_parents_count   binary_integer;
      v_result          num_char_join_coll := num_char_join_coll( );
      v_child_position  binary_integer := 1;
      begin
         v_parents_sorted := sort_collection( p_parents );
         v_children_sorted := sort_collection( p_children );
         v_parents_count   := cardinality( v_parents_sorted );
         for i in 1 .. v_parents_count loop
            v_result.extend;
            v_result( v_result.last ) :=
            num_char_join_obj( v_parents_sorted( i ).id, get_children_sorted_scan( v_parents_sorted( i ).id, v_child_position, v_children_sorted ) );
         end loop;
         return v_result;
      end;

   function sort_merge_join( p_size_outer binary_integer, p_size_inner binary_integer ) return num_char_join_coll is
      begin
         return sort_merge_join(
            collection_gen.get_unsorted_uniq_collection( p_size_outer ),
            collection_gen.get_unsorted_nuniq_collection( p_size_inner, ceil( p_size_inner / p_size_outer ) )
         );
      end;

   function hash_join( p_size_outer binary_integer, p_size_inner binary_integer ) return num_char_join_coll is
      begin
         return null;
      end;

end;
/
