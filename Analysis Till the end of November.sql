USE mavenfuzzyfactory;


/* Story of the database from the first date to Novemeber 27, 2012.  Understand how the company is performing from the data. */

-- created_at < '2012-11-27';

-- There are multilple marketing campaigns running, in the database.
-- Lets look at how gsearch campaigns are running

SELECT DISTINCT utm_source, utm_campaign FROM website_sessions;

SELECT
	MONTH(W.created_at) AS month,
    MIN(DATE(W.created_at)) AS month_start_date,
	COUNT(DISTINCT W.website_session_id) AS Gsearch_sessions,
    COUNT(DISTINCT O.order_id) AS orders_resulted,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT W.website_session_id) AS conversion_rate
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE w.created_at <'2012-11-27'
AND w.utm_source = 'gsearch'
GROUP BY 1;



-- Splitting on how different gsearch marketing campaigns working
-- There are tow gsearch campaigns running, brand and nonbrand

SELECT
	MONTH(W.created_at) AS month,
    MIN(DATE(W.created_at)) AS month_start_date,
	COUNT(DISTINCT CASE WHEN W.utm_campaign = 'nonbrand' THEN W.website_session_id ELSE NULL END) AS nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN W.utm_campaign = 'nonbrand' THEN O.order_id ELSE NULL END) AS nonbrand_orders,
    COUNT(DISTINCT CASE WHEN W.utm_campaign = 'nonbrand' THEN O.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN W.utm_campaign = 'nonbrand' THEN W.website_session_id ELSE NULL END)  AS nonbrands_conversion_rate,
    COUNT(DISTINCT CASE WHEN W.utm_campaign = 'brand' THEN W.website_session_id ELSE NULL END) AS brand_sessions,
    COUNT(DISTINCT CASE WHEN W.utm_campaign = 'brand' THEN O.order_id ELSE NULL END) AS brand_orders,
    COUNT(DISTINCT CASE WHEN W.utm_campaign = 'brand' THEN O.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN W.utm_campaign = 'brand' THEN W.website_session_id ELSE NULL END) AS brand_conversion_rate
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE w.created_at <'2012-11-27'
AND w.utm_source = 'gsearch'
GROUP BY 1;      

-- Looking at which device type is driving the most orders for the gsearch campaigns 

SELECT DISTINCT device_type FROM website_sessions;

SELECT
	MONTH(W.created_at) AS month,
    MIN(DATE(W.created_at)) AS month_start_date,
	COUNT(DISTINCT CASE WHEN W.device_type = 'mobile' THEN W.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN W.device_type = 'mobile' THEN O.order_id ELSE NULL END) AS mobile_orders,
    COUNT(DISTINCT CASE WHEN W.device_type = 'mobile' THEN O.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN W.device_type = 'mobile' THEN W.website_session_id ELSE NULL END)  AS mobile_conversion_rate,
    COUNT(DISTINCT CASE WHEN W.device_type = 'desktop' THEN W.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN W.device_type = 'desktop' THEN O.order_id ELSE NULL END) AS desktop_orders,
    COUNT(DISTINCT CASE WHEN W.device_type = 'desktop' THEN O.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN W.device_type = 'desktop' THEN W.website_session_id ELSE NULL END) AS desktop_conversion_rate
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE w.created_at <'2012-11-27'
AND w.utm_source = 'gsearch'
GROUP BY 1;    

-- How are each channels driving the traffic and oder rate

SELECT DISTINCT utm_source FROM website_sessions WHERE created_at <'2012-11-27';

SELECT
	MONTH(W.created_at) AS month,
    MIN(DATE(W.created_at)) AS month_start_date,
	COUNT(DISTINCT CASE WHEN W.utm_source = 'gsearch' THEN W.website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'gsearch' THEN O.order_id ELSE NULL END) AS gsearcg_orders,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'gsearch' THEN O.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN W.utm_source = 'gsearch' THEN W.website_session_id ELSE NULL END)  AS gsearch_conversion_rate,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'bsearch' THEN W.website_session_id ELSE NULL END) AS bsearch_sessions,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'bsearch' THEN O.order_id ELSE NULL END) AS bsearch_orders,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'bsearch' THEN O.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN W.utm_source = 'bsearch' THEN W.website_session_id ELSE NULL END) AS bsearch_conversion_rate,
    COUNT(DISTINCT CASE WHEN W.utm_source IS NULL THEN W.website_session_id ELSE NULL END) AS other_sessions,
    COUNT(DISTINCT CASE WHEN W.utm_source IS NULL THEN O.order_id ELSE NULL END) AS other_orders,
    COUNT(DISTINCT CASE WHEN W.utm_source IS NULL THEN O.order_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN W.utm_source IS NULL THEN W.website_session_id ELSE NULL END) AS other_conversion_rate
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE w.created_at <'2012-11-27'
GROUP BY 1;    

-- How is the website performing over months 

SELECT
	YEAR(W.created_at),
    MONTH(W.created_at),
    MIN(DATE(W.created_at)) AS month_start_date,
    COUNT(DISTINCT W.website_session_id) AS website_sessions,
    COUNT(DISTINCT O.order_id) AS orders,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT W.website_session_id) AS conversion_rate
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE w.created_at <'2012-11-27'
GROUP BY 1,2;





-- Lander Test, how much is increment in the revenue?
-- Step 1 Identify the lander page view IDS
SELECT
	min(website_session_id),
    min(website_pageview_id)
FROM
	website_pageviews
WHERE pageview_url = '/lander-1';
# min(website_session_id), min(website_pageview_id)
# '11683', '23504'

DROP TABLE landing_ids;



-- Step 2 Idenitfy the landing pageview_ids
CREATE TEMPORARY TABLE landing_ids
SELECT
	P.website_session_id,
    MIN(P.website_pageview_id) AS website_pageview_id
FROM website_pageviews AS P 
	LEFT JOIN website_sessions AS S 
    ON P.website_session_id = S.website_session_id
WHERE
	P.website_session_id >= 11633 
AND P.created_at < '2012-07-28' -- A/B Testing was done in this time period
AND S.utm_source = 'gsearch'
AND S.utm_campaign = 'nonbrand'
GROUP BY 1;
SELECT * FROM landing_ids;

-- Step 3 
-- Joining it with URLs and the order_id table
CREATE TEMPORARY TABLE landing_page
SELECT
	L.website_session_id,
    W.pageview_url AS landing_url 
FROM landing_ids AS L 
	LEFT JOIN website_pageviews AS W 
    ON L.website_pageview_id = W.website_pageview_id;
SELECT * FROM landing_page;

-- Step 4
-- Now joining this with the orders table 
-- to find the increament in order conversion rate
CREATE TEMPORARY TABLE testing_orders
SELECT
	L.website_session_id,
	L.landing_url,
    O.order_id 
FROM landing_page AS L
	LEFT JOIN orders AS O 
    ON L.website_session_id = O.website_session_id ;
SELECT * FROM testing_orders;

-- Step 5, Calculating Conversion Rate
SELECT
	landing_url,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT website_session_id) AS conversion_rate 
FROM testing_orders
GROUP BY 1;
-- increment in the conversion raate = 0.0405 - 0.0325 = 0.0084



-- Now lets look at when was lander1 was made as the main landing page for the business

SELECT
	MAX(P.website_session_id),
    MAX(P.website_pageview_id),
    MAX(P.created_at)
FROM website_pageviews AS P 
	LEFT JOIN website_sessions AS S ON P.website_session_id = S.website_session_id
WHERE S.utm_source = 'gsearch'
AND S.utm_campaign = 'nonbrand'
AND P.pageview_url = '/home'
AND S.created_at < '2012-11-27';

# MAX(P.website_session_id), MAX(P.website_pageview_id)
# '17145', '35339'

-- After website_session_id 17145

SELECT
	count(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND created_at < '2012-11-27'
AND website_session_id > 17145;

-- 22972 order since the test
-- lift in conversion rate 0.0084
-- 192 incremental orders since A/B test concluded 





-- Conversion funnel Analysis
-- FOR the A/B Test period

SELECT DISTINCT pageview_url FROM website_pageviews;


-- home or lander1, products, fuzzy, cart, shipping, billing, thankyou

SELECT
	S.website_session_id,
    P.pageview_url,
    P.created_at,
    CASE WHEN p.pageview_url = '/home' THEN 1 ELSE 0 END AS flag_home,
    CASE WHEN p.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS flag_lander1,
    CASE WHEN p.pageview_url = '/products' THEN 1 ELSE 0 END AS flag_products,
    CASE WHEN p.pageview_url =  '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS flag_fuzzy,
    CASE WHEN p.pageview_url =  '/cart' THEN 1 ELSE 0 END AS flag_cart,
    CASE WHEN p.pageview_url =  '/shipping' THEN 1 ELSE 0 END AS flag_shipping,
    CASE WHEN p.pageview_url =  '/billing' THEN 1 ELSE 0 END AS flag_billing,
    CASE WHEN p.pageview_url =  '/thank-you-for-your-order' THEN 1 ELSE 0 END AS flag_thankyou
FROM website_sessions AS S
	LEFT JOIN website_pageviews AS P ON S.website_session_id = P.website_session_id
WHERE S.created_at >= '2012-06-19' 
AND S.created_at <= '2012-07-28'
AND S.utm_source = 'gsearch'
AND S.utm_campaign = 'nonbrand'
ORDER BY 1,3;



DROP TABLE session_level;

CREATE TEMPORARY TABLE session_level
SELECT
	website_session_id,
    MAX(flag_home) AS saw_home,
    MAX(flag_lander1) AS saw_lander1,
    MAX(flag_products) AS saw_products,
    MAX(flag_fuzzy) AS saw_fuzzy,
    MAX(flag_cart) AS saw_cart,
    MAX(flag_shipping) AS saw_shipping,
    MAX(flag_billing) AS saw_billing,
    MAX(flag_thankyou) AS saw_thankyou
FROM (
SELECT
	S.website_session_id,
    P.pageview_url,
    P.created_at,
    CASE WHEN p.pageview_url = '/home' THEN 1 ELSE 0 END AS flag_home,
    CASE WHEN p.pageview_url = '/lander-1' THEN 1 ELSE 0 END AS flag_lander1,
    CASE WHEN p.pageview_url = '/products' THEN 1 ELSE 0 END AS flag_products,
    CASE WHEN p.pageview_url =  '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS flag_fuzzy,
    CASE WHEN p.pageview_url =  '/cart' THEN 1 ELSE 0 END AS flag_cart,
    CASE WHEN p.pageview_url =  '/shipping' THEN 1 ELSE 0 END AS flag_shipping,
    CASE WHEN p.pageview_url =  '/billing' THEN 1 ELSE 0 END AS flag_billing,
    CASE WHEN p.pageview_url =  '/thank-you-for-your-order' THEN 1 ELSE 0 END AS flag_thankyou
FROM website_sessions AS S
	LEFT JOIN website_pageviews AS P ON S.website_session_id = P.website_session_id
WHERE S.created_at >= '2012-06-19' 
AND S.created_at <= '2012-07-28'
AND S.utm_source = 'gsearch'
AND S.utm_campaign = 'nonbrand'
ORDER BY 1,3) AS pageview_level
GROUP BY 1;


SELECT * FROM session_level;

SELECT
	CASE 
		WHEN saw_home = 1 THEN 'saw_homepage'
        WHEN saw_lander1 = 1 THEN 'saw_lander1'
        ELSE 'check_logic' END AS lander_type,
	COUNT(website_session_id) AS sessions,
    SUM(saw_products) AS to_products,
    SUM(saw_fuzzy) AS to_fuzzy,
    SUM(saw_cart) AS to_cart,
    SUM(saw_shipping) AS to_shipping,
    SUM(saw_billing) AS to_billing,
    SUM(saw_thankyou) AS to_thankyou 
FROM session_level 
GROUP BY 1;
	
        

SELECT
	CASE 
		WHEN saw_home = 1 THEN 'saw_homepage'
        WHEN saw_lander1 = 1 THEN 'saw_lander1'
        ELSE 'check_logic' END AS lander_type,
    SUM(saw_products)/COUNT(website_session_id) AS clickrate_lander,
    SUM(saw_fuzzy)/SUM(saw_products) AS clickrate_products,
    SUM(saw_cart)/SUM(saw_fuzzy) AS clickrate_fuzzy,
    SUM(saw_shipping)/SUM(saw_cart) AS clickrate_cart,
    SUM(saw_billing)/SUM(saw_shipping) AS clickrate_shipping,
    SUM(saw_thankyou)/SUM(saw_billing) AS clickrate_billing 
FROM session_level 
GROUP BY 1;


-- Quantfying the billing test in terms revenue per billing session

-- Lets first identify the billing sessions, whether they resulted in a order or not 


SELECT
	P.website_session_id,
    P.pageview_url,
    O.order_id,
    O.price_usd
FROM website_pageviews AS P
	LEFT JOIN orders AS O ON P.website_session_id = O.website_session_id
WHERE P.created_at > '2012-09-10' 
AND P.created_at < '2012-11-10'
AND P.pageview_url IN ('/billing', '/billing-2');
	

-- finding the lift

SELECT
	pageview_url, 
    COUNT(website_session_id) AS billing_sessions,
    SUM(price_usd)/COUNT(website_session_id) AS revenue_per_billingsessions
FROM (
SELECT
	P.website_session_id,
    P.pageview_url,
    O.order_id,
    O.price_usd
FROM website_pageviews AS P
	LEFT JOIN orders AS O ON P.website_session_id = O.website_session_id
WHERE P.created_at > '2012-09-10' 
AND P.created_at < '2012-11-10'
AND P.pageview_url IN ('/billing', '/billing-2')) AS billing
GROUP BY 1;

-- There is a lift of 8.51 dollars per billing session seen 

-- Monthly Impact
SELECT
	count(website_session_id) AS billing_sessions
FROM website_pageviews
WHERE 
created_at >= '2012-10-27'
AND created_at <= '2012-11-27'
AND pageview_url IN ('/billing', '/billing-2')

-- 1193*8.51 = 10152 additional billing generated 



