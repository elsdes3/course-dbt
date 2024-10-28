# Week 2 Answers (Part 2)

## Background

We added some more models and transformed some data! Now we need to make sure they're accurately reflecting the data. Add dbt tests into your dbt project on your existing models from Week 1, and new models from the section above.

## Questions

### Question 1

**What assumptions are you making about each model? (i.e. why are you adding each test?)**

I am assuming that

1. new data also falls in to the range of old data
2. occurrences of missing values from the a subset of a few rows applies to all other rows

### Question 2

**Did you find any "bad" data as you added and ran tests on your models? How did you go about either cleaning the data in the dbt model or adjusting your assumptions/tests?**

Yes, I found occurrences of bad data. I modified the tests to the models to handle these occurrences.

Below are some models with ocurrences of bad data that required modification of tests

1. in the `int_orders_joined_to_addresses_promos` and `fct_orders` models, the following columns contain missing values if
   - a user has not placed an order
     - `order_cost`
     - `shipping_cost`
     - `order_total`
     - `total_order_size`
     - `num_unique_products`
     - `estimated_delivery_at`
     - `status` (order status)
     - (`fct_orders`) `estimated_delivery_time_seconds`
     - (`fct_orders`) `delivery_time_seconds`
     - (`fct_orders`) `delivery_delay_seconds`
   - an order has not been delivered
     - `delivered_at`
   - no promocode was redeemed in an order
     - `promo_id`
     - `discount`

   For all these columns in these models, I had to remove the `not_null` test.

### Question 3 Part 1

**Your stakeholders at Greenery want to understand the state of the data each day. Explain how you would ensure these tests are passing regularly.**

I would run DBT tests on a daily schedule using a workflow step in a workflow orchestrator. I would ask for a dedicated team to be available to monitor data quality through the data test step in the workflow on a daily basis.

I would notify the business unit that they can assess the state of Greenery data at 3PM daily.

I would setup two workflows to ingest data at daily

1. the first workflow runs data models and DBT tests on new data available at 3PM
2. the second workflow runs models and tests on all data at midnight (nine hours later)

A Slack notification and email alert will be setup to notify data owners of failing tests in either of these workflows. Both workflows would implement the same test suite.

(For workflow 1) I would expect that the subset of the new data (which is available at 3PM) is smaller in size (fewer records) than all the data so tests on it should run and complete faster. Failing tests can be flagged sooner so the owners of the data can start working on fixes sooner. I would expect that fixes on the subset of the new data also work on all data.

For failing tests on all data (which are detected at midnight), I would required that data contract owners respond to the Slack notification or email about failing tests by no later the start of the working day at 8AM. They can leverage learnings from fixes on subset to implement fixes on the full set of data. The data owner has between 8AM and 3PM to implement fixes to the test suite to ensure tests on all the data pass before the business unit(s) can access it.

### Question 3 Part 2

**Explain how you would alert stakeholders about bad data getting through.**

If the business is using model ouputs in a dashboard using a BI tool then I would ask them to update their dashboard with new data through a step in the daily workflow that conditionally runs if DBT tests are passing. This would ensure that the dashboard (business deliverable) contains outdated data if the tests fail. I would also work with the dashboard developer to place a note on the dashboard indicating that it is not showing the latest data due to **failing data model tests**.

In summary, I would alert stakeholders (business users) about bad data getting through in the following ways

1. send email to stakeholder
2. post on Slack (or equivalent)
3. (mentioned above, if possible) work with dashboard developer to display message on dashboard to
   - indicate failing DBT tests
   - block update of dashboard (to retrieve new data), which will result in an out-of-date but accurate dashboard (deliverable)
