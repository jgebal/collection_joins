create or replace package body collection_sorter as

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

   function get_sample_data( p_coll num_char_coll, p_sample_pct number ) return num_char_coll is
      v_coll_size integer := cardinality( p_coll );
      v_result    num_char_coll := num_char_coll();
      begin
         --ora_hash(string,buckets-1) = dbms_utility.get_hash_value(string,0,buckets)
         --from comment in: https://jonathanlewis.wordpress.com/2009/11/21/ora_hash-function/
--          for i in 1 .. v_coll_size loop
--            if dbms_utility.get_hash_value( p_coll(i).id, 0, v_coll_size  ) <= v_coll_size * p_sample_pct / 100 then
--               v_result.extend;
--               v_result(v_result.last) := p_coll(i);
--            end if;
--          end loop;
--          return v_result;
         --alternative
         select num_char_obj( id, name )
           bulk collect into v_result
           from table( p_coll )
          WHERE ORA_HASH( id, v_coll_size - 1 ) <= v_coll_size * p_sample_pct / 100;
         return v_result;
      end;

end;
/
