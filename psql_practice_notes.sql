/* ===========================================================
   POSTGRESQL PRACTICE – DATA ANALYSIS & SEGMENTATION
   This script includes real-world PostgreSQL queries used for:

   ✅ Exploring raw data
   ✅ Understanding concept and city performance
   ✅ Revenue analysis
   ✅ Customer behavior classification (EB Score)
   ✅ Season-based analysis
   ✅ Persona creation (sales_level_based)
   ✅ Customer segmentation
   ✅ Expected revenue estimation

   Designed as a practical learning resource for
   Data Engineering / Data Analytics workflows.
   =========================================================== */


---------------------------------------------------------------
-- MODULE 01
-- PURPOSE: Preview the first 10 records in the dataset
-- WHY: Helps validate that the dataset was loaded correctly
-- and understand the column structure before further analysis.
---------------------------------------------------------------
SELECT * FROM public.practice_data pd LIMIT 10;


---------------------------------------------------------------
-- MODULE 02
-- PURPOSE: Find all unique hotel concepts in the dataset
-- WHY: Identifies the different product offerings (e.g.,
-- all-inclusive, half-board) which will be used in segmentation.
---------------------------------------------------------------
SELECT DISTINCT concept_name
FROM public.practice_data pd;


---------------------------------------------------------------
-- MODULE 03
-- PURPOSE: Count how many sales were made for each concept
-- WHY: Helps understand which hotel concepts are most preferred
-- by customers in terms of booking volume.
---------------------------------------------------------------
SELECT concept_name,
       COUNT(*)
FROM public.practice_data pd
GROUP BY concept_name;


---------------------------------------------------------------
-- MODULE 04
-- PURPOSE: Calculate total revenue per city
-- WHY: Shows which cities generate the highest income, useful
-- for revenue optimization and business strategy.
---------------------------------------------------------------
SELECT sale_city_name,
       SUM(price)
FROM public.practice_data pd
GROUP BY sale_city_name;


---------------------------------------------------------------
-- MODULE 05
-- PURPOSE: Calculate total revenue per hotel concept
-- WHY: Helps compare financial performance across concepts,
-- not just booking quantity.
---------------------------------------------------------------
SELECT concept_name,
       SUM(price)
FROM public.practice_data pd
GROUP BY concept_name;


---------------------------------------------------------------
-- MODULE 06
-- PURPOSE: Calculate average price per city
-- WHY: Shows pricing positioning of each city (high-end vs budget)
---------------------------------------------------------------
SELECT sale_city_name,
       AVG(price)
FROM public.practice_data pd
GROUP BY sale_city_name;


---------------------------------------------------------------
-- MODULE 07
-- PURPOSE: Calculate average price per concept
-- WHY: Identifies which concepts are priced higher and may target
-- different customer segments.
---------------------------------------------------------------
SELECT concept_name,
       AVG(price)
FROM public.practice_data pd
GROUP BY concept_name;


---------------------------------------------------------------
-- MODULE 08
-- PURPOSE: Calculate average price based on city + concept
-- WHY: More detailed pricing analysis combining location and product.
---------------------------------------------------------------
SELECT sale_city_name,
       concept_name,
       AVG(price)
FROM public.practice_data pd
GROUP BY sale_city_name, concept_name;


---------------------------------------------------------------
-- MODULE 09
-- PURPOSE: Classify customers based on booking behavior (EB Score)
-- METHOD:
--   <7 days   → Last Minuters
--   7–30 days → Potential Planners
--   30–90 days→ Planners
--   >90 days  → Early Bookers
-- WHY: Common segmentation used in travel industry to understand
-- planning habits and revenue patterns.
---------------------------------------------------------------
SELECT sale_city_name,
       concept_name,
       CASE
           WHEN sale_checkin_day_diff < 7 THEN 'Last Minuters'
           WHEN sale_checkin_day_diff BETWEEN 7 AND 30 THEN 'Potential Planners'
           WHEN sale_checkin_day_diff BETWEEN 30 AND 90 THEN 'Planners'
           ELSE 'Early Bookers'
       END AS eb_score,
       AVG(price),
       COUNT(*)
FROM public.practice_data pd
GROUP BY sale_city_name, concept_name, eb_score;


---------------------------------------------------------------
-- MODULE 10
-- PURPOSE: Analyze pricing based on seasonality
-- WHY: Season strongly affects hotel pricing and demand patterns.
---------------------------------------------------------------
SELECT sale_city_name,
       concept_name,
       seasons,
       AVG(price),
       COUNT(*)
FROM public.practice_data pd
GROUP BY sale_city_name, concept_name, seasons;


---------------------------------------------------------------
-- MODULE 11
-- PURPOSE: Analyze pricing based on check-in day category
-- (weekday/weekend behavior or business/leisure insights)
---------------------------------------------------------------
SELECT sale_city_name,
       concept_name,
       cin_day,
       AVG(price),
       COUNT(*)
FROM public.practice_data pd
GROUP BY sale_city_name, concept_name, cin_day;


---------------------------------------------------------------
-- MODULE 12
-- PURPOSE: Create a summarized SALES table
-- WHY: Used for further segmentation and revenue modeling
---------------------------------------------------------------
SELECT sale_city_name,
       concept_name,
       CASE
           WHEN sale_checkin_day_diff < 7 THEN 'Last Minuters'
           WHEN sale_checkin_day_diff BETWEEN 7 AND 30 THEN 'Potential Planners'
           WHEN sale_checkin_day_diff BETWEEN 30 AND 90 THEN 'Planners'
           ELSE 'Early Bookers'
       END AS eb_score,
       AVG(price),
       COUNT(*)
INTO public.sales
FROM public.practice_data pd
GROUP BY sale_city_name,
         concept_name,
         CASE
           WHEN sale_checkin_day_diff < 7 THEN 'Last Minuters'
           WHEN sale_checkin_day_diff BETWEEN 7 AND 30 THEN 'Potential Planners'
           WHEN sale_checkin_day_diff BETWEEN 30 AND 90 THEN 'Planners'
           ELSE 'Early Bookers'
         END;

SELECT * FROM public.sales;


---------------------------------------------------------------
-- MODULE 13
-- PURPOSE: Create a city + concept + season summary table
-- and sort by average price
---------------------------------------------------------------
SELECT sale_city_name,
       concept_name,
       seasons,
       AVG(price) AS mean_price,
       COUNT(*) AS count_1
INTO public.sales_ccs
FROM public.practice_data pd
GROUP BY sale_city_name, concept_name, seasons
ORDER BY mean_price;

SELECT * FROM public.sales_ccs;


---------------------------------------------------------------
-- MODULE 14
-- PURPOSE: Create persona variable (sales_level_based)
-- STRUCTURE:
--   city_concept_season
-- WHY: Used to define unique customer/product groups
---------------------------------------------------------------
SELECT *,
       sale_city_name || '_' || concept_name || '_' || seasons AS sales_level_based
INTO public.sales_level_based
FROM public.sales_ccs sc;

SELECT * FROM public.sales_level_based slb;


---------------------------------------------------------------
-- MODULE 15
-- PURPOSE: Create segment table based on price ranges
---------------------------------------------------------------
SELECT *,
CASE 
    WHEN price < 30 THEN 'Low'
    WHEN price BETWEEN 30 AND 60 THEN 'Middle-low'
    WHEN price BETWEEN 60 AND 90 THEN 'Middle-high'
    ELSE 'High'
END AS segments
INTO public.segments
FROM public.practice_data pd;

SELECT * FROM public.segments;


---------------------------------------------------------------
-- MODULE 16
-- PURPOSE: Generate descriptive statistics per segment
---------------------------------------------------------------
SELECT segments,
       AVG(price),
       SUM(price),
       MAX(price),
       MIN(price)
FROM public.segments
GROUP BY segments;


---------------------------------------------------------------
-- MODULE 17
-- PURPOSE: Estimate expected revenue for:
--   City: Antalya
--   Concept: All Inclusive
--   Season: High
-- METHOD: Weighted expected revenue =
--   segment_avg_price * segment_share
---------------------------------------------------------------
SELECT segments,
       AVG(price) AS avg_price,
       COUNT(*) * 1.0 / SUM(COUNT(*)) OVER() AS segment_share,
       AVG(price) * (COUNT(*) * 1.0 / SUM(COUNT(*)) OVER()) AS weighted_expected_revenue
FROM public.segments
WHERE sale_city_name = 'Antalya'
  AND concept_name = 'Herşey Dahil'
  AND seasons = 'High'
GROUP BY segments;


---------------------------------------------------------------
-- MODULE 18
-- PURPOSE: Determine which segment a customer belongs to
-- Example:
-- Customer traveling to Girne
-- Half-board concept
-- Low season
---------------------------------------------------------------
SELECT segments,
       AVG(price),
       SUM(price),
       COUNT(*) * 1.0 / SUM(COUNT(*)) OVER() AS segment_share
FROM public.segments
WHERE sale_city_name = 'Girne'
  AND concept_name = 'Yarım Pansiyon'
  AND seasons = 'Low'
GROUP BY segments;
