USE project;

-- customers: customer_id, customer_unique_id
-- order_items: order_id, product_id, seller_id, price, freight_value
-- order_reviews: review_id, order_id, review_score
-- orders: order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivery_carrier_date, order_delivered_customer_date, order_estimated_delivery_date
-- products: product_id, product_category_name(연결용)
-- product_category_name: product_category_name, product_category_name_english

DROP VIEW IF EXISTS customers_c;
CREATE VIEW customers_c AS
SELECT customer_id, customer_unique_id
FROM customers;

DROP VIEW IF EXISTS order_items_oi;
CREATE VIEW order_items_oi AS
SELECT order_id, product_id, seller_id, price + freight_value AS price, shipping_limit_date
FROM order_items;

DROP VIEW IF EXISTS order_reviews_or;
CREATE VIEW order_reviews_or AS
SELECT review_id, order_id, review_score
FROM order_reviews;

DROP VIEW IF EXISTS orders_o;
CREATE VIEW orders_o AS
SELECT order_id, customer_id, order_status
		, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date,
       DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_period,
       YEAR(order_purchase_timestamp) AS purchase_year,
       MONTH(order_purchase_timestamp) AS purchase_month,
       DAY(order_purchase_timestamp) AS purchase_day
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_approved_at IS NOT NULL
  AND order_delivered_carrier_date IS NOT NULL
  AND order_status <> 'canceled';
  
SELECT * FROM orders_o;

DROP VIEW IF EXISTS products_p;
CREATE VIEW products_p AS
SELECT p.product_id
   , CASE 
        WHEN p.product_category_name = 'pc_gamer' THEN 'pc_gamer'
        WHEN p.product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos' THEN 'portable kitchen appliances and food preparers'
        ELSE pc.product_category_name_english
     END AS category
    , p.product_name_lenght, p.product_description_lenght, p.product_photos_qty
FROM products p
LEFT JOIN product_category pc
ON p.product_category_name = pc.product_category_name
WHERE p.product_category_name IS NOT NULL;

-- ------------------------------------------------------------------------------------------
SELECT cc.customer_id, cc.customer_unique_id
		, oioi.order_id, oioi.product_id, oioi.seller_id, oioi.price, oioi.shipping_limit_date
        , oror.review_id, oror.review_score, oo.order_status
		, oo.order_purchase_timestamp, oo.order_approved_at, oo.order_delivered_carrier_date, oo.order_delivered_customer_date, oo.order_estimated_delivery_date
        , oo.delivery_period, oo.purchase_year, oo.purchase_month, oo.purchase_day
        , pp.category, pp.product_name_lenght, pp.product_description_lenght, pp.product_photos_qty
FROM customers_c cc, order_items_oi oioi, order_reviews_or oror, orders_o oo, products_p pp
WHERE oo.order_id = oioi.order_id
	AND oo.order_id = oror.order_id
    AND oo.customer_id = cc.customer_id
    AND oioi.product_id = pp.product_id;

SELECT * FROM geolocation;

SELECT * FROM geolocation
WHERE geolocation_zip_code_prefix IS NULL;
