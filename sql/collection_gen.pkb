create or replace package body collection_gen as

   function get_unsorted_uniq_collection( p_size binary_integer := 100 ) return a_demo_collection is
      v_size   binary_integer := coalesce( p_size, 0 );
      v_result a_demo_collection := a_demo_collection( );
      begin
         if p_size > 0 then
            select a_demo_object( rownum, 'name ' || rownum )
            bulk collect into v_result
            from dual
            connect by level <= p_size
            order by ora_hash( rownum, p_size );
         end if;
         return v_result;
      end;

   function get_unsorted_nuniq_collection(
      p_size               binary_integer := 1000,
      p_duplication_factor number := 10
   ) return a_demo_collection is
      v_coll      a_demo_collection;
      v_coll_size binary_integer;
      v_result    a_demo_collection := a_demo_collection( );
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
