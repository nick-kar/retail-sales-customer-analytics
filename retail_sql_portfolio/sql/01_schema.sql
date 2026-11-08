-- Retail Analytics Portfolio | PostgreSQL 18
-- Run in a NEW database named retail_portfolio, not retail_analytics.
CREATE SCHEMA IF NOT EXISTS retail;
CREATE TABLE IF NOT EXISTS retail.customers (
 customer_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 first_name text NOT NULL,
 last_name text NOT NULL,
 country text NOT NULL,
 signup_date date NOT NULL
);
CREATE TABLE IF NOT EXISTS retail.products (
 product_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 product_name text NOT NULL,
 category text NOT NULL,
 list_price numeric(10,2) NOT NULL CHECK (list_price >= 0)
);
CREATE TABLE IF NOT EXISTS retail.orders (
 order_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 customer_id bigint NOT NULL REFERENCES retail.customers(customer_id),
 order_date date NOT NULL,
 order_status text NOT NULL CHECK (order_status IN ('Completed','Pending','Cancelled'))
);
CREATE TABLE IF NOT EXISTS retail.order_items (
 order_item_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 order_id bigint NOT NULL REFERENCES retail.orders(order_id),
 product_id bigint NOT NULL REFERENCES retail.products(product_id),
 quantity integer NOT NULL CHECK (quantity > 0),
 unit_price numeric(10,2) NOT NULL CHECK (unit_price >= 0)
);
