# Week 4 Answers (Part 3A)

## Question 1

**Reflecting on your learning in this class, if your organization is thinking about using dbt, how would you pitch the value of dbt/analytics engineering to a decision maker at your organization?**

N/A

## Question 2

**Reflecting on your learning in this class, if your organization is using dbt, what are 1-2 things you might do differently / recommend to your organization based on learning from this course?**

I would first recommend discussing rationale for the project's directory structure that we are currently using and ask whether this can be refactored to be more in line with dbt's recommended project structure (see "Staging: Preparing our atomic building blocks", "Marts: Business-defined entities" and "How we structure our dbt projects" from dbt's docs). By refactoring iteratively, we minimize the chance of making breaking changes. Uplimit's weekly notes and these dbt best practices helped me to settle on a directory structure during week 2. I had to go through a few iterations for in personal Greenery project folder before I settled on one that followed the best practices as closely as I could. This paid off since it helped me to add and refactor new models and add macros during later weeks. I would suggest iterative refactoring for our organization's highest priority projects.

Second, I would emphasize the importance of creating maintainable dbt documentation. One example I came across at the end of week 3 (from the dbt docs) was dbt docs blocks. This helped me remove a lot of repetition in my documentation, and I found this very helpful. I would strongly recommend that all our dbt projects contain documentation (columns, macros, models, exposures, etc.) and that we leverage docs blocks whenever possible. I would advocate for monthly docs sprints to get this in place as soon as possible.

These two changes would help our team to onboard new members faster and get projects started more efficiently.

## Question 3

**Reflecting on your learning in this class, if you are thinking about moving to analytics engineering, what skills have you picked that give you the most confidence in pursuing this next step?**

I got to see dbt in action. My previous (brief) exposure to analytics involved modifying SQL files without experience with the data modeling workflow. This course exposed me to a lot about this field. The main skills I picked up are (a) creating multiple layers of data models aimed at addressing business objectives, (b) development of a data test suite and comprehensive documentation to ensure data quality, (c) structuring a dbt project for maintainable model development, (d) monitoring data changes using dbt snapshots, (e) improving model efficiency/complexity using dbt macros and packages. Through peer reviews, I got practical experiene with understanding the structure of dbt projects that I had not created myself.
