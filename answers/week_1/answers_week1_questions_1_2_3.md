# Week 1 Answers for Questions 1, 2 and 3

## Question 1. Start a new dbt project

I followed the week 0 instructions to set up a new DBT project.

## Question 2. **Using the greenery source data in our data warehouse, set up the staging models for each source (raw) table (these can be seen in the Data Background diagram above)**

### Part 1 a. **Using the instructions in the set up instructions, setup the dbt project called `greenery` which creates the project folder structure**

I ran

```bash
dbt init
```

and specified the DBT project name as `greenery`. When prompted to choose the databas,e I selected *snowflake*. This created a folder named `greenery` with the following contents

```bash
├── analyses
│   └── .gitkeep
├── dbt_project.yml
├── .gitignore
├── macros
│   └── .gitkeep
├── models
│   └── example
│       ├── my_first_dbt_model.sql
│       ├── my_second_dbt_model.sql
│       └── schema.yml
├── README.md
├── seeds
│   └── .gitkeep
├── snapshots
│   └── .gitkeep
└── tests
    └── .gitkeep
```

I deleted the `models/example` folder.

### Part 1 b. **Using the instructions in the set up instructions, configure the `dbt_project.yml` and `profiles.yml` files with your credentials**

I configured the `models` section from [`dbt_project.yml`](https://github.com/elsdes3/course-dbt/blob/main/greenery/dbt_project.yml) as follows

```bash
models:
  greenery:
    # Config indicated by + and applies to all files under models/staging/
    staging:
      +materialized: view
```

Since I deleted the `models/example` folder, I deleted the entry for `models/example` in this file. The other sections of `dbt_project.yml` were not changed.

In order to configure my `profiles.yml`, I followed the week 0 instructions. I then ran

```bash
dbt debug
```

and confirmed that I could successfully connect to the Snowflake instance.

## Question 2

### Part 2 a. **For all the tables (7) in the greenery schema create and configure a `_postgres__sources.yml` file with the seven sources, and save the file into the `models/staging/postgres/` directory. You'll need to create these directories . The name of your source should be `postgres` since thats where this source data originates.**

I created the DBT sources file at [`models/staging/postgres/_postgres__sources.yml`](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/_postgres__sources.yml) with the name and description of each of the seven tables in the greenery dataset schema.

### Part 2 b. **For all the tables (7) in the greenery schema create staging dbt models in `models/staging/postgres/` for each source (You’ll end up with seven `.sql` files). A good best practice to follow is to not `select *` in your staging model, but explicitly select each column so you can rename and cast as needed.**

I created seven `.sql` files in `models/staging/postgres/` using the seven tables with raw data in the greenery dataset schema. Each file follows this best practice to avoid `select *`.

The model (`.sql`) files are

1. [Addresses](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/stg_postgres_addresses.sql)
2. [Users](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/stg_postgres_users.sql)
3. [Promos](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/stg_postgres_promos.sql)
4. [Products](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/stg_postgres_products.sql)
5. [Orders](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/stg_postgres_orders.sql)
6. [Order Items](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/stg_postgres_order_items.sql)
7. [Events](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/stg_postgres_events.sql)

### Part 2 c. **For all the tables (7) in the greenery schema create a `_postgres__models.yml` file with all of the staging model names and descriptions in the `models/staging/postgres/` directory.**

I created the DBT models file at [`models/staging/postgres/_postgres__models.yml`](https://github.com/elsdes3/course-dbt/blob/main/greenery/models/staging/postgres/_postgres__models.yml) with the name, description and columns of each of the seven `staging/postgres` models.

### Part 3. Run your dbt models against the data warehouse using the `dbt run` command. You should see them build in your personal schema in Snowflake.**

I ran

```bash
dbt run
```

and got the following output to indicate the staging models were successfully created

```bash
17:07:04  Running with dbt=1.8.7
17:07:04  Registered adapter: snowflake=1.8.3
17:07:04  Unable to do partial parsing because a project config has changed
17:07:06  Found 7 models, 7 sources, 454 macros
17:07:06  
17:07:07  Concurrency: 1 threads (target='dev')
17:07:07  
17:07:07  1 of 7 START sql view model <schema>.stg_postgres_addresses ......... [RUN]
17:07:08  1 of 7 OK created sql view model <schema>.stg_postgres_addresses .... [SUCCESS 1 in 0.73s]
17:07:08  2 of 7 START sql view model <schema>.stg_postgres_events ............ [RUN]
17:07:09  2 of 7 OK created sql view model <schema>.stg_postgres_events ....... [SUCCESS 1 in 0.92s]
17:07:09  3 of 7 START sql view model <schema>.stg_postgres_order_items ....... [RUN]
17:07:09  3 of 7 OK created sql view model <schema>.stg_postgres_order_items .. [SUCCESS 1 in 0.60s]
17:07:09  4 of 7 START sql view model <schema>.stg_postgres_orders ............ [RUN]
17:07:10  4 of 7 OK created sql view model <schema>.stg_postgres_orders ....... [SUCCESS 1 in 0.82s]
17:07:10  5 of 7 START sql view model <schema>.stg_postgres_products .......... [RUN]
17:07:11  5 of 7 OK created sql view model <schema>.stg_postgres_products ..... [SUCCESS 1 in 0.59s]
17:07:11  6 of 7 START sql view model <schema>.stg_postgres_promos ............ [RUN]
17:07:12  6 of 7 OK created sql view model <schema>.stg_postgres_promos ....... [SUCCESS 1 in 0.77s]
17:07:12  7 of 7 START sql view model <schema>.stg_postgres_users ............. [RUN]
17:07:12  7 of 7 OK created sql view model <schema>.stg_postgres_users ........ [SUCCESS 1 in 0.79s]
17:07:12  
17:07:12  Finished running 7 view models in 0 hours 0 minutes and 6.57 seconds (6.57s).
17:07:12  
17:07:12  Completed successfully
17:07:12  
17:07:12  Done. PASS=7 WARN=0 ERROR=0 SKIP=0 TOTAL=7
```

I verified that seven views were present in my personal schema in Snowflake using

```sql
SELECT table_catalog,
       table_schema,
       table_name
FROM information_schema.tables
WHERE table_type LIKE '%VIEW'
AND table_schema = '<personal-schema-name>'
```

## Question 3

### Part 3 a. **In the `snapshots/` directory (this is at the same level as the `models/` directory), create a snapshot model using the `products` source of our dbt project that monitors the `inventory` column. Since we want the snapshots to build in your personal schema in Snowflake (and not in the snapshots schema) you'll need to add some additional configs in your snapshot model: `target_database` and `target_schema`. You can keep `target.database` and `target.schema` as is, no need to change these to other values!**

I created a [`snapshots/inventory_snapshot.sql` file](https://github.com/elsdes3/course-dbt/blob/main/greenery/snapshots/inventory_snapshot.sql) with the following contents

```sql
{% snapshot inventory_snapshot %}

    {{
    config(
        target_database=target.database,
        target_schema=target.schema,
        strategy='check',
        unique_key='product_id',
        check_cols=['inventory'],
    )
    }}

    SELECT * FROM {{ source('postgres', 'products') }}

{% endsnapshot %}

```

### Part 3 b. **Run the snapshot model to create it in your schema by running `dbt snapshot`**

I created the snapshot by running

```bash
dbt snapshot
```

and I got the following output to indicate the inventory snapshot was successfully created
```bash
17:07:04  Running with dbt=1.8.7
17:07:04  Registered adapter: snowflake=1.8.3
17:07:04  Unable to do partial parsing because a project config has changed
17:07:06  Found 7 models, 7 sources, 454 macros
17:07:06  
17:07:07  Concurrency: 1 threads (target='dev')
17:07:07  
17:07:07  1 of 7 START sql view model <schema>.stg_postgres_addresses ......... [RUN]
17:07:08  1 of 7 OK created sql view model <schema>.stg_postgres_addresses .... [SUCCESS 1 in 0.73s]
17:07:08  2 of 7 START sql view model <schema>.stg_postgres_events ............ [RUN]
17:07:09  2 of 7 OK created sql view model <schema>.stg_postgres_events ....... [SUCCESS 1 in 0.92s]
17:07:09  3 of 7 START sql view model <schema>.stg_postgres_order_items ....... [RUN]
17:07:09  3 of 7 OK created sql view model <schema>.stg_postgres_order_items .. [SUCCESS 1 in 0.60s]
17:07:09  4 of 7 START sql view model <schema>.stg_postgres_orders ............ [RUN]
17:07:10  4 of 7 OK created sql view model <schema>.stg_postgres_orders ....... [SUCCESS 1 in 0.82s]
17:07:10  5 of 7 START sql view model <schema>.stg_postgres_products .......... [RUN]
17:07:11  5 of 7 OK created sql view model <schema>.stg_postgres_products ..... [SUCCESS 1 in 0.59s]
17:07:11  6 of 7 START sql view model <schema>.stg_postgres_promos ............ [RUN]
17:07:12  6 of 7 OK created sql view model <schema>.stg_postgres_promos ....... [SUCCESS 1 in 0.77s]
17:07:12  7 of 7 START sql view model <schema>.stg_postgres_users ............. [RUN]
17:07:12  7 of 7 OK created sql view model <schema>.stg_postgres_users ........ [SUCCESS 1 in 0.79s]
17:07:12  
17:07:12  Finished running 7 view models in 0 hours 0 minutes and 6.57 seconds (6.57s).
17:07:12  
17:07:12  Completed successfully
17:07:12  
17:07:12  Done. PASS=7 WARN=0 ERROR=0 SKIP=0 TOTAL=7
```

### Part 3 c. **You won't see any changes right now, but we will re-run our snapshots in weeks 2, 3, and 4 to see how our data changes over time!**

I verified the following

1.  an `inventory_snapshot` table was created in my personal schema using
    ```sql
    SELECT table_catalog,
           table_schema,
           table_name
    FROM information_schema.tables
    WHERE table_type LIKE '%TABLE'
    AND table_schema = '<personal-schema-name>'
    ```
2. no changes are visible in the snapshot table, by confirming that the `dbt_valid_to` column of this table contains only missing values by counting the number of non-missing values using
   ```sql
   SELECT COUNT(*) AS num_changes
   FROM inventory_snapshot
   WHERE dbt_valid_to IS NOT NULL
   ```

   This gives a `num_changes` column with a value of 0, which confirms that no changes are currently present in this table in my personal Snowflake schema.
