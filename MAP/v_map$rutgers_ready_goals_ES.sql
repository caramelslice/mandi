USE KIPP_NJ
GO

ALTER VIEW MAP$rutgers_ready_goals#ES AS
SELECT map.studentid
      ,map.grade_level
      ,map.school
      ,map.schoolid
      ,map.year
      ,map.lastfirst
      ,map.measurementscale
      ,map.testritscore AS baseline_rit
      ,map.termname AS baseline_term
      ,map.testpercentile AS baseline_percentile
      ,CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) AS keep_up_goal
      ,CASE 
         --bottom quartile
         WHEN CAST(map.testpercentile AS INT) > 0   AND CAST(map.testpercentile AS INT) < 25 
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 1.5, 0)
         --2nd quartile
         WHEN CAST(map.testpercentile AS INT) >= 25 AND CAST(map.testpercentile AS INT) < 50 
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 1.5, 0)
         --3rd quartile
         WHEN CAST(map.testpercentile AS INT) >= 50 AND CAST(map.testpercentile AS INT) < 75 
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 1.25, 0)
         --top quartile
         WHEN CAST(map.testpercentile AS INT) >= 75 AND CAST(map.testpercentile AS INT) < 100
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 1.25, 0)
       END AS rutgers_ready_goal
  FROM KIPP_NJ..MAP$baseline_composite map
  WHERE map.year = 2013
    AND map.grade_level < 4

UNION ALL

SELECT map.studentid
      ,map.grade_level
      ,map.school
      ,map.schoolid
      ,map.year
      ,map.lastfirst
      ,map.measurementscale
      ,map.testritscore AS baseline_rit
      ,map.termname AS baseline_term
      ,map.testpercentile AS baseline_percentile
      ,CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) AS keep_up_goal
      ,CASE 
         --bottom quartile
         WHEN CAST(map.testpercentile AS INT) > 0   AND CAST(map.testpercentile AS INT) < 25 
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 2.0, 0)
         --2nd quartile
         WHEN CAST(map.testpercentile AS INT) >= 25 AND CAST(map.testpercentile AS INT) < 50 
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 1.75, 0)
         --3rd quartile
         WHEN CAST(map.testpercentile AS INT) >= 50 AND CAST(map.testpercentile AS INT) < 75 
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 1.5, 0)
         --top quartile
         WHEN CAST(map.testpercentile AS INT) >= 75 AND CAST(map.testpercentile AS INT) < 100
           THEN ROUND(CAST(map.typical_growth_fallorspring_to_spring AS FLOAT) * 1.25, 0)
       END AS rutgers_ready_goal
  FROM KIPP_NJ..MAP$baseline_composite map
  WHERE map.year = 2013
    AND map.grade_level = 4
    
