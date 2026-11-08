# Retail Sales & Customer Analytics | PostgreSQL 18

A reproducible, SQL-only portfolio project demonstrating relational data modeling, data validation, business analytics, window functions, and execution-plan analysis. Built for **PostgreSQL 18** and tested through **DBeaver Community 26.2.4**.

> **Synthetic dataset:** All customers, products, orders, and prices are artificial. Modular arithmetic generates strong regularities; findings demonstrate SQL techniques, not real retail trends or customer behavior.

## Dataset and schema

| Table | Rows | Purpose |
|---|---:|---|
| `retail.customers` | 10,000 | Customer identity, country, registration date |
| `retail.products` | 200 | Product catalog, category, list price |
| `retail.orders` | 100,000 | Order date, status, customer reference |
| `retail.order_items` | 200,001 | Line-item quantities and historical unit prices |

Relationships: `customers` 1-to-many `orders`; `orders` 1-to-many `order_items`; `products` 1-to-many `order_items`. Primary keys, foreign keys, `NOT NULL`, and `CHECK` constraints enforce basic integrity.

## Reproduce

1. Create an **empty** PostgreSQL database named `retail_portfolio` and connect to it in DBeaver. Do not run these scripts in the separate practice database `retail_analytics`.
2. Execute `sql/01_schema.sql` (creates the `retail` schema and four tables).
3. Execute `sql/02_seed.sql` **once** on empty tables. This inserts deterministic synthetic data; running it twice is not supported.
4. Execute `sql/03_quality_checks.sql` and inspect the three orphan-record checks (expected: zero). The schema also rejects nonpositive quantities and negative prices.
5. Execute `sql/04_analytics.sql` to reproduce monthly sales, repeat-purchase summary, and category-leading products.
6. For the index experiment, open `sql/05_performance.sql`: execute its **first EXPLAIN** before creating the index, then execute `CREATE INDEX` and `ANALYZE`, then the **final EXPLAIN**. Do not run the whole script at once if you want a before/after comparison. Performance varies by machine and cache state.

The seed script assumes newly created identity sequences beginning at 1. The project requires no external datasets, API keys, or personal data.

## Findings (verified from query output)

- **2025 completed-order revenue:** €94,889,714 across 90,000 completed orders.
- **Highest monthly revenue:** October (€8,093,793); **lowest:** February (€7,360,329).
- **Purchasing customers:** 9,000; **repeat customers:** 9,000, or 100% of purchasers. This unrealistically perfect rate is caused by the synthetic generator; it is **not cohort retention**.
- **Top Home product:** Product 27, revenue €1,017,491, representing 5.40% of category revenue.
- **Index experiment:** after creating `(order_status, order_date)`, PostgreSQL switched from sequential scan + sort to index scan. Five indexed executions had a median of **20.298 ms**, compared with **24.128 ms** for a single pre-index run. This is a descriptive observation, **not** a proven performance gain.

See `results/business_insights.md` for interpretation and `results/*.csv` for observed outputs.

## SQL techniques

- `CREATE TABLE`, primary and foreign keys, `CHECK` constraints
- Synthetic data generation with `generate_series`, arrays, `CROSS JOIN LATERAL`
- `JOIN`, `GROUP BY`, `FILTER`, `COUNT(DISTINCT ...)`, CTEs
- `DATE_TRUNC`, `LAG`, `ROW_NUMBER`, windowed category totals
- `EXPLAIN (ANALYZE, BUFFERS)`, composite B-tree indexes, `ANALYZE`

## Repository layout

```text
retail_sql_portfolio/
├── README.md
├── sql/
│   ├── 01_schema.sql
│   ├── 02_seed.sql
│   ├── 03_quality_checks.sql
│   ├── 04_analytics.sql
│   └── 05_performance.sql
├── results/
│   ├── business_insights.md
│   ├── monthly_sales.csv
│   ├── customer_repeat.csv
│   ├── top_products.csv
│   └── index_benchmark.csv
└── docs/
```

## Limitations and future work

The dataset is intentionally simple and strongly patterned, so apparent seasonality, customer repeat behavior, and product rankings are artifacts of the generator. Revenue is not profit; there are no costs, returns, discounts, or refunds. A more rigorous optimization study would collect repeated **pre-index and post-index** timings with comparable cache conditions. Potential extensions include more realistic synthetic distributions, cohort retention, and an ER diagram.
