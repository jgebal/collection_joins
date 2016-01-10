create or replace package collection_sorter as

   function get_unique_collection( p_size integer := 10000 ) return num_char_coll;

   function get_sample_data( p_coll num_char_coll, p_sample_pct number ) return num_char_coll;

end;
/
