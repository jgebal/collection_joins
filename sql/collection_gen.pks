create or replace package collection_gen as

   function get_unsorted_uniq_collection( p_size binary_integer := 100 ) return num_char_coll;

   function get_unsorted_nuniq_collection(
      p_size               binary_integer := 1000,
      p_duplication_factor binary_integer := 10
   ) return num_char_coll;

end;
/
