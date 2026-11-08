-- Deterministic synthetic sample for demonstration, not real customers.
-- Requires the empty tables created by 01_schema.sql.
INSERT INTO retail.customers (first_name,last_name,country,signup_date)
SELECT 'Customer', lpad(g::text,6,'0'),
 (ARRAY['Greece','Germany','France','Netherlands','USA','UK'])[1 + (g % 6)],
 DATE '2024-01-01' + (g % 365)
FROM generate_series(1,10000) AS g;

INSERT INTO retail.products (product_name,category,list_price)
SELECT 'Product ' || g,
 (ARRAY['Electronics','Sports','Home','Books','Clothing'])[1 + (g % 5)],
 (10 + ((g * 37) % 500))::numeric(10,2)
FROM generate_series(1,200) AS g;

INSERT INTO retail.orders (customer_id,order_date,order_status)
SELECT 1 + ((g * 73) % 10000),
 DATE '2025-01-01' + ((g * 17) % 365),
 CASE WHEN g % 20 = 0 THEN 'Cancelled'
      WHEN g % 10 = 0 THEN 'Pending'
      ELSE 'Completed' END
FROM generate_series(1,100000) AS g;

INSERT INTO retail.order_items (order_id,product_id,quantity,unit_price)
SELECT o.order_id,
 1 + ((o.order_id * 13 + i * 17) % 200),
 1 + ((o.order_id + i) % 3),
 p.list_price
FROM retail.orders AS o
CROSS JOIN LATERAL generate_series(1, 1 + (o.order_id % 3)::integer) AS i
JOIN retail.products AS p
 ON p.product_id = 1 + ((o.order_id * 13 + i * 17) % 200);
ANALYZE retail.customers;
ANALYZE retail.products;
ANALYZE retail.orders;
ANALYZE retail.order_items;
