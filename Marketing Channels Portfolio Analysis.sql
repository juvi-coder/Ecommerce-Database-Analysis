-- Analyzing Channel Portfolios 

USE mavenfuzzyfactory;

SELECT DISTINCT
	utm_source,
    utm_campaign
FROM website_sessions;

-- A second search channel was introduced 
-- on August 22, 2012 non brand bsearch
-- weekly trended session volume of bsearch
-- and comparing it with gsearch non brand
SELECT
	WEEK(W.created_at) AS week,
    MIN(DATE(W.created_at)) AS week_start_date,
    COUNT(DISTINCT W.website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'gsearch' THEN W.website_session_id ELSE NULL END) AS gsearch_nonbrand_sessions,
    COUNT(DISTINCT CASE WHEN W.utm_source = 'bsearch' THEN W.website_session_id ELSE NULL END) AS bsearch_sessions
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id 
WHERE 
	W.created_at >  '2012-08-22' 
AND W.created_at < '2012-11-29'
AND utm_campaign = 'nonbrand'
GROUP BY 1;

-- Looking into the mobile sessions for the same

SELECT
	utm_source,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS '% of sessions from mobile'
FROM website_sessions
WHERE utm_campaign = 'nonbrand' 
AND created_at > '2012-08-22' 
AND created_at < '2012-11-30'
AND utm_source in ('gsearch', 'bsearch')
GROUP BY 1;

-- non brand conversion rates
-- slice the data by device types

SELECT
	W.device_type,
    W.utm_source,
    COUNT(W.website_session_id) AS sessions,
    COUNT(O.order_id) AS orders,
    COUNT(O.order_id)/COUNT(W.website_session_id)  AS conversion_rate
FROM website_sessions AS W
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id 
WHERE W.created_at > '2012-08-22' 
AND W.created_at < '2012-09-19' 
AND W.utm_campaign = 'nonbrand'
AND W.utm_source in ('gsearch', 'bsearch')
GROUP BY 1,2
ORDER BY 1;


-- Channel Portfolio Trends

SELECT
	WEEK(created_at) AS WEEK,
    MIN(DATE(created_at)) as week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS gsearch_mobile,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS bsearch_mobile,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'mobile' THEN website_session_id ELSE NULL END) AS 'Bsearchmobile % of Gsearchmobile',
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS gsearch_desktop,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS bsearch_desktop,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND device_type = 'desktop' THEN website_session_id ELSE NULL END) AS 'Bsearchdesktop % of Gsearchdesktop'
FROM website_sessions
WHERE utm_source IN ('gsearch', 'bsearch') 
AND utm_campaign = 'nonbrand'
AND created_at >= '2012-11-04' 
AND created_at < '2012-12-22'
GROUP BY 1;

-- Analyzing Direct, Brand Driven Traffic
SELECT
	MONTH(created_at),
    MIN(DATE(created_at)) AS month_start_date,
    COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_source IS NULL THEN website_session_id ELSE NULL END) AS organic_search,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) AS direct_typein,
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END) AS paid_brand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS paid_nonbrand,
    COUNT(DISTINCT CASE WHEN http_referer IS NOT NULL AND utm_campaign IS NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS organic_pct_of_nonbrand,
    COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS 'Direct_pct_nonbrand',
	COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN utm_campaign = 'nonbrand' THEN website_session_id ELSE NULL END) AS 'brand_pct_nonbrand'
FROM website_sessions
WHERE created_at < '2012-12-23'
GROUP BY 1;











