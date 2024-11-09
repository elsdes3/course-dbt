# Week 4 Answers

## Part 1

### Background

Let’s say that the Director of Product at greenery comes to us (the head Analytics Engineer) and asks some questions:

1. How are our users moving through the product funnel?
2. Which steps in the funnel have largest drop off points?

Product funnel is defined with 3 levels for our dataset:

1. Sessions with any event of type `page_view`
2. Sessions with any event of type `add_to_cart`
3. Sessions with any event of type `checkout`

They need to understand how the product funnel is performing to set the roadmap for the next quarter. The Product and Engineering teams are asking what their projects will be, and they want to make data-informed decisions.

Thankfully, we can help using our data, and modeling it with dbt!

In addition to answering these questions right now, we want to be able to answer them at any time. The Product and Engineering teams will want to track how they are improving these metrics on an ongoing basis. As such, we need to think about how we can model the data in a way that allows us to set up reporting for the long-term tracking of our goals.

Please create any additional dbt models needed to help answer these questions from our product team, and put your answers in a README in your repo.

### Question 1

**How are our users moving through the product funnel?**

1. For all available sessions between 2021-02-09 and 2029-02-12, there were
   - 578 sessions with a product page view
   - 467 sessions with at least one product being added to a shopping cart
   - 361 purchases
2. The [bounce rate](https://amplitude.com/blog/bounce-rate-calculate-and-average#what-is-bounce-rate) is ~18%. This compares favorably to the [industry standard](https://amplitude.com/blog/bounce-rate-calculate-and-average#what-is-a-good-average-bounce-rate) for e-commerce (20%-45%).
3. The [add-to-cart rate](https://blendcommerce.com/blogs/shopify/add-to-cart-rate) is ~81%. This compares to the [industry standard](https://dashthis.com/kpi-examples/add-to-cart-rate/) of 10%-20%, which [suggests](https://blendcommerce.com/blogs/shopify/add-to-cart-rate) strong appeal for Greenery's products, high usability of the Greenery website and positive impact of Greenery's marketing efforts.
4. The [cart abandonment rate](https://www.geckoboard.com/best-practice/kpi-examples/shopping-cart-abandonment-rate/) is ~23%, which is well below the industry average of ~70%-75%, which suggests execllent usability at driving sales revenue for the Greenery website.
5. The [add-to-cart abandonment rate](https://www.tidio.com/blog/add-to-cart-conversion-rate-statistics/) is ~77%. This is also well above the industry standard which is ~10%. This suggests favorable website design, product choice and customer service for the Greenery platform.
6. The [conversion rate (using sessions)](https://www.shopify.com/ca/blog/ecommerce-conversion-rate#2) is ~62%. This is nearly 20X the industry standard ([1](https://www.toptal.com/external-blogs/growth-collective/ecommerce-conversion-rates), [2](https://www.toptal.com/external-blogs/growth-collective/ecommerce-conversion-rates)) which is ~3%. From 2., ~81% of sessions end in at least one Greenery product being added to a shopping cart. Relative to this, it is encouraging that ~62% of sessions end in a conversion.

In conclusion, the Greenery platform is matching or beating the industry standard in all of the above five metrics. This suggests that, overall, **customers are moving through the product funnel with a high degree of efficiency**.

### Question 2

**Which steps in the funnel have largest drop off points?**

The funnel step with the largest dropoff is *checkout*s (relative to add-to-carts) at ~23%, which is slightly higher than the dropoff in add-to-carts (relative to page views), which is ~19%. This small difference suggests there is [probably no issue between](https://segment.com/blog/building-ultimate-funnel-sql/) adding Greenery products to a shopping cart and checking out the cart.

## Part 2

### Background

We'll also want to make sure that any model feeding into this report is defined in an exposure (which we’ll cover in this week’s materials).

### Question 1

**Use an exposure on your product analytics model to represent that this is being used in downstream BI tools. Please reference the course content if you have questions.**

I created the following exposure definition file in `models/marts/marketing/exposures/schema.yml`

```bash
version: 2

exposures:  
  - name: product_funnel_dashboard
    label: Product funnel visualization using BI tool
    type: dashboard
    maturity: medium
    description: >
        Models to retrieve product analytics by visualizing funnel performance
        at multiple granularities through BI tool

    depends_on:
      - ref('fct_products_funnel')

    owner:
      name: E D
      email: xxxx@gmail.com

    tags: ['bi-dashboard', 'product-funnel']
```

The `label`, `description` and `tags` properties indicate that these models are being used in a downstream BI tool to visualize the product funnel.
