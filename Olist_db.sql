-- 1. Customers Dataset
DROP TABLE IF EXISTS olist_customers_dataset CASCADE;
CREATE TABLE olist_customers_dataset (
    customer_id TEXT PRIMARY KEY,
    customer_unique_id TEXT,
    customer_zip_code_prefix TEXT,
    customer_city TEXT,
    customer_state TEXT
);

-- 2. Geolocation Dataset (No Primary Key as zip codes repeat)
DROP TABLE IF EXISTS olist_geolocation_dataset CASCADE;
CREATE TABLE olist_geolocation_dataset (
    geolocation_zip_code_prefix TEXT,
    geolocation_lat NUMERIC,
    geolocation_lng NUMERIC,
    geolocation_city TEXT,
    geolocation_state TEXT
);

-- 3. Products Dataset
DROP TABLE IF EXISTS olist_products_dataset CASCADE;
CREATE TABLE olist_products_dataset (
    product_id TEXT PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- 4. Sellers Dataset
DROP TABLE IF EXISTS olist_sellers_dataset CASCADE;
CREATE TABLE olist_sellers_dataset (
    seller_id TEXT PRIMARY KEY,
    seller_zip_code_prefix TEXT,
    seller_city TEXT,
    seller_state TEXT
);

-- 5. Orders Dataset
DROP TABLE IF EXISTS olist_orders_dataset CASCADE;
CREATE TABLE olist_orders_dataset (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT,
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 6. Order Items Dataset
DROP TABLE IF EXISTS olist_order_items_dataset CASCADE;
CREATE TABLE olist_order_items_dataset (
    order_id TEXT,
    order_item_id INTEGER,
    product_id TEXT,
    seller_id TEXT,
    shipping_limit_date TIMESTAMP,
    price NUMERIC,
    freight_value NUMERIC
);

-- 7. Order Payments Dataset
DROP TABLE IF EXISTS olist_order_payments_dataset CASCADE;
CREATE TABLE olist_order_payments_dataset (
    order_id TEXT,
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC
);

-- 8. Order Reviews Dataset
DROP TABLE IF EXISTS olist_order_reviews_dataset CASCADE;
CREATE TABLE olist_order_reviews_dataset (
    review_id TEXT,
    order_id TEXT,
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- 9. Product Category Name Translation
DROP TABLE IF EXISTS product_category_name_translation CASCADE;
CREATE TABLE product_category_name_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);


COPY olist_customers_dataset FROM 'D:/Downloads/olist_customers_dataset.csv' DELIMITER ',' CSV HEADER;

COPY olist_geolocation_dataset FROM 'D:\Downloads\olist_geolocation_dataset.csv' DELIMITER ',' CSV HEADER;

COPY olist_products_dataset FROM 'D:\Downloads\olist_products_dataset.csv' DELIMITER ',' CSV HEADER;

COPY olist_sellers_dataset FROM 'D:\Downloads\olist_sellers_dataset.csv' DELIMITER ',' CSV HEADER;

COPY olist_orders_dataset FROM 'D:\Downloads\olist_orders_dataset.csv' DELIMITER ',' CSV HEADER;

COPY olist_order_items_dataset FROM 'D:/Downloads/olist_order_items_dataset.csv' DELIMITER ',' CSV HEADER;

COPY olist_order_payments_dataset FROM 'D:\Downloads\olist_order_payments_dataset.csv' DELIMITER ',' CSV HEADER;

COPY olist_order_reviews_dataset FROM 'D:\Downloads\olist_order_reviews_dataset.csv' DELIMITER ',' CSV HEADER;

COPY product_category_name_translation FROM 'D:\Downloads\product_category_name_translation.csv' DELIMITER ',' CSV HEADER;


SELECT * FROM olist_geolocation_dataset;


-- Link Orders to Customers
ALTER TABLE olist_orders_dataset
ADD CONSTRAINT fk_orders_customers
FOREIGN KEY (customer_id) REFERENCES olist_customers_dataset(customer_id);

-- Link Order Items to Orders, Products, and Sellers
ALTER TABLE olist_order_items_dataset
ADD CONSTRAINT fk_items_orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id),
ADD CONSTRAINT fk_items_products
FOREIGN KEY (product_id) REFERENCES olist_products_dataset(product_id),
ADD CONSTRAINT fk_items_sellers
FOREIGN KEY (seller_id) REFERENCES olist_sellers_dataset(seller_id);

-- Link Order Payments to Orders
ALTER TABLE olist_order_payments_dataset
ADD CONSTRAINT fk_payments_orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);

-- Link Order Reviews to Orders
ALTER TABLE olist_order_reviews_dataset
ADD CONSTRAINT fk_reviews_orders
FOREIGN KEY (order_id) REFERENCES olist_orders_dataset(order_id);


-- Orders
CREATE INDEX IF NOT EXISTS ix_orders_order_id ON olist_orders_dataset(order_id);
CREATE INDEX IF NOT EXISTS ix_orders_customer_id ON olist_orders_dataset(customer_id);
CREATE INDEX IF NOT EXISTS ix_orders_purchase_date ON olist_orders_dataset(order_purchase_timestamp);

-- Order Items
CREATE INDEX IF NOT EXISTS ix_items_order_id ON olist_order_items_dataset(order_id);
CREATE INDEX IF NOT EXISTS ix_items_product_id ON olist_order_items_dataset(product_id);
CREATE INDEX IF NOT EXISTS ix_items_seller_id ON olist_order_items_dataset(seller_id);

-- Customers
CREATE INDEX IF NOT EXISTS ix_customers_customer_id ON olist_customers_dataset(customer_id);
CREATE INDEX IF NOT EXISTS ix_customers_state ON olist_customers_dataset(customer_state);

--views

CREATE OR REPLACE VIEW bi_dim_product AS
SELECT
  p.product_id,
  COALESCE(t.product_category_name_english, p.product_category_name) AS category,
  p.product_weight_g,
  p.product_length_cm,
  p.product_height_cm,
  p.product_width_cm,
  (p.product_length_cm * p.product_height_cm * p.product_width_cm) AS volume_cm3
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t
  ON t.product_category_name = p.product_category_name;


CREATE OR REPLACE VIEW bi_fact_review_latest AS
SELECT DISTINCT ON (r.order_id)
  r.order_id,
  r.review_score,
  r.review_creation_date,
  r.review_answer_timestamp
FROM olist_order_reviews_dataset r
ORDER BY r.order_id, r.review_creation_date DESC NULLS LAST;


CREATE OR REPLACE VIEW bi_fact_order AS
SELECT
  o.order_id,
  o.customer_id,
  o.order_status,
  o.order_purchase_timestamp::date AS purchase_date,
  date_trunc('month', o.order_purchase_timestamp)::date AS purchase_month,
  o.order_delivered_customer_date::date AS delivered_date,
  o.order_estimated_delivery_date::date AS estimated_date,
  CASE
    WHEN o.order_status = 'delivered'
     AND o.order_delivered_customer_date IS NOT NULL
    THEN (o.order_delivered_customer_date::date - o.order_purchase_timestamp::date)
    ELSE NULL
  END AS delivery_days,
  CASE
    WHEN o.order_status = 'delivered'
     AND o.order_delivered_customer_date IS NOT NULL
     AND o.order_estimated_delivery_date IS NOT NULL
     AND o.order_delivered_customer_date::date > o.order_estimated_delivery_date::date
    THEN 1 ELSE 0
  END AS is_late,
  c.customer_unique_id,
  c.customer_city,
  c.customer_state
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON c.customer_id = o.customer_id;


CREATE OR REPLACE VIEW bi_fact_sales AS
SELECT
  oi.order_id,
  oi.order_item_id,
  oi.product_id,
  oi.seller_id,
  oi.shipping_limit_date::date AS shipping_limit_date,
  oi.price,
  oi.freight_value,
  fo.customer_id,
  fo.customer_unique_id,
  fo.order_status,
  fo.purchase_date,
  fo.purchase_month,
  fo.delivered_date,
  fo.estimated_date,
  fo.delivery_days,
  fo.is_late,
  fo.customer_city,
  fo.customer_state,
  dp.category,
  r.review_score,
  p.payment_type,
  p.payment_installments,
  p.payment_value,
  s.seller_city,
  s.seller_state
FROM olist_order_items_dataset oi
JOIN bi_fact_order fo ON fo.order_id = oi.order_id
LEFT JOIN bi_dim_product dp ON dp.product_id = oi.product_id
LEFT JOIN bi_fact_review_latest r ON r.order_id = oi.order_id
LEFT JOIN olist_order_payments_dataset p ON p.order_id = oi.order_id
LEFT JOIN olist_sellers_dataset s ON s.seller_id = oi.seller_id;


CREATE OR REPLACE VIEW bi_payments_order AS
SELECT
  op.order_id,
  SUM(op.payment_value) AS order_payment_value,
  MAX(op.payment_installments) AS order_payment_installments,
  (ARRAY_AGG(op.payment_type ORDER BY op.payment_value DESC NULLS LAST))[1] AS order_payment_type
FROM olist_order_payments_dataset op
GROUP BY op.order_id;

-- Payments
CREATE INDEX IF NOT EXISTS ix_payments_order_id ON olist_order_payments_dataset(order_id);

-- Reviews
CREATE INDEX IF NOT EXISTS ix_reviews_order_id ON olist_order_reviews_dataset(order_id);

