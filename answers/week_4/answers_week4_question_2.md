# Week 4 Answers

## Part 1

...

## Part 2

### Background

We'll also want to make sure that any model feeding into this report is defined in an exposure (which we’ll cover in this week’s materials).

### Question 2

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
