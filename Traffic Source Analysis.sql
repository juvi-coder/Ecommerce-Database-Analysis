USE mavenfuzzyfactory;

-- Finding top traffic sources, till April 12, 2022

SELECT
	  utm_source,
      utm_campaign,
      http_referer, 
      COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

/* gsearch, nonbrand camapign is the most important channel to focous on */


SELECT
	  W.utm_source,
      W.utm_campaign,
      W.http_referer, 
      COUNT(W.website_session_id) AS sessions,
      COUNT(O.order_id) AS orders,
      (COUNT(O.order_id)/COUNT(W.website_session_id))*100 AS conversion_rate -- gives what percentage of sessions reslut in orders
FROM website_sessions as W LEFT JOIN 
	 orders AS O ON W.website_session_id = O.website_session_id
WHERE W.created_at < '2012-04-14'
GROUP BY 1, 2, 3
ORDER BY 4 DESC;

/* Order conversion rate for the Gsearch non brand traffic channel is aroud 2.875%.
It is way below the threshold of 4% to make the numbers work */


-- Gsearch non brand trend analysis [WEEK]
-- Bid down on 2012-04-15 because of the low conversion rate

SELECT
	YEAR(created_at) AS year,
	WEEK(created_at) AS week,
	MIN(DATE(created_at)) AS start_of_week,
    COUNT(website_session_id) AS sessions
FROM website_sessions
WHERE utm_source = 'gsearch' AND 
utm_campaign = 'nonbrand' AND
created_at < '2012-05-10'
GROUP BY 1,2;

-- Traffic decreased from a high of 1152 sessions to 621 on 2012-04-15 [Week 16]
-- Traffic remained stabled for 2 weeks since bid down, went to all time low by week 17


-- conversion rates across device types

SELECT
    W.device_type,
    COUNT(W.website_session_id) AS website_sessions,
    COUNT(O.order_id) AS orders,
    COUNT(O.order_id)/COUNT(W.website_session_id) AS conversion_rate
FROM website_sessions AS W LEFT JOIN 
	ORDERS AS O ON w.website_session_id = O.website_session_id
WHERE W.created_at < '2012-05-11'
AND W.utm_source = 'gsearch' AND 
W.utm_campaign = 'nonbrand'
GROUP BY 1
ORDER BY 4 DESC;

-- We've got device type sessions orders and we have conversion rate and so what's interesting here is the conversion rate for your desktop traffic is about 3.7 %. 
-- 3.7% of sessions matriculate to a revenue generating order for the business for mobile traffic it's less than 1%.


-- Bid up Gseach Non Brand computer marketing campaign 
-- Lets look at weekly trends of traffic at with device type

SELECT
	YEAR(created_at) AS year,
    MONTH(created_at) AS month,
    WEEK(created_at) AS week,
	MIN(DATE(created_at)) AS week_start_date,
    COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-04-15' AND '2012-06-09'
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 1,2,3;

-- Bid changes that were made for desktop, resulted  a pop in desktop traffic after the bid up and we didn't see any kind of a pop for mobile.  
-- We can pretty confidently say that those bid changes did help us create this additional surge in desktop volume.













