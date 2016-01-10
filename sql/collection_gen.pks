create or replace package collection_gen as

   function get_unique_collection( p_size integer := 10000 ) return num_char_coll;

   function get_sample_data( p_num_rows integer, p_sample_pct integer ) return num_char_coll;

   function get_duplicated_collection( p_num_rows integer, p_duplication_factor integer ) return num_char_coll;

end;
/
