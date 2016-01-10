require_relative 'support/execute_sqlplus_file'

[
  '../../../sql/uninstall.sql',
  '../../../sql/num_char_obj.tps',
  '../../../sql/num_char_coll.tps',
  '../../../sql/collection_sorter.pks',
  '../../../sql/collection_sorter.pkb',
].each { |file| execute_sqlplus_file(file) }
