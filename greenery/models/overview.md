{% docs __overview__ %}

# Greenery Platform

## Overview

Welcome to the home page for the `dbt` documentation for Greenery's data models.

## Project Structure

The models are organized into a project structure that follows [**`dbt` Best Practices**](https://docs.getdbt.com/best-practices/how-we-structure/1-guide-overview)

1. `staging` models consist of light transformations being applied to clean the source data
2. `intermediate` models are stored in separate sub-folders and are created for (a) products and (b) orders. Since `intermediate` models were created at different levels (orders and products) it was decided to create an `intermediate` folder at the root of the `models` directory. This resulted in two sub-folders (`intermediate/orders` and `intermediate/products`) within the parent `intermediate` folder. A separate nested `intermediate` sub-folder was not created within each `marts` folder for two reasons (a) three such folders would be needed, one for each `marts` model, (b) the `intermediate/orders` models are used by both the `core` and `marketing` business units. Creating a separate`intermediate` folder that is not nested within `marts` avoided repeating SQL code in those `intermediate` models.
3. `marts` models are organized into separate sub-folders for each intended business user (a) marketing team (`marketing` folder), (b) multiple teams (`core` folder, primarily the operations team) and (c) product team (`product` folder, since metrics were calculated at two levels, overall and per day, two sub-folders are created within the `product` folder)

## Tests

A suite of tests was implemented using

1. `dbt`'s built-in testing utilities
2. custom-written generic tests, placed in `tests/generic`

More complex tests are implemented macros provided by two `dbt` packages

1. `dbt-expectations`, which is a package designed to bring the power of the [Great Expectations](https://greatexpectations.io/) framework to ensure data quality to data models in `dbt`
2. `dbt-utils`

Some of the macros that are predominantly used to test Greenery's data models are listed later.

## Custom Macros

A custom set of macros has been developed to simplify and improve data model DAGs. All macros are placed in the `macros` sub-folder and are fully documented.

## Source Code

**Check out the source code for this project on Github [here](https://github.com/elsdes3/course-dbt/tree/main/greenery).**

{% enddocs %}

{% docs __dbt_expectations__ %}
## Testing Macros

This project heavily uses a [suite of testing macros](https://hub.getdbt.com/calogica/dbt_expectations/latest/), especially

1. [`expect_table_columns_to_match_ordered_list`](https://github.com/calogica/dbt-expectations/tree/0.10.4/#expect_table_columns_to_match_ordered_list), to test that the expected column names and column order are found in source data
2. [`expect_column_distinct_count_to_equal_other_table`](https://github.com/calogica/dbt-expectations/tree/0.10.4/#expect_column_distinct_count_to_equal_other_table), to test that the number of unique values in a model matches the number expected in a different model
3. [`expect_column_values_to_be_of_type`](https://github.com/calogica/dbt-expectations/tree/0.10.4/#expect_column_values_to_be_of_type), to test the expected data type is returned for timestamp columns
4. [`expect_table_row_count_to_equal`](https://github.com/calogica/dbt-expectations/tree/0.10.4/#expect_table_row_count_to_equal), to test that the expected number of rows are returned by the model
5. [`expect_column_values_to_match_regex`](expect_column_values_to_match_regex), to test the validity of email addresses and phone numbers
6. [`expect_column_values_to_match_like_pattern`](https://github.com/calogica/dbt-expectations/tree/0.10.4/#expect_column_values_to_match_like_pattern), to test the validity of email addresses and phone numbers
7. [`expect_column_value_lengths_to_equal`](expect_column_value_lengths_to_equal), to test the validity of phone numbers
{% enddocs %}

{% docs __dbt_utils__ %}
## Utility Macros

This project also uses [a suite of utility macros](https://github.com/dbt-labs/dbt-utils), especially those designed to implement [generic `dbt` tests](https://docs.getdbt.com/docs/build/data-tests)

1. [`expression_is_true`](https://github.com/dbt-labs/dbt-utils/tree/1.3.0/#expression_is_true-source) for running custom SQL to conditionally (a) test that expected relationships exist between multiple columns in a single model and (b) test that column values are above, below or equal to thresholds
{% enddocs %}
