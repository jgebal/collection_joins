create or replace package body collection_gen as

   function get_unique_collection( p_size integer := 10000 ) return num_char_coll is
      v_size   integer := coalesce(p_size, 0);
      v_result num_char_coll := num_char_coll();
      begin
         for i in 1 .. v_size loop
            v_result.extend;
            v_result(i) := num_char_obj(i, 'name '||i);
         end loop;
         return v_result;
      end;

   function get_sample_data( p_num_rows integer, p_sample_pct integer ) return num_char_coll is
      v_coll      num_char_coll;
      v_coll_size integer;
      v_result    num_char_coll := num_char_coll();
      begin
         v_coll := get_unique_collection( p_num_rows*p_sample_pct );
         v_coll_size := cardinality( v_coll );
         --ora_hash(string,buckets-1) = dbms_utility.get_hash_value(string,0,buckets)
         --from comment in: https://jonathanlewis.wordpress.com/2009/11/21/ora_hash-function/
--          for i in 1 .. v_coll_size loop
--             if dbms_utility.get_hash_value( v_coll(i).id, 0, v_coll_size  ) <= v_coll_size * (p_sample_pct+1) / 100 then
--                v_result.extend;
--                v_result(v_result.last) := v_coll(i);
--             end if;
--             exit when v_result.count = p_num_rows;
--          end loop;
--          return v_result;
          --alternative
         select num_char_obj( id, name )
           bulk collect into v_result
           from table( v_coll )
          where ora_hash( id, v_coll_size - 1 ) <= v_coll_size * p_sample_pct+1 / 100
            and rownum <= p_num_rows
         order by ora_hash( id, v_coll_size - 1 );
         return v_result;
      end;

   function get_duplicated_collection( p_num_rows integer, p_duplication_factor integer ) return num_char_coll is
      v_coll      num_char_coll;
      v_coll_size integer;
      v_result    num_char_coll := num_char_coll();
      begin
         v_coll := get_sample_data( p_num_rows/p_duplication_factor, 10 );
         v_coll_size := cardinality( v_coll );
         for i in 1 .. v_coll_size loop
            for j in 1 .. p_duplication_factor loop
               v_result.extend;
               v_result(v_result.last) := v_coll(i);
            end loop;
         end loop;
         return v_result;
      end;

end;
/
