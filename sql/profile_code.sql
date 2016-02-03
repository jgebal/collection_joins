delete from plsql_profiler_data;
delete from plsql_profiler_units;
delete from plsql_profiler_runs;
commit;


alter package collection_gen compile debug;
alter package collection_outer_join compile debug;

declare
   v_dummy integer;
begin
--    dbms_profiler.START_PROFILER('nl_full_scan_join 2,000 parents 20,000 children');
--    select count(1) into v_dummy
--    from table( collection_outer_join.nl_full_scan_join(2000, 20000) );
--    dbms_profiler.STOP_PROFILER();

   dbms_profiler.START_PROFILER('nl_index_scan_join 2,000 parents 20,000 children');
   select count(1) into v_dummy
   from table( collection_outer_join.nl_index_scan_join(2000, 20000) );
   dbms_profiler.STOP_PROFILER();

   dbms_profiler.START_PROFILER('sort_merge_join 2,000 parents 20,000 children');
   select count(1) into v_dummy
   from table( collection_outer_join.sort_merge_join(2000, 20000) );
   dbms_profiler.STOP_PROFILER();

--    dbms_profiler.START_PROFILER('nl_index_scan_join 100,000 parents 400,000 children');
--    select count(1) into v_dummy
--    from table( collection_outer_join.nl_index_scan_join(100000, 400000) );
--    dbms_profiler.STOP_PROFILER();
--
--    dbms_profiler.START_PROFILER('sort_merge_join 100,000 parents 400,000 children');
--    select count(1) into v_dummy
--    from table( collection_outer_join.sort_merge_join(100000, 400000) );
--    dbms_profiler.STOP_PROFILER();
--
--    dbms_profiler.START_PROFILER('nl_index_scan_join 10,000 parents 500,000 children');
--    select count(1) into v_dummy
--    from table( collection_outer_join.nl_index_scan_join(10000, 500000) );
--    dbms_profiler.STOP_PROFILER();
--
--    dbms_profiler.START_PROFILER('sort_merge_join 10,000 parents 500,000 children');
--    select count(1) into v_dummy
--    from table( collection_outer_join.sort_merge_join(10000, 500000) );
--    dbms_profiler.STOP_PROFILER();
end;
/


select
       plsql_profiler_runs.run_comment,
       plsql_profiler_runs.run_total_time/1000000 as total_time_mili_sec,
       sum(plsql_profiler_data.total_occur) over (partition by plsql_profiler_units.runid) as total_line_executions,
       plsql_profiler_data.total_occur as line_executions,
       plsql_profiler_data.total_time/1000000 as line_time_mili_sec,
       round((plsql_profiler_data.total_time/plsql_profiler_runs.run_total_time)*100,2) as pct_of_total_run_time,
       plsql_profiler_units.unit_name,
       plsql_profiler_data.line#,
       dba_source.text
from plsql_profiler_runs
   join plsql_profiler_units
      on plsql_profiler_runs.runid = plsql_profiler_units.runid
   join plsql_profiler_data
      on plsql_profiler_units.runid = plsql_profiler_data.runid
         and plsql_profiler_units.unit_number = plsql_profiler_data.unit_number
   join dba_source
      on dba_source.type='PACKAGE BODY' and
         dba_source.owner = plsql_profiler_units.unit_owner and
         dba_source.line = plsql_profiler_data.line# and
         dba_source.name = plsql_profiler_units.unit_name
    where round((plsql_profiler_data.total_time/plsql_profiler_runs.run_total_time)*100,2) > 0.01
          and plsql_profiler_units.unit_name = 'COLLECTION_OUTER_JOIN'
order by runid, plsql_profiler_data.total_time desc
;
