-- =========================
-- DATA CHECKING
-- =========================

-- 1. Total Customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM customers;

-- 2. Total Orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- 3. Total Revenue
SELECT ROUND(SUM(payment_value),2) AS total_revenue
FROM order_payments;

-- 4. Average Order Value
SELECT ROUND(SUM(payment_value)/COUNT(DISTINCT order_id),2) AS avg_order_value
FROM order_payments;

-- 5. Total Products
SELECT COUNT(DISTINCT product_id) AS total_products
FROM products;

-- =========================
-- DATA CLEANING
-- =========================

-- 6. Check NULL Delivery Dates
SELECT COUNT(*)
FROM orders
WHERE order_delivered_customer_date IS NULL;

-- 7. Check Duplicate Customers
SELECT customer_id,
       COUNT(*)
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 8. Orders by Status
SELECT order_status,
       COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

-- =========================
-- CUSTOMER ANALYSIS
-- =========================

-- 9. Top 10 Customers by Orders
SELECT customer_id,
       COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC
LIMIT 10;

-- 10. Repeat Customers
SELECT customer_id,
       COUNT(order_id) AS orders_count
FROM orders
GROUP BY customer_id
HAVING COUNT(order_id) > 1;

-- 11. Top Customers by Revenue
SELECT o.customer_id,
       ROUND(SUM(op.payment_value),2) AS revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY o.customer_id
ORDER BY revenue DESC
LIMIT 10;

-- =========================
-- PRODUCT ANALYSIS
-- =========================

-- 12. Top Products Sold
SELECT product_id,
       COUNT(*) AS units_sold
FROM order_items
GROUP BY product_id
ORDER BY units_sold DESC
LIMIT 10;

-- 13. Top Products by Revenue
SELECT product_id,
       ROUND(SUM(price),2) AS revenue
FROM order_items
GROUP BY product_id
ORDER BY revenue DESC
LIMIT 10;

-- 14. Most Expensive Products
SELECT product_id,
       MAX(price) AS max_price
FROM order_items
GROUP BY product_id
ORDER BY max_price DESC
LIMIT 10;

-- =========================
-- PAYMENT ANALYSIS
-- =========================

-- 15. Revenue by Payment Type
SELECT payment_type,
       ROUND(SUM(payment_value),2) AS revenue
FROM order_payments
GROUP BY payment_type
ORDER BY revenue DESC;

-- 16. Average Payment by Type
SELECT payment_type,
       ROUND(AVG(payment_value),2) AS avg_payment
FROM order_payments
GROUP BY payment_type;

-- =========================
-- LOCATION ANALYSIS
-- =========================

-- 17. Revenue by State
SELECT c.customer_state,
       ROUND(SUM(op.payment_value),2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- 18. Orders by State
SELECT c.customer_state,
       COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;

-- =========================
-- TIME ANALYSIS
-- =========================

-- 19. Monthly Revenue
SELECT DATE_TRUNC('month', order_purchase_timestamp::timestamp) AS month,
       COUNT(*) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;

-- 20. Monthly Revenue Trend
SELECT DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS month,
       ROUND(SUM(op.payment_value),2) AS revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY month
ORDER BY month;

-- 21. Average Delivery Time
SELECT AVG(
(order_delivered_customer_date::timestamp -
 order_purchase_timestamp::timestamp)
) AS avg_delivery_time
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;

-- =========================
-- CTE
-- =========================

-- 22. Top Revenue Customers Using CTE
WITH customer_revenue AS
(
SELECT o.customer_id,
       SUM(op.payment_value) AS revenue
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY o.customer_id
)
SELECT *
FROM customer_revenue
ORDER BY revenue DESC
LIMIT 10;

-- =========================
-- WINDOW FUNCTIONS
-- =========================

-- 23. Revenue Ranking
SELECT payment_type,
       SUM(payment_value) AS revenue,
       RANK() OVER
       (ORDER BY SUM(payment_value) DESC) AS rank_no
FROM order_payments
GROUP BY payment_type;

-- 24. Running Revenue Total
SELECT DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS month,
       SUM(op.payment_value) AS revenue,
       SUM(SUM(op.payment_value))
       OVER(ORDER BY DATE_TRUNC('month', o.order_purchase_timestamp::timestamp))
       AS running_total
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY month;

-- 25. Customer Revenue Ranking
SELECT o.customer_id,
       SUM(op.payment_value) AS revenue,
       DENSE_RANK() OVER
       (ORDER BY SUM(op.payment_value) DESC) AS rank_no
FROM orders o
JOIN order_payments op
ON o.order_id = op.order_id
GROUP BY o.customer_id;