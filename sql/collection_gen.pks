create or replace package collection_gen as

   function get_unsorted_uniq_collection( p_size binary_integer := 100 ) return a_demo_collection;

   function get_unsorted_nuniq_collection(
      p_size               binary_integer := 1000,
      p_duplication_factor number := 10
   ) return a_demo_collection;

end;
/
