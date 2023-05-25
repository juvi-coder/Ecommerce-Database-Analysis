-- Website Performance Analysis

USE mavenfuzzyfactory;

-- Top Website Pages

SELECT
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS views
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC;

-- what we see the home page gets the vast majority of the page used during this time period followed by the products and the original Mr. fuzzy page 

-- Finding Top Entry Pages

/* Step 1 Find the website_session_id and
respective minimum page view id [Landing Page] */

CREATE TEMPORARY TABLE landing_pages
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pageview_id 
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 1;

SELECT * FROM landing_pages;


/* Step 2 Identify the pageview_url for the 
first_pageview_id */
CREATE TEMPORARY TABLE landing_urls
SELECT
	L.website_session_id,
    W.pageview_url AS landing_page
FROM landing_pages AS L 
	LEFT JOIN 
		website_pageviews AS W
			ON L.first_pageview_id = W.website_pageview_id;
	-- The above join gets the pageview_url of landing sessions
    -- only

SELECT * FROM landing_urls;

-- Final Step, grouping by landing_urls

SELECT
	landing_page,
    COUNT(website_session_id) AS sessions
FROM landing_urls
GROUP BY 1;

DROP TABLE landing_urls;
DROP TABLE landing_pages;


-- Bounce Rate Analysis 

/* Step 1 Need to identify the landing sessions */

CREATE TEMPORARY TABLE landing_sessions
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pageview_id 
    /*MIN(website_pageview_id) 
     Identifies the first page view id of each website session
     AKA landing page view */
FROM website_pageviews
WHERE created_at < '2012-06-14'
GROUP BY 1;

SELECT * FROM landing_sessions;

/* Step 2
Left Join to the website_pageviews table
Get the landing page url of each website session */

CREATE TABLE landing_pages
SELECT
	L.website_session_id AS website_session_id,
    W.pageview_url AS pageview_url 
FROM landing_sessions AS L 
	LEFT JOIN website_pageviews AS W 
	ON L.first_pageview_id = W.website_pageview_id;

SELECT * FROM landing_pages;

/* Step 3
Identifying bounce sessions, by left joining to website_pageviews */
CREATE TABLE bounced_sessions
SELECT 
	L.website_session_id AS website_session_id,
    L.pageview_url AS pageview_url,
    COUNT(W.website_pageview_id) AS pageviews 
    -- the above column will give us no pageviews for each session
FROM landing_pages AS L 
	 LEFT JOIN website_pageviews AS W 
     ON L.website_session_id = W.website_session_id
GROUP BY 1,2
HAVING COUNT(W.website_pageview_id) = 1;
-- We are limiting to only one sessions
-- bounce means they visited the landing_page but didn't go anyfuther in funnel.
SELECT * FROM bounced_sessions;

/* Step 4
Left joining the landing_pages and bounced_sessions
And using case and pivot to find bounce rate analysis  */

SELECT
	L.pageview_url AS URL,
	COUNT(L.website_session_id) AS sessions,
    COUNT(B.website_session_id) AS bounced_sessions,
    COUNT(B.website_session_id)/COUNT(L.website_session_id) AS bounce_rate
FROM landing_pages AS L
	 LEFT JOIN bounced_sessions AS B 
     ON L.website_session_id = B.website_session_id
GROUP BY 1;
-- we see that the home page has a 59.18% bounce rate .

-- A new custom lander ['/lander-1'] was developed
-- A/B test was run against home page for gsearch non brand traffic
-- Now lets look at the bounce_rates of both landing_pages

-- Step 1 Find when the lander_1 was live
SELECT
	MIN(website_session_id)
FROM website_pageviews
WHERE pageview_url = '/lander-1';
-- 11683 was the first session when '/lander-1' got live

/* Step 2 Need to identify the landing sessions */
CREATE TEMPORARY TABLE landing_ids
SELECT
	P.website_session_id,
    MIN(P.website_pageview_id) AS website_pageview_id 
    -- The First pageview_id for each session
FROM website_pageviews AS P 
	LEFT JOIN website_sessions AS S 
    ON P.website_session_id = S.website_session_id
WHERE P.website_session_id >= '11683' 
AND P.created_at < '2012-07-28'
AND S.utm_source = 'gsearch'
AND S.utm_campaign = 'nonbrand'
GROUP BY 1;
SELECT * FROM landing_ids;

/* Step 3
Left Join to the website_pageviews table
Get the landing page url of each website session */
CREATE TEMPORARY TABLE landing_pages
SELECT 
	L.website_session_id AS website_session_id,
    W.pageview_url AS pageview_url
FROM landing_ids AS L 
	LEFT JOIN website_pageviews AS W 
    ON L.website_pageview_id = W.website_pageview_id;
SELECT * FROM landing_pages;

/* Step 4
Identifying bounce sessions, by left joining to website_pageviews */
CREATE TEMPORARY TABLE bounced_sessions
SELECT
	L.website_session_id AS website_session_id,
    L.pageview_url AS pageview_url,
    COUNT(W.website_pageview_id) AS page_views
FROM landing_pages AS L 
	LEFT JOIN website_pageviews AS W 
    ON L.website_session_id = W.website_session_id
GROUP BY 1,2
HAVING page_views = 1;
SELECT * FROM bounced_sessions;

/* Step 5
Left joining the landing_pages and bounced_sessions
And using case and pivot to find bounce rate analysis*/

SELECT
	L.pageview_url AS landing_pages,
    COUNT(L.website_session_id) AS sessions,
    COUNT(B.website_session_id) AS bounced_sessions,
    COUNT(B.website_session_id)/COUNT(L.website_session_id) AS bounce_rate
FROM landing_pages AS L 
	LEFT JOIN bounced_sessions AS B 
    ON L.website_session_id = B.website_session_id 
GROUP BY 1;

-- Trend Analysis Bounce Rate

DROP TABLE landing_ids;

-- Step 1
-- Identify the landing pageview_ids
CREATE TEMPORARY TABLE landing_ids
SELECT 
	S.website_session_id,
    MIN(P.website_pageview_id) AS landing_id,
    COUNT(P.website_pageview_id) AS page_views
FROM website_sessions AS S
	LEFT JOIN website_pageviews AS P 
    ON P.website_session_id = S.website_session_id
WHERE S.created_at> '2012-06-01' 
AND S.created_at < '2012-08-31'
AND S.utm_source = 'gsearch'
AND S.utm_campaign = 'nonbrand'
GROUP BY 1;
SELECT * FROM landing_ids;


DROP TABLE landing_urls;
-- Step2 
-- Left join to website_pageviews
-- and identify the landing page urls for each session
CREATE TEMPORARY TABLE landing_urls
SELECT
	L.website_session_id,
    L.landing_id,
    L.page_views,
    W.pageview_url AS landing_url,
    W.created_at
FROM landing_ids AS L 
	LEFT JOIN website_pageviews AS W 
    ON L.landing_id = W.website_pageview_id;
SELECT * FROM landing_urls;


-- Step 3 Perform Trend Analysis    
SELECT
	YEAR(created_at) AS year,
    WEEK(created_at) AS week, 
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS website_sessions,
    COUNT(CASE WHEN page_views = 1 THEN website_session_id ELSE NULL END) AS bounced_sessions,
    COUNT(CASE WHEN page_views = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS overall_bounce_rate,
    COUNT(DISTINCT CASE WHEN landing_url = '/home' THEN website_session_id ELSE NULL END) AS home_sessions,
    COUNT(DISTINCT CASE WHEN landing_url = '/lander-1' THEN website_session_id ELSE NULL END) AS lander1_sessions
FROM landing_urls 
GROUP BY 1,2;


-- Conversion Funnel Analysis 

/* Funnel: lander-1, products, fuzzy, cart, shipping, billing, thankyou */

-- Step 1
-- Flagging all the website_sessions with each page viewed
SELECT
	S.website_session_id,
    P.pageview_url,
    P.created_at,
    CASE WHEN P.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN P.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page,
    CASE WHEN P.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN P.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN P.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN P.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
FROM website_sessions AS S
	LEFT JOIN website_pageviews P 
    ON S.website_session_id = P.website_session_id
WHERE S.utm_source = 'gsearch' 
AND S.utm_campaign = 'nonbrand'
AND P.created_at > '2012-08-05' 
AND P.created_at < '2012-09-05'
ORDER BY 1,3;

-- Step 2
-- Using the step 1 as subquery, identifying the customer journey
-- Now Grouping by session_id to understand each customers journey

CREATE TEMPORARY TABLE session_level_funnel
SELECT
	website_session_id,
    MAX(products_page) AS products_page,
    MAX(fuzzy_page) AS fuzzy_page,
    MAX(cart_page) AS cart_page,
    MAX(shipping_page) AS shipping_page,
    MAX(billing_page) AS billing_page ,
    MAX(thankyou_page) AS thankyou_page
FROM (    -- Sub Query here from step 1
SELECT
	S.website_session_id,
    P.pageview_url,
    P.created_at,
    CASE WHEN P.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
    CASE WHEN P.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS fuzzy_page,
    CASE WHEN P.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN P.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
    CASE WHEN P.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
    CASE WHEN P.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page

FROM website_sessions AS S
	LEFT JOIN website_pageviews P ON S.website_session_id = P.website_session_id

WHERE S.utm_source = 'gsearch' 
AND S.utm_campaign = 'nonbrand'
AND P.created_at > '2012-08-05' 
AND P.created_at < '2012-09-05'
ORDER BY 1,3) AS pageview_level
GROUP BY 1;

SELECT * FROM session_level_funnel;

-- Step3 funnel flow
SELECT
	COUNT(website_session_id) AS sessions,
    SUM(products_page ) AS to_products,
    SUM(fuzzy_page) AS to_fuzzy,
    SUM(cart_page) AS to_cart,
    SUM(shipping_page) AS to_shipping,
    SUM(billing_page) AS to_billing,
    SUM(thankyou_page) AS to_thankyou
FROM session_level_funnel;

-- Step 4 Click rate from one page to another
SELECT
    SUM(products_page)/COUNT(website_session_id) AS lander_rate,
    SUM(fuzzy_page)/SUM(products_page) AS products_rate,
    SUM(cart_page)/SUM(fuzzy_page) AS fuzzy_rate,
    SUM(shipping_page)/SUM(cart_page) AS cart_rate,
    SUM(billing_page)/SUM(shipping_page) AS shipping_rate,
    SUM(thankyou_page)/SUM(billing_page) AS thankyou_rate
FROM session_level_funnel;


-- /billing-2 Was introduced, did final billing % increase for the new funnel ?
-- A/B test was run against billing and billing-2 for all the traffic
-- Now lets look at the funnels of both the billing sessions

-- First setp, when was the first live session of the /billing-2
SELECT
	MIN(created_at),
	MIN(website_session_id),
    MIN(website_pageview_id)
FROM website_pageviews 
WHERE pageview_url = '/billing-2';

-- website_session_id : '25325', 
-- website_pageview_id : '53550' for the first /billing-2 session

-- Step 2
-- Now identfying the sessions which went till billing and billing 2

CREATE TEMPORARY TABLE billing
SELECT
	website_session_id,
    pageview_url
FROM website_pageviews
WHERE website_pageview_id >= 53550
AND created_at < '2012-11-10'
AND pageview_url in ('/billing', '/billing-2')
ORDER BY 1;

SELECT * FROM billing;

-- Joing the oders with billing sessions

SELECT 
	B.website_session_id,
    B.pageview_url,
    O.order_id
FROM billing AS B 
	LEFT JOIN ORDERS AS O ON B.website_session_id = O.website_session_id
ORDER BY 1;


-- Left Joing to oders and calculating the conversion rate
SELECT 
	B.pageview_url,
	COUNT(DISTINCT B.website_session_id) AS billing_sessions,
    COUNT(DISTINCT O.order_id) AS orders,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT B.website_session_id) AS conversion_rate
FROM billing AS B 
	LEFT JOIN ORDERS AS O ON B.website_session_id = O.website_session_id
GROUP BY 1;







