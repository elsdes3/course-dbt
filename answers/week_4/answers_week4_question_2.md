# Week 4 Answers (Part 2)

Sections 1 and 2 answer questions 1 and 2 respectively. The third section discusses the question about the visualization.

## Section 1

### Background

**Let's say that the Director of Product at greenery comes to us (the head Analytics Engineer) and asks some questions:**

1. **How are our users moving through the product funnel?**
2. **Which steps in the funnel have largest drop off points?**

**Product funnel is defined with 3 levels for our dataset:**

1. **Sessions with any event of type `page_view`**
2. **Sessions with any event of type `add_to_cart`**
3. **Sessions with any event of type `checkout`**

**They need to understand how the product funnel is performing to set the roadmap for the next quarter. The Product and Engineering teams are asking what their projects will be, and they want to make data-informed decisions.**

**Thankfully, we can help using our data, and modeling it with dbt!**

**In addition to answering these questions right now, we want to be able to answer them at any time. The Product and Engineering teams will want to track how they are improving these metrics on an ongoing basis. As such, we need to think about how we can model the data in a way that allows us to set up reporting for the long-term tracking of our goals.**

**Please create any additional dbt models needed to help answer these questions from our product team, and put your answers in a README in your repo.**

### Question about Models

**Please create any additional dbt models needed to help answer these questions from our product team, and put your answers in a README in your repo.**

In order to build a funnel model that supports creation of (a) reports and (b) metrics, I created a `marts/products` funnel model.

This model will be used by the Product and Engineering. I considered both teams to be the business users. Since more than one business unit would be using this model, I initially created this as a `facts` model in `marts/core`. However, since the model would be getting exposed to business users on a dashboard, I changed this into a business mart. Instead of leaving this `facts` model in `marts/core`, I instead placed this model in `marts/products` since two product-related teams would be the end users.

#### Intermediate Models Created

An `intermediate` model was created in `intermediate/products/daily/int_sessions_aggregated_to_product_daily` to get a daily aggregation of events (page views, add-to-carts and checkouts) for each product per session. The `product_id` was used to identify each product. The `user_id` and `session_id` were used to identify each session. A column at the session level (`is_bounce_session`) was also added to indicate if the session resulted in a bounce (single product page-view in the entire session). These four columns (page views, add-to-carts and checkouts, `is_bounce_session`) summarized each session and could be used to calculate and monitor metrics.

The first three columns (page views, add-to-carts and checkouts) summarized each product in each session and could be used to calculate the following metrics

1. add-to-cart rate
2. add-to-cart conversion rate
3. cart abandonment rate
4. conversion rate

The fourth column (`is_bounce_session`) could be used to calculate a fifth metric ([bounce rate](https://chartio.com/learn/marketing-analytics/how-to-track-bounce-rate-among-google-analytics-visitors/#what-is-bounce-rate)).

The aggregation of events per session was performed daily so a date column (`created_at_date`) was also included in this intermediate data model. This column could be used to filter sessions by date in order to track the impact of promotions, platform upgrades, etc. on the

1. five metrics
2. three raw counts (page views, add-to-carts and checkouts)

over time at a product (using `product_id`) or user (using `user_id`) granularity over time.

In this way, a single model supports creation of (a) reports and (b) metrics on an ongoing basis.

#### Marts Models Created

A `marts/products` model was created that joined the `intermediate` model with `staging` models to convert

1. `product_id` into product name
2. `user_id` into state name

to add human-readable insights to reports and metrics. Instead of shown `product_id` the product name could be used. Similarly, the state name could be used instead of `user_id`.

### Question 1

**How are our users moving through the product funnel?**

1. For all available sessions between 2021-02-09 and 2029-02-12, there were
   - 578 sessions with a product page view
   - 467 sessions with at least one product being added to a shopping cart
   - 361 purchases
2. The [bounce rate](https://amplitude.com/blog/bounce-rate-calculate-and-average#what-is-bounce-rate) is 0%. The [industry standard](https://amplitude.com/blog/bounce-rate-calculate-and-average#what-is-a-good-average-bounce-rate) for e-commerce (20%-45%).
3. The [add-to-cart rate](https://blendcommerce.com/blogs/shopify/add-to-cart-rate) is ~81%. This compares to the [industry standard](https://dashthis.com/kpi-examples/add-to-cart-rate/) of 10%-20%, which [suggests](https://blendcommerce.com/blogs/shopify/add-to-cart-rate) strong appeal for Greenery's products, high usability of the Greenery website and positive impact of Greenery's marketing efforts.
4. The [cart abandonment rate](https://www.geckoboard.com/best-practice/kpi-examples/shopping-cart-abandonment-rate/) is ~23%, which is well below the industry average of ~70%-75%, which suggests execllent usability at driving sales revenue for the Greenery website.
5. The [add-to-cart conversion rate](https://www.tidio.com/blog/add-to-cart-conversion-rate-statistics/) is ~77%. This is also well above the industry standard which is ~10%. This suggests favorable website design, product choice and customer service for the Greenery platform.
6. The [conversion rate (using sessions)](https://www.shopify.com/ca/blog/ecommerce-conversion-rate#2) is ~62%. This is nearly 20X the industry standard ([1](https://www.toptal.com/external-blogs/growth-collective/ecommerce-conversion-rates), [2](https://www.toptal.com/external-blogs/growth-collective/ecommerce-conversion-rates)) which is ~3%. From 3., ~81% of sessions end in at least one Greenery product being added to a shopping cart. Relative to this, it is encouraging that ~62% of sessions end in a conversion.

In conclusion, the Greenery platform is matching or beating the industry standard in all of the above five metrics. This suggests that, overall, **customers are moving through the product funnel with a high degree of efficiency**.

### Question 2

**Which steps in the funnel have largest drop off points?**

The funnel step with the largest dropoff is *checkout*s (relative to add-to-carts) at ~23%, which is slightly higher than the dropoff in add-to-carts (relative to page views), which is ~19%. This small difference suggests there is [probably no issue between](https://segment.com/blog/building-ultimate-funnel-sql/) adding Greenery products to a shopping cart and checking out the cart.

## Section 2

### Background

**We'll also want to make sure that any model feeding into this report is defined in an exposure (which we'll cover in this week's materials).**

### Question

**Use an exposure on your product analytics model to represent that this is being used in downstream BI tools. Please reference the course content if you have questions.**

I created the following exposure definition file in a separate `exposures` sub-directory within `marts`, in `models/marts/exposures/schema.yml`

```bash
version: 2

exposures:
  - name: product_funnel_dashboard
    label: Product funnel visualization using BI tool
    type: dashboard
    maturity: medium
    description: >
        Models to facilitate product analytics by using BI tool to visualize
        daily funnel performance at user and product granularities through BI
        tool

    depends_on:
      - ref('fct_sessions_daily')

    owner:
      name: E D
      email: xxxx@gmail.com

    tags: ['bi-dashboard', 'product-funnel']
```

The `label`, `description` and `tags` properties indicate that these models are being used in a downstream BI tool to visualize the product funnel.

The `dbt` documentation showing the exposure, model developed and DAG is shown [here](https://github.com/elsdes3/course-dbt/blob/main/answers/week_4/week4_answer_part2_dbt_exposure.pdf). See pages 2 and 3 for the model and pages 4 and 5 for the DAG.

## (Optional) Section about Visualization

**With our funnel data model complete, let's create a sigma workbook to visualize all of our data for our CPO and CEO.**

I created a [dashboard using Sigma to visualize Greenery product performance](https://github.com/elsdes3/course-dbt/blob/main/answers/week_4/visualization/00-dashboard.png) using the `marts/products` funnel data model created above. The three counts columns (page views, add-to-carts and chckouts), five metrics and date column were used on the dashboard to allow both teams to quantitatively track product-oriented goals over time.

### Row 1

The [first row](https://github.com/elsdes3/course-dbt/blob/main/answers/week_4/visualization/01-metrics_overall.png) shows the five metrics and three counts using [Sigma's KPI value chart configuration](https://help.sigmacomputing.com/docs/build-a-kpi-chart#basic-kpi-chart-configurations). A fourth count (users who purchased one or more products) was also shown.

This row was shown in chronological order of user activity within a session

1. user views product page
   - (product) page views
     - this is the first count
2. user leaves after viewing single (product) page, which is a bounce event
   - bounce rate
     - this is the first metric
3. user adds product(s) to cart
   - add-to-carts
     - this is the second count
   - add-to-cart rate
     - this is the second metric
4. user leaves (session ends) without checking out the cart
   - cart abandonment rate
     - this is the third metric
5. user makes purchase
   - checkouts
     - this is the third count
   - add-to-cart conversion rate
     - user leaves (session ends) after checking out the cart
     - this is the fourth metric
   - conversion rate
     - this is the fifth metric

The last (fourth) count which is shown using a KPI value chart is the number of users who made a purchase on the platform. All KPI value charts use [Sigma's tooltip](https://help.sigmacomputing.com/docs/build-a-kpi-chart#customize-the-trend-line) to give the reader a longer description of the metric or count that is being visualized.

This row uses all available aggregated sessions data from the funnel model I developed above.

### Row 2

The left column of the [second row](https://github.com/elsdes3/course-dbt/blob/main/answers/week_4/visualization/02-overall_checkouts_by_state_product_and_cart_performance_by_product.png) also uses all available aggregated sessions data to show the total number of checkouts broken down by product or state. A [drill down control element](https://help.sigmacomputing.com/docs/drill-down-control) is used to choose between product or state. A date range filter is also used to capture sessions within a specific range of dates and it uses the `created_at_date` column as discussed earlier. In this way, the funnel model supports visualization of metrics on an ongoing basis. With more data, a line chart could be created to track KPIs and counts over datetime attributes (day, week, month, quarter). A line chart was not included on the dashboard.

The right column of the second row focuses on shopping cart performance using bar charts for the two cart-related metrics: cart abandonment and add-to-cart conversion rate, by product. The top *N* products are shown on the chart. *N* can be changed using a [*Top N* filter](https://help.sigmacomputing.com/docs/top-n-filter). Both metrics are calculated and displayed as a KPI value chart (similar to the first row) for the selected number of products. As before, both of these KPI value charts have a tooltip to indicate that only the selected *Top N* products are used to calculate the metric being visualized here.

### Row 3

The left column of the [third row](https://github.com/elsdes3/course-dbt/blob/main/answers/week_4/visualization/03-conversions_by_product_and_product_funnel.png) focuses on product performance. The two metrics to choose from are the add-to-cart conversion rate and the conversion rate. After exploring the add-to-cart conversion rate, I did not find much variation by product so I excluded this metric from the dashboard. Instead, the conversion rate is shown on its own. Another *Top N* filter is used to display the top *N* performing products only.

The right column of the third row uses [Sigma's funnel chart](https://help.sigmacomputing.com/docs/build-a-funnel-chart) to show the product funnel for the Greenery platform. All available aggregated sessions data from the funnel model is shown on this chart.
