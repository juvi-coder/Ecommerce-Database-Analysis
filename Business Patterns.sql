-- Monthly Patterns

USE mavenfuzzyfactory;

-- Monthly Trend Analysis of Traffic and Orders

SELECT
	YEAR(W.created_at),
    MONTH(W.created_at),
    COUNT(DISTINCT W.website_session_id) AS sessions,
    COUNT(DISTINCT O.order_id) AS orders,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT W.website_session_id) AS conversion_rate
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE W.created_at < '2013-01-02'
GROUP BY 1,2 
ORDER BY 1,2;


-- Weekly Traffic and Orders patters

SELECT
	WEEK(W.created_at) AS weeks,
    MIN(DATE(W.created_at)) AS start_of_week,
    COUNT(DISTINCT W.website_session_id) AS sessions,
    COUNT(DISTINCT O.order_id) AS orders,
    COUNT(DISTINCT O.order_id)/COUNT(DISTINCT W.website_session_id) AS conversion_rate
FROM website_sessions AS W 
	LEFT JOIN orders AS O ON W.website_session_id = O.website_session_id
WHERE W.created_at < '2013-01-02'
GROUP BY 1
ORDER BY 1;




-- How are  website sessions throught day and day of the week?
SELECT
	Hour,
    ROUND(AVG(CASE WHEN wkday = 0 THEN website_sessions ELSE NULL END),1) AS monday_sessions,
    ROUND(AVG(CASE WHEN wkday = 1 THEN website_sessions ELSE NULL END),1) AS tuesday_sessions,
    ROUND(AVG(CASE WHEN wkday = 2 THEN website_sessions ELSE NULL END),1) AS wednesday_sessions,
	ROUND(AVG(CASE WHEN wkday = 3 THEN website_sessions ELSE NULL END),1) AS thursday_sessions,
    ROUND(AVG(CASE WHEN wkday = 4 THEN website_sessions ELSE NULL END),1) AS friday_sessions,
    ROUND(AVG(CASE WHEN wkday = 5 THEN website_sessions ELSE NULL END),1) AS saturday_sessions,
    ROUND(AVG(CASE WHEN wkday = 6 THEN website_sessions ELSE NULL END),1) AS sunday_sessions
FROM  (
SELECT
	DATE(created_at) AS created_at,
	WEEKDAY(created_at) AS wkday,
    HOUR(created_at) AS Hour,
	COUNT(DISTINCT website_session_id) AS website_sessions
FROM website_sessions
WHERE created_at BETWEEN'2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3) AS average_sessions
GROUP BY 1 ORDER BY 1;
