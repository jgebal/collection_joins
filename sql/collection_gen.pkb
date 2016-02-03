create or replace package body collection_gen as

   function get_unsorted_uniq_collection( p_size binary_integer := 100 ) return num_char_coll is
      v_size   binary_integer := coalesce( p_size, 0 );
      v_result num_char_coll := num_char_coll( );
      begin
         if p_size > 0 then
            select num_char_obj( rownum, 'name ' || rownum )
            bulk collect into v_result
            from dual
            connect by level <= p_size
            order by ora_hash( rownum, p_size );
         end if;
         return v_result;
      end;

   function get_unsorted_nuniq_collection(
      p_size               binary_integer := 1000,
      p_duplication_factor binary_integer := 10
   ) return num_char_coll is
      v_coll      num_char_coll;
      v_coll_size binary_integer;
      v_result    num_char_coll := num_char_coll( );
      begin
         if p_duplication_factor > 0 then
            v_coll_size := ceil( p_size / p_duplication_factor );
            v_coll := get_unsorted_uniq_collection( v_coll_size );
            while v_result.count < p_size loop
               v_result.extend;
               v_result( v_result.last ) := v_coll( ceil( v_result.count / p_duplication_factor ) );
            end loop;
         end if;
         return v_result;
      end;

end;
/
