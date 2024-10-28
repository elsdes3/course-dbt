# Week 2 Answers (Part 1)

## Background

For the final week of our project, we'll...be answering questions like: 

1. How are our users moving through the product funnel?
2. Which steps in the funnel have largest drop off points?

## Questions

### Question 1

**What is our user repeat rate? Repeat Rate = Users who purchased 2 or more times / users who purchased**

From the `stg_postgres_orders` model, the repeat purchaser rate is 79.84% (rounded to 80%)

### Question 2

**What are good indicators of a user who will likely purchase again? What about indicators of users who are likely NOT to purchase again? If you had more data, what features would you want to look into to answer this question? NOTE: This is a hypothetical question vs. something we can analyze in our Greenery data set. Think about what exploratory analysis you would do to approach this question.**

#### Indicators of Users Who are Likely to Purchase Again

1. User has purchased frequently in trailing 3, 6, 12 months
2. Wheter user leaves/writes positive product reviews or leaves positive ratings (if applicable)
   - if product ratings can be left on the Greenery store site then users who have prevoiusly purchased and who write and/or react positively to (eg. like, thumbs up, etc.) those ratings are more likely to purchase again
3. Whether users are subscribers
   - similar to [Amazon's *Subscribe & Save Subscription*](https://www.amazon.ca/gp/help/customer/display.html?nodeId=GJ2LTMLFGGMH67M7)
4. Whether users frequently participate in promotions

#### Indicators of Users Who are Not Likely to Purchase Again

1. User metrics for behaviour on site are poor
   - bounce rate is high
   - time on site is low
   - views few product pages
   - high cart abandonment rate
2. Wheter user leaves/writes negative user reviews or leaves negative ratings (if applicable)
   - if product ratings can be left on the Greenery store site then users who have prevoiusly purchased but who write and/or react negatively to (eg. thumbs down, etc.) those ratings are less likely to purchase again
3. Poor experience with Greenery platform
   - frequent and long delays in receiving their orders
   - high product return rate
4. Whether users infrequently participate in promotions

#### Features to Look into with More Data

1. Past purchasing frequency (number of orders) of user
2. Whether user is subscriber
3. Past partitipation in promotions

### Question 3

Explain the product mart models you added.

#### Answer

I created the below `marts` marketing models
1. `marts/marketing/fct_user_orders`
   - this model summarizes order details aggregated by user. It can be used by the marketing team to **understand user overall buying behavior at the order level**. This includes the average size of each order, which is the average number of products purchased across all orders placed by each user. I also included user-level stats for the total number of orders delivered and currently being shipped to the user. Both total number of orders and total order value (which I also included) can be used to identify our biggest customers for more focused analysis. Since the data currently only contains a few days of orders data, I did not calculate time-dependent metrics at the user level. With more days of orders data, time-dependent metrics could be used to explore trends among the biggest versus all other customers. These trends could be used to inform future targeted initiatives by the marketing team to grow sales revenue.
2. `marts/marketing/fct_promo_orders`
   - this model summarizes order details aggregated by promotion. It can also be used by the marketing team to quantify and compare the impact of promotional campaigns in order to **determine which promotions generated the highest sales revenue from orders placed on the platform**. The number of orders placed, order cost and average order size per promotion are three metrics that could be used to measure and compare the impact of promotions run by the marketing team.
3. `marts/core/fct_orders`
   - this model summarizes aggregated order performance. It can be used to **understand attributes of [order turnaround](https://www.energy-robotics.com/post/turnaround-time-a-comprehensive-guide)** placed on the platform. Order size and order cost are two of the per-order attributes calculated to help with this. Order turnaround time can be used to explore the relationship between these two attributes and the delivery delay time per order. The impact of promotions on order delivery delays can also be explored. The name of the state in which the order will be delivered to (geospatial) and timestamp at which the order was placed (temporal) are also included in order to understand these relationships at a more granular level. The primary business user for this is the operations team that is responsible for facilitating efficient order turnaround. However, since this model is granular and contains a combination of multiple `intermediate` models, other teams can also use this model.
4. `marts/products/daily/fct_products_daily`
   - this model calculates the following e-commerce metrics daily per product in order to help the product team understand how different products perform on a daily basis and track their performance over time
     - (required) daily page views
       - column name
         - `num_page_views`
     - (required) daiy orders
       - column name
         - `num_orders`
5. `marts/products/overall/fct_products`
   - this model calculates the following e-commerce metrics overall per product in order to help the product team understand how different products perform
     - (required) high-traffic (traffic = page views) and low-conversion products
       - the following columns were created per product and then ranked across all products
         - `num_purchases` (number of purchases)
         - `num_page_views` (number of page views, or traffic)
       - products with high traffic were identified as
         - rank in top 10 in number of page views
         - column name
           - `is_high_traffic`
       - products with low conversions were identified as
         - rank in bottom 10 in number of conversions (purchases)
         - column name
           - `is_low_conversions`
       - these two boolen columns can be used to identify products getting high traffic but low conversions
     - (optional) number of sessions in which a product page was viewed
       - this column can be alternatively used to represent traffic, in place of page views
       - column name
         - `num_page_view_sessions`
     - (optional) [cart abandonment rate](https://www.geckoboard.com/best-practice/kpi-examples/shopping-cart-abandonment-rate/)
       - ratio: number of purchases / number of carts created
       - column name
         - `cart_abandonment_rate`
         - columns used
         - `num_purchases` / `num_carts`
         - `num_purchases`
           - number of purchases per product
         - `num_carts`
           - number of times a product was added to a cart
     - (optional) [average time spent viewing a product page](https://www.klipfolio.com/resources/kpi-examples/digital-marketing/average-time-on-page)
       - take average of time spent on each `page_view` session, per product

### Question 4

Why did you organize the models in the way you did?

#### Answer

I organized models into

1. `staging`
   - these models were previously developed and I did not change them
2. `intermediate`
   - I created separate sub-folders for models for
     - products
     - orders
   
   Since I created `intermediate` models at different levels (orders and products) I chose to create an `intermediate` folder at the root of the `models` directory. This resulted in two sub-folders (`intermediate/orders` and `intermediate/products`) within the parent `intermediate` folder.
   
   I did not create a separate nested `intermediate` sub-folder within each `marts` folder for two reasons
   - I would need three such folders, one for each `marts` model
   - the `intermediate/orders` models are used by both the `core` and `marketing` business units. Creating a separate`intermediate` folder that is not nested within `marts` avoided repeating SQL code in those `intermediate` models.
3. `marts`
   - I organized `marts` models into separate sub-folders for each intended business user
     - marketing team (`marketing` folder)
     - multiple teams (`core` folder)
       - primarily the operations team
     - product team (`product` folder)
       - since metrics were calculated at two levels (overall and per day) I created two sub-folders within the `product` folder

### Question 5

**Use the dbt docs to visualize your model DAGs to ensure the model layers make sense. Paste in an image of your DAG from the docs. These commands will help you see the full DAG**
```bash
$ dbt docs generate 
$ dbt docs serve --no-browser
```

**You'll find in the lower right corner a symbol to click on to see the DAG.**

### Answer

An image of the DAG is shown in a `.pdf` file named `dbt_DAG.pdf` [here](https://github.com/elsdes3/course-dbt/blob/main/greenery/answers_week_2/dbt_DAG.pdf). Unfortunately, the text is too small to read.
