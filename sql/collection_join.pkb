create or replace package body collection_join as

   function nested_loop_full(p_size_outer integer, p_size_inner integer) return num_char_join_coll is
      v_master      num_char_coll;
      v_detail      num_char_coll;
      v_master_size integer;
      v_detail_size integer;
      v_result      num_char_join_coll := num_char_join_coll();
      begin
         v_master := collection_gen.get_sample_data( p_size_outer, 10 );
         v_detail := collection_gen.get_duplicated_collection( p_size_inner, ceil(p_size_inner/p_size_outer) );
         v_master_size := cardinality(v_master);
         v_detail_size := cardinality(v_detail);
         for i in 1 .. v_master_size loop
            v_result.extend;
            v_result(v_result.last) :=  num_char_join_obj( v_master(i).id, num_char_coll() );
            for j in 1 .. v_detail_size loop
               if v_master( i ).id = v_detail( j ).id then
                  v_result( v_result.last ).children.extend;
                  v_result( v_result.last ).children( v_result( v_result.last ).children.last ) := v_detail( j );
               end if;
            end loop;
         end loop;
         return v_result;
      end;

   function nested_loop_index(p_size_outer integer, p_size_inner integer) return num_char_join_coll is
      begin
         return null;
      end;

   function sort_merge_join(p_size_outer integer, p_size_inner integer) return num_char_join_coll is
      begin
         return null;
      end;

   function hash_join(p_size_outer integer, p_size_inner integer) return num_char_join_coll is
      begin
         return null;
      end;

end;
/
