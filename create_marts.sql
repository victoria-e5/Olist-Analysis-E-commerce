CREATE TABLE olist_orders_dataset (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);
CREATE TABLE olist_order_items_dataset (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);
CREATE TABLE olist_products_dataset (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
CREATE TABLE olist_customers_dataset (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);
CREATE TABLE olist_order_payments_dataset (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

SELECT * FROM olist_customers_dataset LIMIT 5;
SELECT * FROM olist_order_payments_dataset LIMIT 5;
SELECT * FROM olist_orders_dataset LIMIT 5;

CREATE OR REPLACE VIEW mart_orders_finance AS
WITH payment_agg AS (
    SELECT 
        order_id,
        SUM(payment_value) AS total_revenue,
        COUNT(payment_sequential) AS payments_count
    FROM olist_order_payments_dataset
    GROUP BY order_id
)
SELECT 
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    COALESCE(p.total_revenue, 0) AS total_revenue,
    COALESCE(p.payments_count, 0) AS payments_count
FROM olist_orders_dataset o
LEFT JOIN payment_agg p ON o.order_id = p.order_id;

SELECT * FROM mart_orders_finance LIMIT 10;

CREATE OR REPLACE VIEW mart_behavioral_retention AS
WITH valid_orders AS (
    SELECT 
        o.order_id,
        c.customer_unique_id,
        o.order_purchase_timestamp
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
windowed_metrics AS (
    SELECT 
        order_id,
        customer_unique_id,
        order_purchase_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY customer_unique_id 
            ORDER BY order_purchase_timestamp
        ) AS order_sequence_num,
        LAG(order_purchase_timestamp) OVER (
            PARTITION BY customer_unique_id 
            ORDER BY order_purchase_timestamp
        ) AS prev_order_date
    FROM valid_orders
)
SELECT 
    order_id,
    customer_unique_id,
    order_purchase_timestamp,
    order_sequence_num,
    prev_order_date,
    DATE(order_purchase_timestamp) - DATE(prev_order_date) AS days_since_prior_order
FROM windowed_metrics;

SELECT * FROM mart_behavioral_retention LIMIT 10;

SELECT * FROM mart_behavioral_retention 
WHERE order_sequence_num > 1 
ORDER BY days_since_prior_order DESC;

CREATE OR REPLACE VIEW mart_rfm_profile AS
WITH base_data AS (
    SELECT 
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp,
        p.payment_value
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    LEFT JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    WHERE o.order_status = 'delivered'
),
rfm_calc AS (
    SELECT 
        customer_unique_id,
        MAX(order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(payment_value) AS monetary
    FROM base_data
    GROUP BY customer_unique_id
)
SELECT 
    customer_unique_id,
    (SELECT DATE(MAX(order_purchase_timestamp)) FROM olist_orders_dataset) - DATE(last_order_date) AS recency,
    frequency,
    COALESCE(monetary, 0) AS monetary
FROM rfm_calc;

SELECT * FROM mart_rfm_profile 
ORDER BY monetary DESC 
LIMIT 10;

SELECT * FROM mart_rfm_profile 
ORDER BY frequency DESC 
LIMIT 10;

SELECT * FROM mart_rfm_profile 
ORDER BY recency DESC 
LIMIT 10;
