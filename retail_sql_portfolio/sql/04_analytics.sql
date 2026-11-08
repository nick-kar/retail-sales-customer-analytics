-- Monthly completed-order revenue and month-over-month growth.
WITH monthly AS (
 SELECT date_trunc('month',o.order_date)::date AS sales_month,
        COUNT(DISTINCT o.order_id) AS completed_orders,
        SUM(oi.quantity * oi.unit_price) AS revenue
 FROM retail.orders o
 JOIN retail.order_items oi ON oi.order_id=o.order_id
 WHERE o.order_status='Completed'
 GROUP BY 1
), comparison AS (
 SELECT *, LAG(revenue) OVER (ORDER BY sales_month) AS previous_revenue
 FROM monthly
)
SELECT sales_month,completed_orders,revenue,
 ROUND(100.0*(revenue-previous_revenue)/NULLIF(previous_revenue,0),2) AS mom_growth_pct
FROM comparison ORDER BY sales_month;

-- Customer order-frequency segmentation (completed orders only).
WITH customer_orders AS (
 SELECT customer_id, COUNT(*) AS completed_orders
 FROM retail.orders WHERE order_status='Completed' GROUP BY customer_id
)
SELECT COUNT(*) AS purchasing_customers,
 COUNT(*) FILTER (WHERE completed_orders>=2) AS repeat_customers,
 ROUND(100.0*COUNT(*) FILTER (WHERE completed_orders>=2)/NULLIF(COUNT(*),0),2) AS repeat_rate_pct
FROM customer_orders;

-- Top product per category, including products with zero completed sales.
WITH product_performance AS (
 SELECT p.product_id,p.product_name,p.category,
 COALESCE(SUM(oi.quantity*oi.unit_price) FILTER (WHERE o.order_status='Completed'),0) AS revenue,
 COALESCE(SUM(oi.quantity) FILTER (WHERE o.order_status='Completed'),0) AS units_sold
 FROM retail.products p
 LEFT JOIN retail.order_items oi ON oi.product_id=p.product_id
 LEFT JOIN retail.orders o ON o.order_id=oi.order_id
 GROUP BY p.product_id,p.product_name,p.category
), ranked AS (
 SELECT *, ROW_NUMBER() OVER (PARTITION BY category ORDER BY revenue DESC,product_id) AS category_position,
 SUM(revenue) OVER (PARTITION BY category) AS category_revenue
 FROM product_performance
)
SELECT category,product_id,product_name,revenue,units_sold,
 ROUND(100.0*revenue/NULLIF(category_revenue,0),2) AS category_share_pct
FROM ranked WHERE category_position=1 ORDER BY category;
