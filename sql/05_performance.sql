-- Run the first EXPLAIN before creating the index, then repeat afterward.
EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id,customer_id,order_date,order_status
FROM retail.orders
WHERE order_status='Completed' AND order_date>=DATE '2025-07-01'
ORDER BY order_date;

CREATE INDEX IF NOT EXISTS idx_retail_orders_status_date
ON retail.orders (order_status,order_date);
ANALYZE retail.orders;

EXPLAIN (ANALYZE, BUFFERS)
SELECT order_id,customer_id,order_date,order_status
FROM retail.orders
WHERE order_status='Completed' AND order_date>=DATE '2025-07-01'
ORDER BY order_date;
