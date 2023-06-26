-- 3 Years Analysis of the database
USE mavenfuzzyfactory;

-- Growth over last 3 years interms of traffic and order value
-- Sessions, orders volume trended by quarter
SELECT
	YEAR(W.created_at) AS Year,
	QUARTER(W.created_at) AS quarter,
    MIN(DATE(W.created_at)) AS quarter_start_date,
    COUNT(DISTINCT W.website_session_id) AS traffic,
    COUNT(DISTINCT O.order_id) AS orders_placed,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT W.website_session_id) AS conversion_rate
FROM website_sessions AS W 
			LEFT JOIN orders AS O 
				ON W.website_session_id = O.website_session_id
WHERE W.created_at < '2015-03-20'
GROUP BY 1, 2;


-- Revenue per order, revenue per session
SELECT
	YEAR(W.created_at) AS Year,
	QUARTER(W.created_at) AS quarter,
    MIN(DATE(W.created_at)) AS quarter_start_date,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT W.website_session_id) AS order_conversion_rate,
    SUM(price_usd) AS revenue,
    SUM(cogs_usd) AS margin,
    SUM(price_usd)/COUNT(DISTINCT O.order_id) AS revenue_per_order,
    SUM(price_usd)/COUNT(DISTINCT W.website_session_id) AS revenue_per_session
FROM website_sessions AS W 
			LEFT JOIN orders AS O 
				ON W.website_session_id = O.website_session_id
WHERE W.created_at < '2015-03-20'
GROUP BY 1, 2;


-- How much traffic did the channels brought in and what is the growth

SELECT  utm_source, utm_campaign, utm_content, http_referer, count(website_Session_id) FROM website_sessions WHERE created_at < '2015-01-01' GROUP BY 1,2,3,4;

/*
http_referer null and utm_content, utm_campaign, utm_source null then direct type in
http_referer not null, but utm_content, utm_campaign, utm_source null then organic growth 
rest non brand and brand sessions */


-- Orders and Traffic from the marketing channels 
SELECT
	YEAR(W.created_at) AS Year,
	QUARTER(W.created_at) AS quarter,
    MIN(DATE(W.created_at)) AS quarter_start_date,
    COUNT(DISTINCT W.website_session_id) AS traffic,
	COUNT(DISTINCT CASE WHEN W.utm_source = 'gsearch' and W.utm_campaign = 'nonbrand' THEN W.website_session_id ELSE NULL END) AS gsearch_nonbrand_traffic,
	COUNT(DISTINCT CASE WHEN W.utm_source = 'gsearch' and W.utm_campaign = 'nonbrand' THEN O.order_id ELSE NULL END) AS gsearch_nonbrand_orders,   
    COUNT(DISTINCT CASE WHEN W.utm_source = 'bsearch' and W.utm_campaign = 'nonbrand' THEN W.website_session_id ELSE NULL END) AS bsearch_nonbrand_traffic,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'bsearch' and W.utm_campaign = 'nonbrand' THEN O.order_id ELSE NULL END) AS bsearch_nonbrand_orders,
    COUNT(DISTINCT CASE WHEN W.utm_campaign = 'brand' THEN W.website_session_id ELSE NULL END) AS brand_traffic,
    COUNT(DISTINCT CASE WHEN W.utm_campaign = 'brand' THEN O.order_id ELSE NULL END) AS brand_orders,
    COUNT(DISTINCT CASE WHEN W.http_referer IS NOT NULL AND W.utm_campaign IS NULL THEN W.website_session_id ELSE NULL END) AS organic_traffic,
    COUNT(DISTINCT CASE WHEN W.http_referer IS NOT NULL AND W.utm_campaign IS NULL THEN O.order_id ELSE NULL END) AS organic_orders,
    COUNT(DISTINCT CASE WHEN W.http_referer IS NULL AND W.utm_campaign IS NULL THEN W.website_session_id ELSE NULL END) AS direct_typein_traffic,
    COUNT(DISTINCT CASE WHEN W.http_referer IS NULL AND W.utm_campaign IS NULL THEN O.order_id ELSE NULL END) AS direct_typein_orders
FROM website_sessions AS W
			LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE W.created_at < '2015-03-20'
GROUP BY 1, 2;


-- How are each products sale, revenue and cog 

SELECT DISTINCT product_id FROM order_items WHERE created_at < '2015-03-20';

SELECT
	YEAR(created_at) AS Year,
    MONTH(created_at) AS Month,
    DATE(MIN(created_at)) AS first_date,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_revenue,
    SUM(CASE WHEN product_id = 1 THEN (price_usd-cogs_usd) ELSE NULL END) AS mrfuzzy_margin,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_revenue,
    SUM(CASE WHEN product_id = 2 THEN (price_usd-cogs_usd) ELSE NULL END) AS lovebear_margin,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_revenue,
    SUM(CASE WHEN product_id = 3 THEN (price_usd-cogs_usd) ELSE NULL END) AS birthdaybear_margin,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_revenue,
    SUM(CASE WHEN product_id = 4 THEN (price_usd-cogs_usd) ELSE NULL END) AS minibear_margin,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin
FROM order_items 
WHERE created_at < '2015-03-20'
GROUP BY 1,2;


-- CROSS SELL ANALYSIS

WITH product_analysis AS (
SELECT
    O.primary_product_id AS primary_product,
    OI.product_id AS cross_sell_product,
    O.order_id
FROM orders AS O
	LEFT JOIN order_items AS OI
    ON O.order_id = OI.order_id
    AND OI.is_primary_item = 0
WHERE O.created_at > '2014-12-05')
SELECT
	 primary_product,
     COUNT(DISTINCT order_id) AS total_orders,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 1 THEN order_id ELSE NULL END) AS x_sold_1,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 2 THEN order_id ELSE NULL END) AS x_sold_2,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 3 THEN order_id ELSE NULL END) AS x_sold_3,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 4 THEN order_id ELSE NULL END) AS x_sold_4,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 1 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)  AS p1_cross_sell_rate,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 2 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)  AS p2_cross_sell_rate,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 3 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)  AS p3_cross_sell_rate,
     COUNT(DISTINCT CASE WHEN cross_sell_product = 4 THEN order_id ELSE NULL END)/COUNT(DISTINCT order_id)  AS p4_cross_sell_rate
FROM product_analysis
GROUP BY 1


    
	
	

    
    