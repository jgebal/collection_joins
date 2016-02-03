create or replace package body collection_outer_join as

   --index type declarations
   type collection_index_entry_t is table of binary_integer index by binary_integer;

   --   type collection_index_t is table of element_pos_indexes_t index by varchar2 (100);
   type collection_index_t is table of collection_index_entry_t index by binary_integer;

   --private functions
   function build_collection_index( p_collection a_demo_collection ) return collection_index_t is
      v_size   binary_integer := cardinality( p_collection );
      v_result collection_index_t;
      begin
         for i in 1..v_size loop
            begin
               v_result( p_collection( i ).id )( v_result( p_collection( i ).id ).last + 1 ) := i;
               exception
               when no_data_found then
               v_result( p_collection( i ).id )( 1 ) := i;
            end;
         end loop;
         return v_result;
      end;

--    function build_collection_index( p_collection a_demo_collection ) return collection_index_t is
--       v_size            binary_integer := cardinality( p_collection );
--       v_result          collection_index_t;
--       v_index_key       binary_integer;
--       v_idx_element_pos binary_integer;
--       begin
--          for i in 1..v_size loop
--             v_index_key := p_collection( i ).id;
--             begin
--                v_idx_element_pos := v_result( v_index_key ).last + 1;
--                exception
--                when no_data_found then
--                v_idx_element_pos := 1;
--             end;
--             v_result( v_index_key )( v_idx_element_pos ) := i;
--          end loop;
--          return v_result;
--       end;

   function get_children_full_scan( p_parent_id number, p_children a_demo_collection ) return a_demo_collection is
      v_children_count binary_integer := cardinality( p_children );
      v_result         a_demo_collection := a_demo_collection( );
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
      p_element binary_integer, p_index collection_index_t, p_children a_demo_collection
   ) return a_demo_collection is
      v_index_branch_count binary_integer;
      v_result             a_demo_collection := a_demo_collection( );
      begin
         if p_index.exists( p_element ) then
            v_index_branch_count := p_index( p_element ).count;
            v_result.extend( v_index_branch_count );
            for i in 1 .. v_index_branch_count loop
               v_result( i ) := p_children( p_index( p_element )( i ) );
            end loop;
         end if;
         return v_result;
      end;

   function get_children_sorted_scan(
      p_parent_id number, v_child_position in out nocopy binary_integer, p_children a_demo_collection
   ) return a_demo_collection is
      v_result a_demo_collection := a_demo_collection( );
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
   function sort_collection( p_collection a_demo_collection ) return a_demo_collection is
      v_index  collection_index_t;
      v_result a_demo_collection := a_demo_collection( );
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

   function nl_full_scan_join( p_parents a_demo_collection, p_children a_demo_collection ) return a_demo_join_collection is
      v_parents_count binary_integer := cardinality( p_parents );
      v_result        a_demo_join_collection := a_demo_join_collection( );
      begin
         for i in 1 .. v_parents_count loop
            v_result.extend;
            v_result( v_result.last ) :=
               a_demo_join_object( p_parents( i ).id, get_children_full_scan( p_parents( i ).id, p_children ) );
         end loop;
         return v_result;
      end;

   function nl_full_scan_join( p_size_outer binary_integer, p_size_inner binary_integer ) return a_demo_join_collection is
      begin
         return nl_full_scan_join(
            collection_gen.get_unsorted_uniq_collection( p_size_outer ),
            collection_gen.get_unsorted_nuniq_collection( p_size_inner, p_size_inner / p_size_outer )
         );
      end;

   function nl_index_scan_join( p_parents a_demo_collection, p_children a_demo_collection ) return a_demo_join_collection is
      v_parents_count binary_integer := cardinality( p_parents );
      v_index         collection_index_t;
      v_result        a_demo_join_collection := a_demo_join_collection( );
      begin
         v_index := build_collection_index( p_children );
         for i in 1 .. v_parents_count loop
            v_result.extend;
            v_result( v_result.last ) :=
               a_demo_join_object( p_parents( i ).id,
                               get_children_index_scan( p_parents( i ).id, v_index, p_children ) );
         end loop;
         return v_result;
      end;

   function nl_index_scan_join( p_size_outer binary_integer, p_size_inner binary_integer ) return a_demo_join_collection is
      begin
         return nl_index_scan_join(
            collection_gen.get_unsorted_uniq_collection( p_size_outer ),
            collection_gen.get_unsorted_nuniq_collection( p_size_inner, p_size_inner / p_size_outer )
         );
      end;

   function sort_merge_join( p_parents a_demo_collection, p_children a_demo_collection ) return a_demo_join_collection is
      v_parents_sorted  a_demo_collection;
      v_children_sorted a_demo_collection;
      v_parents_count   binary_integer;
      v_result          a_demo_join_collection := a_demo_join_collection( );
      v_child_position  binary_integer := 1;
      begin
         v_parents_sorted := sort_collection( p_parents );
         v_children_sorted := sort_collection( p_children );
         v_parents_count := cardinality( v_parents_sorted );
         for i in 1 .. v_parents_count loop
            v_result.extend;
            v_result( v_result.last ) :=
               a_demo_join_object( v_parents_sorted( i ).id,
                               get_children_sorted_scan( v_parents_sorted( i ).id, v_child_position,
                                                         v_children_sorted ) );
         end loop;
         return v_result;
      end;

   function sort_merge_join( p_size_outer binary_integer, p_size_inner binary_integer ) return a_demo_join_collection is
      begin
         return sort_merge_join(
            collection_gen.get_unsorted_uniq_collection( p_size_outer ),
            collection_gen.get_unsorted_nuniq_collection( p_size_inner, p_size_inner / p_size_outer )
         );
      end;

   function hash_join( p_size_outer binary_integer, p_size_inner binary_integer ) return a_demo_join_collection is
      begin
         return null;
      end;

end;
/
