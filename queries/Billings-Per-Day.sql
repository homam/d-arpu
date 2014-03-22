-- Per Day:
-- Visits, Subscribers
-- Per Day After Subscription;
---- Accumulative Billings till that date, Active Subscriber


-- Billing Per Device

-- (DateFrom, BillingDuration) -> (Country, SuperCamaignId, CampaignId, Service, Category, Visits, Subscribers, Active, Billings)
-- Active and Billings: Up to DateFrom + Duration
-- Service: Only for subscribers

-- Paramters:

USE Mobitrans;

DECLARE @DateFrom DATETIME = '{FROM_DATE}' -- 2014-02-01
DECLARE @BillingDuration INT = {BILLING_DURATION} -- 1

DECLARE @DateTo DATETIME = DATEADD(d, 1, @DateFrom)
DECLARE @BillingUpToDate DATETIME = DATEADD(d, @BillingDuration, @DateTo)

------ Query -----
;
WITH 
Visits AS (
	SELECT 
		V.VID, V.country, V.Cid, S.Service AS ServiceId, V.UA_Id, U.Wurfl_Id, S.SubscriberId, Active = 
			CASE
				WHEN (S.SubscriberId IS NULL) OR ((S.Active = 0) AND (S.UnsubscribedOn < @BillingUpToDate) AND (S.SubscribedOn >= @DateFrom AND S.SubscribedOn <= @DateTo)) THEN 0
				ELSE 1
			End           
	FROM dbo.Wap_Visits V WITH (NOLOCK) 
		LEFT JOIN dbo.Web_Subscriptions W WITH (NOLOCK) ON W.VisitId = V.VID AND W.Source = 1
		left JOIN Subscribers S WITH (NOLOCK) ON S.SubscriberId = W.SubscriberId
		LEFT JOIN dbo.Wap_Visits_Ua U WITH (NOLOCK) ON U.UA_Id = V.UA_Id
	WHERE 
		(V.Date_Created > @DateFrom AND V.Date_Created < @DateTo)

),
------------------------------
-- Traffic, Conversion --
------------------------------
iOS AS ( 
	SELECT * FROM dbo.FN_WURFL_FIND_Children('apple_generic')
),
Android AS (
	SELECT * FROM dbo.FN_WURFL_FIND_Children('generic_android')
),
CategorizedVisits AS (
	SELECT
		V.*, Category = 
			CASE 
				WHEN  Android.Wurfl_Id IS NOT NULL THEN 'Android'
				WHEN  iOS.Wurfl_Id IS NOT NULL THEN 'iOS'
				ELSE 'Rest'
			END
	FROM  Visits V
	LEFT JOIN iOS ON V.Wurfl_Id = iOS.Wurfl_Id
	LEFT JOIN Android ON V.Wurfl_Id = Android.Wurfl_Id
),
Conversion_Results AS (
	SELECT
		country, Category, Cid, ServiceId, COUNT(*) AS Visits, COUNT(SubscriberId) AS Subscribers, SUM(Active) AS Active
	FROM CategorizedVisits V
		GROUP BY country, Category, Cid, ServiceId
),
Conversion AS (
	SELECT C.CountryName, R.Category, R.Cid, R.ServiceId, R.Visits, R.Subscribers, R.Active
	FROM Conversion_Results R
	INNER JOIN dbo.Countries C ON C.CountryId = R.country
),
------------------------------
-- Billings Reports --
------------------------------
CategorizedSubscribers AS (
	SELECT
		V.*, Category = 
			CASE 
				WHEN  Android.Wurfl_Id IS NOT NULL THEN 'Android'
				WHEN  iOS.Wurfl_Id IS NOT NULL THEN 'iOS'
				ELSE 'Rest'
			END
	FROM Visits V
	LEFT JOIN iOS ON V.Wurfl_Id = iOS.Wurfl_Id 
	LEFT JOIN Android ON V.Wurfl_Id = Android.Wurfl_Id
	WHERE SubscriberId IS NOT NULL
),
CategorizedBillings AS (
	SELECT C.*, B.Subscriberid AS BillingSubscriberId
	FROM CategorizedSubscribers AS C
	LEFT JOIN dbo.Billings B WITH (NOLOCK) ON B.Subscriberid = C.SubscriberId AND B.Billed_date > @DateFrom AND B.Billed_date < @BillingUpToDate
),
Billing_Results AS (
	SELECT Country, Category, Cid, ServiceId, COUNT(DISTINCT VID) AS Visits, COUNT(DISTINCT SubscriberId) AS Subscribers, COUNT(BillingSubscriberId) AS Billings
	FROM CategorizedBillings
	GROUP BY country, Category, Cid, ServiceId
),
Billing AS(
	SELECT C.CountryName, R.Category, R.Cid, R.ServiceId, R.Visits, R.Subscribers, R.Billings
	FROM Billing_Results R
	INNER JOIN dbo.Countries C ON C.CountryId = R.country
)

SELECT C.CountryName AS Country,  RC.SuperCampaignId, C.Cid AS CampaignId, S.Srvc_Describtion AS [Service], C.Category, C.Visits, C.Subscribers, C.Active, (ISNULL(B.Billings,0)) AS Billings
FROM Conversion C 
LEFT JOIN Billing B ON C.CountryName = B.CountryName AND C.Category = B.Category AND C.Cid = B.Cid AND C.ServiceId = B.ServiceId
LEFT JOIN dbo.RuleEngine_Campaigns RC ON RC.id = C.Cid
LEFT JOIN dbo.Services S WITH (NOLOCK) ON S.SrvcId = C.ServiceId
ORDER BY C.CountryName, RC.SuperCampaignId, C.Cid, C.Category