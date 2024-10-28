# Week 2 Answers (Part 3)

## Background

Let's update our products snapshot that we created last week to see how our data is changing.

## Questions

### Question 1

**Run the product snapshot model using dbt snapshot and query it in snowflake to see how the data has changed since last week.**

I ran the snapshot by running

```bash
dbt snapshot
```

and I got the following output to indicate the inventory snapshot was successfully updated
```bash
00:46:24  Running with dbt=1.8.7
00:46:24  Registered adapter: snowflake=1.8.4
00:46:24  Found 67 models, 1 snapshot, 1 seed, 208 data tests, 7 sources, 633 macros
00:46:24  
00:46:26  Concurrency: 1 threads (target='dev')
00:46:26  
00:46:26  1 of 1 START snapshot <schema>.inventory_snapshot ................... [RUN]
00:46:30  1 of 1 OK snapshotted <schema>.inventory_snapshot ................... [SUCCESS 12 in 3.92s]
00:46:30  
00:46:30  Finished running 1 snapshot in 0 hours 0 minutes and 5.45 seconds (5.45s).
00:46:30  
00:46:30  Completed successfully
00:46:30  
00:46:30  Done. PASS=1 WARN=0 ERROR=0 SKIP=0 TOTAL=1
```

### Question 2

**Which products had their inventory change from week 1 to week 2?**

I identified changes in the snapshot table, by confirming that the `dbt_valid_to` column of this table does not contain missing values for some products (rows) in this table using the following query
```sql
SELECT COUNT(*) AS num_changes
FROM inventory_snapshot
WHERE dbt_valid_to IS NOT NULL
```

This gives a `num_changes` column with a value of six, which indicated that six products had their inventory change.

To identify the products which had their inventory change from week 1, I modified the above query to return all rows instead of a count
```sql
SELECT *
FROM inventory_snapshot
WHERE dbt_valid_to IS NOT NULL
```

Based on the output of this query, the following six products had their inventory change from week 1 to week 2

```bash
4cda01b9-62e2-46c5-830f-b7f262a58fb1 (Pothos)
55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3 (Philodendron)
689fb64e-a4a2-45c5-b9f2-480c2155624d (Bamboo)
b66a7143-c18a-43bb-b5dc-06bb5d1d3160 (ZZ Plant)
be49171b-9f72-4fc9-bf7a-9a52e259836b (Monstera)
fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80 (String of pearls)
```

The product ID is shown, with the product name in parentheses.
