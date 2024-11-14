# Week 4 Answers (Part 3B)

## Question 1

**Setting up for production / scheduled dbt run of your project And finally, before you fly free into the dbt night, we will take a step back and reflect: after learning about the various options for dbt deployment and seeing your final dbt project, how would you go about setting up a production/scheduled dbt run of your project in an ideal state? You don’t have to actually set anything up - just jot down what you would do and why and post in a README file.**
- **Hints: what steps would you have? Which orchestration tool(s) would you be interested in using? What schedule would you run your project on? Which metadata would you be interested in using? How/why would you use the specific metadata? , etc.**

## Assumptions

I would begin by checking with the business users (product and engineering team) about their reporting cadence. I will assume

1. the business units need the
   - BI dashboard (from week 4 part 2)
   - reports (created by business users)

   to be updated every week on Monday and Wednesday at midnight so that fresh data is available for the teams to use at bi-weekly meetings on Monday/Wednesday afternoon
2. our organization uses dbt Cloud

## dbt Production Run Workflow

I would use Prefect's [`prefect-dbt` Python package](https://docs.prefect.io/integrations/prefect-dbt/index) to orchestrate a scheduled run of my dbt project [using Prefect's support for dbt Cloud](https://www.prefect.io/blog/dbt-and-prefect) twice every week using Prefect's [Interval](https://docs.prefect.io/3.0/automate/add-schedules#interval) schedule. To do this, I would create a Prefect flow with the following tasks

1. Prefect task to run the dbt Cloud job that runs all models
   - this will ensure that data since the last run is captured by the funnel product model
2. Prefect task to run dbt Cloud job that tests all models
   - this is to ensure assumptions about data have not changed since last run
3. Prefect task to run dbt Cloud job to generate dbt documentation, which will be hosted on dbt Cloud
   - this is to ensure that stakeholders can quickly understand and use the funnel data model to generate reports
4. Prefect task to load all dbt run metadata from `run_results.json` into a private S3 bucket using [Prefect's `prefect_aws` Python package](https://prefecthq.github.io/prefect-aws/s3/#prefect_aws.s3.S3Bucket.upload_from_path)
5. task to load all dbt test metadata from `run_results.json` into private S3 bucket
6. task to load all dbt project metadata from `manifest.json` into private S3 bucket

The dbt Cloud job in steps 1, 2 and 3 would have to be configured before orchestrating the project runs. Also, before the project runs begin, configure dbt Cloud to [check source freshness for all dbt Cloud jobs](https://docs.getdbt.com/docs/deploy/job-commands#checkbox-commands).

Steps 4, 5 and 6 may not be necessary since [dbt Cloud can save artifacts](https://docs.getdbt.com/docs/deploy/artifacts).

Since dbt Cloud is being used, I would set up a job notification to [send a Slack notification](https://docs.getdbt.com/docs/deploy/job-notifications#slack-notifications) for failing runs of a dbt Cloud job. Alternatively, [Prefect's `prefect-slack` Python package](https://docs.prefect.io/integrations/prefect-slack/index#write-and-run-a-flow) can be used to detect if a Prefect task that runs a dbt Cloud job has failed and to trigger a Slack notification using a webhook. To do this, a new step would have to be added to the above workflow with a Prefect task to implement this. I am not familiar with how Prefect's webhooks work so the dbt Cloud option may be better.

## Using dbt Metadata Collected from dbt Project Runs

### Models

Step 4 of the workflow is used to monitor model performance over time using the following [`dbt run` metadata in `run_results.json`](https://docs.getdbt.com/reference/artifacts/run-results-json#compile-model-results)

1. model run time (`execution_time`)
2. rows affected (from `adapter_response`)
3. model name (from `relation_name`)
4. errors (`failures`)
5. run status (`status`)

I would want to know

1. which model runs are failing
2. how long on average a successful run takes per model
3. whether runs were not triggered at their scheduled time, and what was the delay

### Tests

Step 5 of the workflow is used to monitor test performance over time per model using the following [`dbt test` metadata in `run_results.json`](https://docs.getdbt.com/reference/artifacts/run-results-json#run-generic-data-tests)

1. test run time
2. name of tested model
3. whether test failed (`failures`)
4. status (`status`)
5. test tag
   - [from `manifest.json`](https://schemas.getdbt.com/dbt/manifest/v12/index.html#nodes_additionalProperties_anyOf_i0_columns_additionalProperties) under `nodes.tags`

I would want to know

1. how many columns have not been tested per node
2. how many models have not been tested
3. which models are failing tests and how many tests failed, per tag
4. how long on average the test suite takes per model

### Project

Step 6 of the workflow is to monitor project performance over time using the following [metadata in `manifest.json`](https://schemas.getdbt.com/dbt/manifest/v12/index.html#nodes_additionalProperties_anyOf_i0_columns_additionalProperties)

1. column level
   - name (from `nodes.columns.name`)
   - description (from `nodes.columns.description`)
2. node level
   - name (from `nodes.name`)
   - description (from `nodes.description`)

I would want to know which nodes in the funnel model DAG are not documented at the

1. column level
   - name
   - description
2. model level
   - name
   - description

Documentation would make it easier for the stakeholder teams to use the data model in their reports.

## Notes

1. I have not used dbt Cloud or orchestrated a dbt workflow before so some of these steps may need to be modified. Also, I have not built the models for steps 4, 5 and 6 so I am not sure if all this metadata can be extracted from the JSON files.
