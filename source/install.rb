require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/uninstall.sql',
  '../../../sql/num_char_obj.tps',
  '../../../sql/num_char_coll.tps',
  '../../../sql/num_char_join_obj.tps',
  '../../../sql/num_char_join_coll.tps',
  '../../../sql/collection_gen.pks',
  '../../../sql/collection_join.pks',
  '../../../sql/collection_gen.pkb',
  '../../../sql/collection_join.pkb',
].each { |file| execute_sqlplus_file(file) }
