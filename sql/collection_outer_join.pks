create or replace package collection_outer_join as

   function sort_collection( p_collection a_demo_collection ) return a_demo_collection;

   function nl_full_scan_join( p_parents a_demo_collection, p_children a_demo_collection ) return a_demo_join_collection;

   function nl_full_scan_join( p_size_outer binary_integer, p_size_inner binary_integer ) return a_demo_join_collection;

   function nl_index_scan_join( p_parents a_demo_collection, p_children a_demo_collection ) return a_demo_join_collection;

   function nl_index_scan_join(p_size_outer binary_integer, p_size_inner binary_integer) return a_demo_join_collection;

   function sort_merge_join( p_parents a_demo_collection, p_children a_demo_collection ) return a_demo_join_collection;

   function sort_merge_join( p_size_outer binary_integer, p_size_inner binary_integer ) return a_demo_join_collection;

   function hash_join( p_size_outer binary_integer, p_size_inner binary_integer ) return a_demo_join_collection;

end;
/
