# Week 4 Answers (Part 1)

## Background

Let's update our products snapshot one last time to see how our data is changing:

## Notes

My projects 1, 2 and 3 were submitted one week late. I did not take this one-week offset into account for projects 2 and 3. My snapshots and corresponding answer for weeks 1, 2 and 3 should have been for weeks 2, 3 and 4 instead. My answers to the week 2 and week 3 project snapshot analysis questions are incorrect. I tried to take this offset into account this week (week 4).

## Questions

### Question 1

**Run the products snapshot model using `dbt snapshot` and query it in snowflake to see how the data has changed since last week.**

I ran the snapshot by running

```bash
dbt snapshot
```

### Question 2

**Which products had their inventory change from week 3 to week 4?**

The following six products had their inventory change from week 3 to week 4

1. `fb0e8be7-5ac4-4a76-a1fa-2cc4bf0b2d80` (String of pearls)
   - inventory increased by 10
2. `b66a7143-c18a-43bb-b5dc-06bb5d1d3160` (ZZ Plant)
   - inventory decreased by 12
3. `689fb64e-a4a2-45c5-b9f2-480c2155624d` (Bamboo)
   - inventory decreased by 21
4. `55c6a062-5f4a-4a8b-a8e5-05ea5e6715a3` (Philodendron)
   - inventory increased by 15
5. `4cda01b9-62e2-46c5-830f-b7f262a58fb1` (Pothos)
   - inventory increased by 20
6. `be49171b-9f72-4fc9-bf7a-9a52e259836b` (Monstera)
   - inventory decreased by 19

The product ID is shown, with the product name in parentheses.

### Question 3 (Part 1)

#### Background

**Now that we have 3 weeks of snapshot data, can you use the inventory changes to determine which products had the most fluctuations in inventory?**

**Over the last three weeks**, the following six products had three changes in inventory

1. ZZ Plant
2. Pothos
3. Monstera
4. Bamboo
5. Philodendron
6. String of pearls

**Over the last three weeks**, the following were the overall changes in inventory

1. ZZ Plant (changed by 48: 89 to 53 = 36 and 53 to 41 = 12, 36+12 = 48)
2. Pothos (changed by 40)
3. Monstera (changed by 33)
4. Bamboo (changed by 33)
5. Philodendron (changed by 25)
6. String of pearls (changed by 20)

#### Answer

**Over the last three weeks**, ZZ Plant (`product_id` = *b66a7143-c18a-43bb-b5dc-06bb5d1d3160*) was the product that had the most fluctuation in inventory.

Since I was late in submitting all my assignments, I don't have a snapshot for week 1. My earliest snapshot starts in week 2. So, I can only answer this question using inventory levels (captured in the snapshots) from weeks 2, 3 and 4. For this reason, I had to indicate **Over the last three weeks** at the start of my answer.

### Question 3 (Part 2)

**Did we have any items go out of stock in the last 3 weeks?**

Yes, we did have items that went out of stock in the last 3 weeks. The following are the products that went out of stock over weeks 2, 3 and 4

1. String of pearls
   - went out of stock in week 3
   - inventory dropped from 10 (in week 2) to 0 in week 3
2. Pothos
   - went out of stock in week 3
   - inventory dropped from 20 (in week 2) to 0 in week 3
