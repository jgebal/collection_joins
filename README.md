# Sample project to provide means of one to many left joining collections in Oracle PL/SQL

For the purpose of this sample project following types are being used.

- [An object](sql/a_demo_object.tps) representing the contents of the collection to be joined

```sql
create or replace type a_demo_object as object (
   id number,
   name varchar2(100)
);
/
```

- [A collection of those objects](sql/a_demo_collection.tps) is used as inputs for joining

```sql
create or replace type a_demo_collection as table of a_demo_object;
/
```

- [A join result object](sql/a_demo_join_object.tps) representing the outcomes of one to many outer join
 
```sql
create or replace type a_demo_join_object as object (
   id number,
   children a_demo_collection
);
/
```

- [A collection of join results](sql/a_demo_join_collection.tps) is used as outcome of join functions

```sql
create or replace type a_demo_join_collection as table of a_demo_join_object;
/
```

# Description

There are currently three different join methods implemented:
 - Nested loops outer join with full scan of the inner collection. The method has complexity `n*m`, causing computation intensity to grow exponentially.
 - Nested loops outer join with index-like scan of the inner collection. First an index is build on inner collection, then access is done via index-path. Complexity ` x*m + y*(m+n)` where x is number of steps needed to build index and y is the number of steps needed to link the two.
 - Sort-merge outer join. First both collections are sorted, then each element is accessed exactly once while joining. Complexity ` a*(m+n) + b*(m+n)` where a is number of steps needed to sort the collection and b is the number of steps needed to link the two.

Both sort-merge and nested loops with index should provide quite linear performance with the growth of amount of data processed.

# Usage

Example of joining two collections:
```sql
select *
  from table( 
     collection_outer_join.nl_index_scan_join(
        a_demo_collection(a_demo_object(1,'a')),
        a_demo_collection(
            a_demo_object(1,'a'),
            a_demo_object(1,'a')
        )
     )
  );

--join 100 sample rows with 1000 sample rows
select * from table( collection_outer_join.nl_index_scan_join(100, 1000) );
select * from table( collection_outer_join.sort_merge_join(100, 1000) );
select * from table( collection_outer_join.nl_full_scan_join(100, 1000) );
```

You may use the examples provided here as you find them useful.

Additional package collection_gen was added only for demo and testing purposes.

# Performance

RUN_COMMENT|TOTAL_TIME_MILI_SEC
-----------|-------------------
nl_full_scan_join 1,000 parents 20,000 children|178,320
nl_index_scan_join 1,000 parents 20,000 children|900
sort_merge_join 1,000 parents 20,000 children|1,130
nl_index_scan_join 40,000 parents 400,000 children|20,720
sort_merge_join 40,000 parents 400,000 children|27,330
nl_index_scan_join 10,000 parents 1,000,000 children|46,810
sort_merge_join 10,000 parents 1,000,000 children|70,040

The code was profiled using DBMSL_PROFILER.
- The `nl_full_scan_join` is slowest
- The `nl_index_scan_join` is fastest 
- The `sort_merge_join` would be as fast as nested loops, but requires sorting that takes extra hit on performance.

[Here](sql/profiler_outcomes.html) you may see the full outcomes of the profiler runs. 
