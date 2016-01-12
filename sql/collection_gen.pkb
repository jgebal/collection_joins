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
      v_coll_size binary_integer := p_size / p_duplication_factor;
      v_result    num_char_coll := num_char_coll( );
      begin
         v_coll := get_unsorted_uniq_collection( v_coll_size );
         for i in 1 .. v_coll_size loop
            for j in 1 .. p_duplication_factor loop
               v_result.extend;
               v_result( v_result.last ) := v_coll( i );
            end loop;
         end loop;
         return v_result;
      end;

end;
/
