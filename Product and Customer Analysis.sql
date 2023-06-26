


-- Monthly trends of the orders, 
-- revenue generated and the margin
USE mavenfuzzyfactory;

SELECT
	YEAR(created_at) AS Year,
	MONTH(created_at) AS Month,
    MIN(DATE(Created_at)) AS month_start_date,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price_usd) AS reveune,
    SUM(price_usd - cogs_usd) AS margin
FROM orders
WHERE created_at <= '2013-01-04' 
GROUP BY 1,2;

-- Impact of New Product Launch

SELECT
	YEAR(W.created_at) AS YEAR,
    MONTH(W.created_at) AS MONTH, 
    MIN(DATE(W.created_at)) AS start_of_month,
    COUNT(DISTINCT W.website_session_id) AS sessions,
    COUNT(DISTINCT O.order_id) AS orders,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT W.website_session_id) AS conversion_rate,
    SUM(O.price_usd)/COUNT(DISTINCT W.website_session_id) AS revenue_per_session,
    COUNT(DISTINCT CASE WHEN O.primary_product_id = 1 THEN order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN O.primary_product_id = 2 THEN order_id ELSE NULL END) AS product_two_orders
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id 
WHERE W.created_at > '2012-04-01'
AND W.created_at < '2013-04-04'
GROUP BY 1,2
ORDER BY 1 ;

-- Product Pathing Analysis 
-- Lets look at how many people hit the products page and where they went after wards
-- Need to compare 3 months before and 3 months after product launch
-- Product 2 was launched on Jan 06, 2013

-- Step 1 Identify the product sessions
CREATE TEMPORARY TABLE product_sessions
SELECT
	CASE WHEN W.created_at < '2013-01-06' THEN 'pre_product_launch'
		 WHEN W.created_at >= '2013-01-06' THEN 'post_product_launch' 
         ELSE 'check_logic' END AS time_line,
	W.website_session_id,
    W.website_pageview_id,
    W.created_at
FROM website_pageviews AS W
WHERE W.created_at < '2013-04-06'
AND W.created_at > '2012-10-06'
AND W.pageview_url = '/products';
SELECT * FROM product_sessions;

-- Step 2 Find the next pageview that occours after the products pageview
CREATE TEMPORARY TABLE next_pv_table
SELECT
	P.time_line,
    P.website_session_id,
    MIN(W.website_pageview_id) AS next_pv_id
FROM product_sessions AS P 
	LEFT JOIN website_pageviews AS W
    ON P.website_session_id = W.website_session_id
    AND W.website_pageview_id > P.website_pageview_id -- Very IMP
GROUP BY 1,2;
SELECT * FROM next_pv_table;
-- Next_pv_id Null then website_session_bounced at products_page

-- Step 3 Find the url associated with next_pv_id
CREATE TEMPORARY TABLE next_pageviews
SELECT
	N.time_line,
    N.website_session_id,
    W.pageview_url AS next_pageview_url
FROM next_pv_table AS N 
	LEFT JOIN website_pageviews AS W
    ON N.next_pv_id = W.website_pageview_id;
SELECT * FROM next_pageviews;
    
-- Step 4 Summarizing the data
SELECT
	time_line,
    COUNT(DISTINCT website_session_id) AS product_sessions,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id)  AS pct_w_nxt_pg,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear,
    COUNT(DISTINCT CASE WHEN next_pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM next_pageviews
GROUP BY 1
ORDER BY 1 DESC;



-- Product Level Conversion Funnels
-- Since Jan 6th 2014
-- to April 14th 2014
-- Funnel products<product<to_cart<to_shipping<to_billing<to_thankyou
-- Step 1 Flaging the URLS with 1,0
SELECT
	website_session_id,
    pageview_url,
    created_at,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy,
    CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END AS lovebear,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou
FROM website_pageviews
WHERE created_at > '2013-01-06' 
AND created_at < '2013-04-10'
AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/cart', '/shipping', '/billing-2','/thank-you-for-your-order');


-- Step 2 Building the product funnel based on the flagging table
CREATE TEMPORARY TABLE product_funnel 
SELECT
	website_session_id,
    MAX(fuzzy) AS flag_fuzzy,
    MAX(lovebear) AS flag_lovebear,
    MAX(cart) AS flag_cart,
    MAX(shipping) AS flag_shipping,
    MAX(billing) AS flag_billing,
    MAX(thankyou) AS flag_thankyou
FROM ( -- Step 1 SQL Code in subquery
SELECT
	website_session_id,
    pageview_url,
    created_at,
	CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy,
    CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END AS lovebear,
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping,
    CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END AS billing,
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou
FROM website_pageviews
WHERE created_at > '2013-01-06' 
AND created_at < '2013-04-10'
AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear', '/cart', '/shipping', '/billing-2','/thank-you-for-your-order')) AS session_level_flags
GROUP BY 1;
SELECT * FROM product_funnel;

-- Step 3 Number Analysis
SELECT
	CASE WHEN flag_fuzzy = 1 THEN 'fuzzy_sessions'
		 WHEN flag_lovebear = 1 THEN 'love_bear' ELSE 'check_logic' END AS prodcut_seen,
	COUNT(DISTINCT website_session_id) AS sessions,
    SUM(flag_cart) AS to_cart,
    SUM(flag_shipping) AS to_shipping,
    SUM(flag_billing) AS to_billing,
    SUM(flag_thankyou) AS to_thankyou 
FROM product_funnel 
GROUP BY 1;

-- Step 4 % Analysis
SELECT
	CASE WHEN flag_fuzzy = 1 THEN 'fuzzy_sessions'
		 WHEN flag_lovebear = 1 THEN 'love_bear' ELSE 'check_logic' END AS prodcut_seen,
	COUNT(DISTINCT website_session_id) AS sessions,
    SUM(flag_cart)/COUNT(DISTINCT website_session_id) AS product_clickrate,
    SUM(flag_shipping)/SUM(flag_cart) AS cart_clickrate,
    SUM(flag_billing)/SUM(flag_shipping) AS shipping_clickrate,
    SUM(flag_thankyou)/SUM(flag_billing) AS billing_clickrate
FROM product_funnel 
GROUP BY 1;

-- On Spet 25, 2013 users get the option to add 2nd product while on cart page\
-- Comparing the following metrics month before and after the change
-- Click through rate of cartpage
-- Average products per order
-- Average order value
-- Revenue per cart page view 
-- Step 1 Identifying relvant sessions
CREATE TEMPORARY TABLE cart_sessions
SELECT 
	CASE WHEN created_at < '2013-09-25' THEN 'pre_cross_sell'
		 WHEN created_at >= '2013-09-25' THEN 'post_cross_sell'
         ELSE 'check_logic' END AS time_period,
	website_session_id,
    website_pageview_id
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
AND pageview_url = '/cart';
SELECT * FROM cart_sessions;

-- Step 2
-- Now finding the website_sessions which clicked through the cart sessions
CREATE TEMPORARY TABLE after_cart_sessions
SELECT
	C.time_period,
    C.website_session_id,
    MIN(W.website_pageview_id) AS next_session_pageview_id
FROM cart_sessions AS C
	LEFT JOIN website_pageviews AS W 
    ON C.website_session_id = W.website_session_id
	AND C.website_pageview_id < W.website_pageview_id 
	-- This condintions help us only include the next pageview_id after cart session
GROUP BY 1, 2
HAVING MIN(W.website_pageview_id) IS NOT NULL;
-- Having condition limits the table to sessions which didn't bounce at the cart
SELECT * FROM after_cart_sessions;

-- Step 3
-- Now lets look at the orders which were successful after going through cart
-- Cart Orders which resulted in a sale
CREATE TEMPORARY TABLE cart_orders
SELECT
	C.time_period,
    C.website_session_id,
    O.order_id,
    O.items_purchased,
    O.price_usd
FROM cart_sessions AS C 
		INNER JOIN orders AS O 
        ON C.website_session_id = O.website_session_id;
SELECT * FROM cart_orders;


-- Step 4 Bringing All together
SELECT
	C.time_period,
    C.website_session_id,
    CASE WHEN A.next_session_pageview_id IS NULL THEN 0 ELSE 1 END AS flag_anotherpageview,
    CASE WHEN O.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    O.items_purchased,
    O.price_usd
FROM cart_sessions AS C 
	 LEFT JOIN after_cart_sessions AS A 
		ON C.website_session_id = A.website_session_id
	 LEFT JOIN cart_orders AS O 
		ON C.website_session_id = O.website_session_id 
ORDER BY 2;

-- Step 5
SELECT
	time_period,
    COUNT(website_session_id) AS cart_sessions,
    SUM(flag_anotherpageview) AS clicked_next_page,
    SUM(flag_anotherpageview)/COUNT(website_session_id) AS cart_click_rate,
    SUM(placed_order) AS orders_placed,
    SUM(items_purchased) AS products_purchased,
    SUM(items_purchased)/SUM(placed_order) AS products_per_order,
    SUM(price_usd)/SUM(placed_order) AS aov,
    SUM(price_usd)/COUNT(website_session_id) AS revenue_per_cartpage_view
FROM ( -- Step 4 as Subquery 
	SELECT
	C.time_period,
    C.website_session_id,
    CASE WHEN A.next_session_pageview_id IS NULL THEN 0 ELSE 1 END AS flag_anotherpageview,
    CASE WHEN O.order_id IS NULL THEN 0 ELSE 1 END AS placed_order,
    O.items_purchased,
    O.price_usd
FROM cart_sessions AS C LEFT JOIN after_cart_sessions AS A ON C.website_session_id = A.website_session_id
						LEFT JOIN cart_orders AS O ON C.website_session_id = O.website_session_id 
ORDER BY 2) AS total_data
GROUP BY 1;


-- Portfolio Expansion Analysis
-- Birthday Bear launched on December 12th, 2013
-- Pre and post analysis comparing 
-- month before v/s month after 
-- session to order conversion rate
-- Average Order Value
-- Products per order and revenue per session
-- Step 1 Bringing all the relevant data into one table
SELECT
	CASE WHEN W.created_at < '2013-12-12' THEN 'pre_launch'
		 WHEN W.created_at >= '2013-12-12' THEN 'post_launch' ELSE 'check_logic' END AS time_period,
	W.website_session_id,
    O.order_id,
    O.items_purchased,
    O.price_usd
FROM website_sessions AS W
	LEFT JOIN orders AS O
    ON W.website_session_id = O.website_session_id
WHERE W.created_at BETWEEN '2013-11-12' AND '2014-01-12';

-- Step 2 getting the numbers
SELECT
	time_period,
    COUNT(website_session_id) AS sessions,
    COUNT(order_id) AS orders,
    COUNT(order_id)/COUNT(website_session_id) AS conversion_rate,
    SUM(price_usd) AS revenue, 
    SUM(price_usd)/COUNT(order_id) AS AOV,
    SUM(items_purchased) AS products_sold,
    SUM(items_purchased)/COUNT(order_id) AS products_per_order,
    SUM(price_usd)/COUNT(website_session_id) AS revenue_per_session
FROM(    -- Step 1 as subquery
SELECT
	CASE WHEN W.created_at < '2013-12-12' THEN 'pre_launch'
		 WHEN W.created_at >= '2013-12-12' THEN 'post_launch' ELSE 'check_logic' END AS time_period,
	W.website_session_id,
    O.order_id,
    O.items_purchased,
    O.price_usd
FROM website_sessions AS W
	LEFT JOIN orders AS O
    ON W.website_session_id = O.website_session_id
WHERE W.created_at BETWEEN '2013-11-12' AND '2014-01-12') AS session_orders
GROUP BY 1;


SELECT
	CASE WHEN O.created_at < '2013-12-12' THEN 'pre_launch'
		 WHEN O.created_at >= '2013-12-12' THEN 'post_launch' ELSE 'check_logic' END AS time_period,
    O.primary_product_id AS primary_product,
    OI.product_id AS cross_sell_product,
    COUNT(DISTINCT O.order_id) AS orders
FROM orders AS O
	LEFT JOIN order_items AS OI
    ON O.order_id = OI.order_id
    AND OI.is_primary_item = 0
WHERE O.created_at BETWEEN '2013-11-12' AND '2014-01-12'
GROUP BY 1,2,3
ORDER BY 1 DESC;

SELECT DISTINCT product_id, price_usd, cogs_usd
FROM order_items;

-- Product Refund Rates of Fuzzy 
-- Step 1
SELECT
	O.created_at,
    O.product_id,
    O.order_item_id,
    CASE WHEN R.order_item_refund_id IS NULL THEN 0 ELSE 1 END AS refund_status
FROM order_items AS O
			LEFT JOIN order_item_refunds AS R 
            ON O.order_item_id = R.order_item_id
WHERE O.created_at < '2014-10-15';

SELECT
	YEAR(created_at),
    MONTH(created_at),
    MIN(DATE(created_at)),
    COUNT(CASE WHEN product_id =1 THEN order_item_id ELSE NULL END) AS orders_p1,
    SUM(CASE WHEN product_id =1 AND refund_status =1 THEN 1 ELSE 0 END)/COUNT(CASE WHEN product_id =1 THEN order_item_id ELSE NULL END) AS rrate_p1,
    COUNT(CASE WHEN product_id =2 THEN order_item_id ELSE NULL END) AS orders_p2,
    SUM(CASE WHEN product_id =2 AND refund_status =1 THEN 1 ELSE 0 END)/COUNT(CASE WHEN product_id =2 THEN order_item_id ELSE NULL END) AS rrate_p2,
    COUNT(CASE WHEN product_id =3 THEN order_item_id ELSE NULL END) AS orders_p3,
    SUM(CASE WHEN product_id =3 AND refund_status =1 THEN 1 ELSE 0 END)/COUNT(CASE WHEN product_id =3 THEN order_item_id ELSE NULL END) AS rrate_p3,
    COUNT(CASE WHEN product_id =4 THEN order_item_id ELSE NULL END) AS orders_p4,
    SUM(CASE WHEN product_id =4 AND refund_status =1 THEN 1 ELSE 0 END)/COUNT(CASE WHEN product_id =4 THEN order_item_id ELSE NULL END) AS rrate_p4
FROM ( -- Step 1 as Sub Query
SELECT
	O.created_at,
    O.product_id,
    O.order_item_id,
    CASE WHEN R.order_item_refund_id IS NULL THEN 0 ELSE 1 END AS refund_status
FROM order_items AS O
			LEFT JOIN order_item_refunds AS R 
            ON O.order_item_id = R.order_item_id
WHERE O.created_at < '2014-10-15') AS order_data
GROUP BY 1,2 ;
	

-- Identify the relvant sessions


CREATE TEMPORARY TABLE sessions_W_repeat
SELECT
	new_sessions.user_id,     -- User ID for all the new sessions
    new_sessions.website_session_id AS new_session_id, -- Tagging all the new customers who visited the website
    website_sessions.website_session_id -- repeat sessions [Joining on user_id, we will have only one user
FROM (
SELECT 
	user_id,
    website_session_id
FROM website_sessions
WHERE created_at < '2014-11-01' AND created_at >= '2014-01-01'
AND is_repeat_session = 0  ) AS new_sessions -- New sessions only
LEFT JOIN website_sessions ON website_sessions.user_id = new_sessions.user_id
			AND website_sessions.is_repeat_session = 1
            AND website_sessions.website_session_id > new_sessions.website_session_id 
            AND created_at < '2014-11-01' AND created_at >= '2014-01-01';

-- There could be multiple repeat sessions for one new session

SELECT * FROM sessions_W_repeat;


SELECT
	repeat_sessions_flag AS repeat_sessions,
    COUNT(DISTINCT user_id) AS users
FROM (
SELECT
	user_id,
    COUNT(DISTINCT new_session_id),
    COUNT(DISTINCT website_session_id) AS repeat_sessions_flag-- Repeat sessions
FROM sessions_W_repeat
GROUP BY 1
ORDER BY 3) AS user_level
GROUP BY 1;


-- Analyzing repeat behavior 





    
