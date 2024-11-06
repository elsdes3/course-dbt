# Week 3 Answers (Part 5)

## Background

After improving our project with all the things that we have learned about dbt, we want to show off our work!

## Question

**Show (using dbt docs and the model DAGs) how you have simplified or improved a DAG using macros and/or dbt packages.**

A `.pdf` file [here](https://github.com/elsdes3/course-dbt/blob/main/answers/week_3/answer_5_dbt_docs_macros_tests.pdf) is used to show screenshots from the DBT documentation in order to answer this question. Screenshots show

1. SQL and `jinja` for multiple macros and models
2. the DAG for two data models
3. Importance of tests to flag an inaccurate column in a `facts` model in `marts/core`

For evidence of how macros (built-in and from `dbt` packages) have improved an `intermediate` or `marts` model DAG see pages 12 to 22. One macro was used to completely render two separate DAGs. A walkthrough of this macro is shown on pages 19 and 20 and the DAGs are shown on page 21.

For evidence of how custom tests and tests from dbt packages have

1. improved the **quality** of model data returned by `intermediate` and `marts` model DAGs see pages 25 to 34 (excluding page 31)
2. improved the **accuracy** of model data returned by a `marts/core` model, see pages 35 to 43
