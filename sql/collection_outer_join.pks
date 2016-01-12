create or replace package collection_outer_join as

   function sort_collection( p_collection num_char_coll ) return num_char_coll;

   function nl_full_scan_join( p_parents num_char_coll, p_children num_char_coll ) return num_char_join_coll;

   function nl_full_scan_join( p_size_outer binary_integer, p_size_inner binary_integer ) return num_char_join_coll;

   function nl_index_scan_join( p_parents num_char_coll, p_children num_char_coll ) return num_char_join_coll;

   function nl_index_scan_join(p_size_outer binary_integer, p_size_inner binary_integer) return num_char_join_coll;

   function sort_merge_join( p_parents num_char_coll, p_children num_char_coll ) return num_char_join_coll;

   function sort_merge_join( p_size_outer binary_integer, p_size_inner binary_integer ) return num_char_join_coll;

   function hash_join( p_size_outer binary_integer, p_size_inner binary_integer ) return num_char_join_coll;

end;
/
