create or replace package collection_join as

   function nested_loop_full( p_size_outer integer, p_size_inner integer ) return num_char_join_coll;

   function nested_loop_index( p_size_outer integer, p_size_inner integer ) return num_char_join_coll;

   function sort_merge_join( p_size_outer integer, p_size_inner integer ) return num_char_join_coll;

   function hash_join( p_size_outer integer, p_size_inner integer ) return num_char_join_coll;

end;
/
