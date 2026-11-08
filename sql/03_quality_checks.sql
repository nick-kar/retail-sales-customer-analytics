-- Basic integrity and completeness checks; expected orphan counts: zero.
SELECT 'orders_without_customers' AS check_name, COUNT(*) AS issue_count
FROM retail.orders o LEFT JOIN retail.customers c ON c.customer_id=o.customer_id
WHERE c.customer_id IS NULL
UNION ALL
SELECT 'items_without_orders', COUNT(*)
FROM retail.order_items oi LEFT JOIN retail.orders o ON o.order_id=oi.order_id
WHERE o.order_id IS NULL
UNION ALL
SELECT 'items_without_products', COUNT(*)
FROM retail.order_items oi LEFT JOIN retail.products p ON p.product_id=oi.product_id
WHERE p.product_id IS NULL;
