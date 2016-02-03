require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/uninstall.sql',
  '../../../sql/a_demo_object.tps',
  '../../../sql/a_demo_collection.tps',
  '../../../sql/a_demo_join_object.tps',
  '../../../sql/a_demo_join_collection.tps',
  '../../../sql/collection_gen.pks',
  '../../../sql/collection_outer_join.pks',
  '../../../sql/collection_gen.pkb',
  '../../../sql/collection_outer_join.pkb',
].each { |file| execute_sqlplus_file(file) }
