# Week 3 Answers (Part 6)

## Background

Let's update our products snapshot again to see how our data is changing:

## Questions

### Question 1

**Run the products snapshot model using dbt snapshot and query it in snowflake to see how the data has changed since last week.**

I ran the snapshot by running

```bash
dbt snapshot
```

and I got the following output to indicate the inventory snapshot was successfully updated
```bash
21:27:10  Running with dbt=1.8.7
21:27:10  Registered adapter: snowflake=1.8.4
21:27:11  Found 1 snapshot, 69 models, 1 seed, 336 data tests, 7 sources, 910 macros
21:27:11  
21:27:13  Concurrency: 1 threads (target='dev')
21:27:13  
21:27:13  1 of 1 START snapshot dbt_<schema-name>.inventory_snapshot ................... [RUN]
21:27:16  1 of 1 OK snapshotted dbt_<schema-name>.inventory_snapshot ................... [SUCCESS 12 in 3.54s]
21:27:16  
21:27:16  Finished running 1 snapshot in 0 hours 0 minutes and 5.30 seconds (5.30s).
21:27:17  
21:27:17  Completed successfully
21:27:17  
21:27:17  Done. PASS=1 WARN=0 ERROR=0 SKIP=0 TOTAL=1
```

### Question 2

**Which products had their inventory change from week 2 to week 3?**

The following six products had their inventory change from week 1 to week 2

1. `b66a7143-c18a-43bb-b5dc-06bb5d1d3160` (ZZ Plant)
   - inventory decreased by 12
2. `689fb64e-a4a2-45c5-b9f2-480c2155624d` (Bamboo)
   - inventory decreased by 21
3. `55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3` (Philodendron)
   - inventory increased by 15
4. `be49171b-9f72-4fc9-bf7a-9a52e259836b` (Monstera)
   - inventory decreased by 19
5. `fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80` (String of pearls)
   - inventory increased by 10
6. `4cda01b9-62e2-46c5-830f-b7f262a58fb1` (Pothos)
   - inventory increased by 20

The product ID is shown, with the product name in parentheses.
