USE KIPP_NJ
GO

ALTER VIEW MAP$rutgers_ready_student_goals AS
WITH stu_roster AS( 
  SELECT c.studentid
        ,c.schoolid
        ,c.lastfirst
        ,c.grade_level
        ,c.year
  FROM COHORT$comprehensive_long#static c WITH(NOLOCK)
  WHERE c.year >= 2012
    AND c.schoolid != 999999
    AND c.rn = 1
    --AND c.studentid = 2877
 )
   
,math_read AS (
  SELECT 'Mathematics' AS measurementscale
        ,NULL AS alt_measurementscale
  UNION
  SELECT 'Reading'
        ,NULL AS alt_measurementscale
 )

,sci_lang AS (
  SELECT 'Science - General Science' AS measurementscale
        ,'General Science' AS alt_measurementscale
  UNION 
  SELECT 'Language' AS measurementscale
        ,'Language Usage' AS alt_measurementscale
 )

--MATH AND READING FOR MS/HS
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
    (      
     SELECT stu_roster.*
           ,math_read.measurementscale
           ,map_base.testritscore AS baseline_rit
           ,map_base.testpercentile AS baseline_percentile
           ,map_base.termname AS derived_from                 
           ,COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_goal
           ,map_base.testritscore + COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_rit
           ,CASE
             WHEN rr_goals.RIT_target IS NOT NULL THEN ROUND(MIN(rr_goals.RIT_target), 0) - CAST(map_base.testritscore AS FLOAT)
             --bottom quartile
             WHEN rr_goals.RIT_target IS NULL AND CAST(status_norms.percentile AS INT) > 0   AND CAST(status_norms.percentile AS INT) < 25 THEN ROUND(CAST(norm.r22 AS FLOAT) * 2.0, 0)
             --2nd quartile
             WHEN rr_goals.RIT_target IS NULL AND CAST(status_norms.percentile AS INT) >= 25 AND CAST(status_norms.percentile AS INT) < 50 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.75, 0)
             --3rd quartile
             WHEN rr_goals.RIT_target IS NULL AND CAST(status_norms.percentile AS INT) >= 50 AND CAST(status_norms.percentile AS INT) < 75 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
             --top quartile
             WHEN rr_goals.RIT_target IS NULL AND CAST(status_norms.percentile AS INT) >= 75 AND CAST(status_norms.percentile AS INT) < 100 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
             ELSE NULL
            END AS rutgers_ready_goal                 
     FROM stu_roster
     JOIN math_read
       ON 1=1      
     --baseline (composite of Spring and Fall; pick best)
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_base WITH(NOLOCK)
       ON stu_roster.studentid = map_base.studentid 
      AND stu_roster.year = map_base.year
      AND math_read.measurementscale = map_base.measurementscale
     --RR goals (generated by R script)
     LEFT OUTER JOIN MAP$rutgers_ready_goals rr_goals WITH(NOLOCK)  
       ON stu_roster.studentid = rr_goals.studentid 
      AND stu_roster.year = rr_goals.academic_year
      AND rr_goals.measurementscale = map_base.MeasurementScale
      AND ROUND(rr_goals.RIT_target, 0) > ROUND(map_base.testritscore, 0)
      AND ROUND(rr_goals.RIT_target - map_base.testritscore, 0) > map_base.typical_growth_fallorspring_to_spring
     LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data_extended#2011 norm WITH(NOLOCK)
       ON math_read.measurementscale = norm.subject
      AND map_base.testritscore = norm.startrit
      AND stu_roster.grade_level-1 = norm.startgrade
     LEFT OUTER JOIN KIPP_NJ..MAP$norm_table#2011 status_norms
        ON math_read.measurementscale = status_norms.measurementscale
        AND map_base.testritscore = status_norms.RIT
        AND (
          (stu_roster.grade_level > 0 AND stu_roster.grade_level-1 = status_norms.grade AND status_norms.fallwinterspring='Spring') OR
          (stu_roster.grade_level = 0 AND stu_roster.grade_level = status_norms.grade AND status_norms.fallwinterspring='Fall')
        )
     WHERE stu_roster.grade_level >= 5      
     GROUP BY stu_roster.studentid
             ,stu_roster.schoolid
             ,stu_roster.lastfirst
             ,stu_roster.grade_level
             ,stu_roster.year
             ,math_read.measurementscale
             ,map_base.testritscore
             ,map_base.testpercentile
             ,status_norms.percentile
             ,map_base.termname
             ,map_base.typical_growth_fallorspring_to_spring
             ,rr_goals.RIT_target
             ,norm.R22
    ) sub 


UNION ALL


--SCIENCE AND LANGUAGE FOR 4-12
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
    (
     SELECT stu_roster.*
           ,sci_lang.measurementscale
           ,map_base.testritscore AS baseline_rit
           ,map_base.testpercentile AS baseline_percentile
           ,map_base.termname AS derived_from                      
           ,COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_goal
           ,map_base.testritscore + COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_rit
           ,CASE 
             --bottom quartile
             WHEN CAST(status_norms.percentile AS INT) > 0   AND CAST(status_norms.percentile AS INT) < 25 THEN ROUND(CAST(norm.r22 AS FLOAT) * 2.0, 0)
             --2nd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 25 AND CAST(status_norms.percentile AS INT) < 50 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.75, 0)
             --3rd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 50 AND CAST(status_norms.percentile AS INT) < 75 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
             --top quartile
             WHEN CAST(status_norms.percentile AS INT) >= 75 AND CAST(status_norms.percentile AS INT) < 100 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
            END AS rutgers_ready_goal       
     FROM stu_roster
     JOIN sci_lang
       ON 1=1            
     --baseline (composite of Spring and Fall; pick best)
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_base WITH(NOLOCK)
       ON stu_roster.studentid = map_base.studentid 
      AND stu_roster.year = map_base.year
      AND sci_lang.measurementscale = REPLACE(map_base.measurementscale, ' Usage', '')
     LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data_extended#2011 norm WITH(NOLOCK)
      ON sci_lang.alt_measurementscale = norm.subject
      AND map_base.testritscore = norm.startrit
      AND stu_roster.grade_level - 1 = norm.startgrade
     LEFT OUTER JOIN KIPP_NJ..MAP$norm_table#2011 status_norms
        ON map_base.measurementscale = status_norms.measurementscale
        AND map_base.testritscore = status_norms.RIT
        AND (
          (stu_roster.grade_level > 0 AND stu_roster.grade_level-1 = status_norms.grade AND status_norms.fallwinterspring='Spring') OR
          (stu_roster.grade_level = 0 AND stu_roster.grade_level = status_norms.grade AND status_norms.fallwinterspring='Fall')
        )
     WHERE stu_roster.grade_level >= 4       
    ) sub


UNION ALL


--SCIENCE AND LANGUAGE FOR K-3
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
    (
     SELECT stu_roster.*
           ,sci_lang.measurementscale
           ,map_base.testritscore AS baseline_rit
           ,map_base.testpercentile AS baseline_percentile
           ,map_base.termname AS derived_from           
           ,COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_goal
           ,map_base.testritscore + COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_rit
           ,CASE 
             --bottom quartile
             WHEN CAST(status_norms.percentile AS INT) > 0   AND CAST(status_norms.percentile AS INT) < 25 
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
             --2nd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 25 AND CAST(status_norms.percentile AS INT) < 50 
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
             --3rd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 50 AND CAST(status_norms.percentile AS INT) < 75 
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
             --top quartile
             WHEN CAST(status_norms.percentile AS INT) >= 75 AND CAST(status_norms.percentile AS INT) < 100
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
             --K needs fall to spring norm
             --bottom quartile
             WHEN CAST(status_norms.percentile AS INT) > 0   AND CAST(status_norms.percentile AS INT) < 25 
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.5, 0)
             --2nd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 25 AND CAST(status_norms.percentile AS INT) < 50 
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.5, 0)
             --3rd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 50 AND CAST(status_norms.percentile AS INT) < 75 
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.25, 0)
             --top quartile
             WHEN CAST(status_norms.percentile AS INT) >= 75 AND CAST(status_norms.percentile AS INT) < 100
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.25, 0)
            END AS rutgers_ready_goal
     FROM stu_roster
     JOIN sci_lang
       ON 1=1      
     --baseline (composite of Spring and Fall; pick best)
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_base WITH(NOLOCK)
       ON stu_roster.studentid = map_base.studentid 
      AND stu_roster.year = map_base.year
      AND sci_lang.measurementscale = REPLACE(map_base.measurementscale, ' Usage', '')
     LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data_extended#2011 norm WITH(NOLOCK)
      ON sci_lang.alt_measurementscale = norm.subject
      AND map_base.testritscore = norm.startrit
      AND (
        (stu_roster.grade_level > 0 AND stu_roster.grade_level-1 = norm.startgrade) OR
        (stu_roster.grade_level = 0 AND stu_roster.grade_level = norm.startgrade)
      )
      LEFT OUTER JOIN KIPP_NJ..MAP$norm_table#2011 status_norms
        ON map_base.measurementscale = status_norms.measurementscale
        AND map_base.testritscore = status_norms.RIT
        AND (
          (stu_roster.grade_level > 0 AND stu_roster.grade_level-1 = status_norms.grade AND status_norms.fallwinterspring='Spring') OR
          (stu_roster.grade_level = 0 AND stu_roster.grade_level = status_norms.grade AND status_norms.fallwinterspring='Fall')
        )
     WHERE stu_roster.grade_level < 4
    ) sub


UNION ALL


--MATH AND READING FOR ES K-3
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
    (
     SELECT stu_roster.*
           ,math_read.measurementscale
           ,map_base.testritscore AS baseline_rit
           ,map_base.testpercentile AS baseline_percentile
           ,map_base.termname AS derived_from           
           ,CASE WHEN stu_roster.grade_level = 0 THEN norm.r42 ELSE norm.r22 END AS keep_up_goal
           ,map_base.testritscore + norm.r22 AS keep_up_rit
           --,COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_goal
           --,map_base.testritscore + COALESCE(map_base.typical_growth_fallorspring_to_spring, norm.r22) AS keep_up_rit
           ,CASE 
             --bottom quartile
             WHEN CAST(map_base.testpercentile AS INT) > 0   AND CAST(status_norms.percentile AS INT) < 25 
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
             --2nd quartile
             WHEN CAST(map_base.testpercentile AS INT) >= 25 AND CAST(status_norms.percentile AS INT) < 50 
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
             --3rd quartile
             WHEN CAST(map_base.testpercentile AS INT) >= 50 AND CAST(status_norms.percentile AS INT) < 75 
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
             --top quartile
             WHEN CAST(map_base.testpercentile AS INT) >= 75 AND CAST(status_norms.percentile AS INT) < 100
              AND stu_roster.GRADE_LEVEL > 0
              THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)             
             --K needs fall to spring norm
             WHEN CAST(map_base.testpercentile AS INT) > 0   AND CAST(status_norms.percentile AS INT) < 25 
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.5, 0)
             --2nd quartile
             WHEN CAST(map_base.testpercentile AS INT) >= 25 AND CAST(status_norms.percentile AS INT) < 50 
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.5, 0)
             --3rd quartile
             WHEN CAST(map_base.testpercentile AS INT) >= 50 AND CAST(status_norms.percentile AS INT) < 75 
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.25, 0)
             --top quartile
             WHEN CAST(map_base.testpercentile AS INT) >= 75 AND CAST(status_norms.percentile AS INT) < 100
              AND stu_roster.GRADE_LEVEL = 0
              THEN ROUND(CAST(norm.r42 AS FLOAT) * 1.25, 0)
            END AS rutgers_ready_goal  
     FROM stu_roster
     JOIN math_read
       ON 1=1     
     --baseline (composite of Spring and Fall; pick best)
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_base WITH(NOLOCK)
       ON stu_roster.studentid = map_base.studentid 
      AND stu_roster.year = map_base.year
      AND math_read.measurementscale = map_base.measurementscale
     LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data_extended#2011 norm WITH(NOLOCK)
       ON math_read.measurementscale = norm.subject
      AND map_base.testritscore = norm.startrit
      AND (
        (stu_roster.grade_level > 0 AND stu_roster.grade_level-1 = norm.startgrade ) OR
        (stu_roster.grade_level = 0 AND stu_roster.grade_level = norm.startgrade)
      )
      LEFT OUTER JOIN KIPP_NJ..MAP$norm_table#2011 status_norms
        ON math_read.measurementscale = status_norms.measurementscale
        AND map_base.testritscore = status_norms.RIT
        AND (
          (stu_roster.grade_level > 0 AND stu_roster.grade_level-1 = status_norms.grade AND status_norms.fallwinterspring='Spring') OR
          (stu_roster.grade_level = 0 AND stu_roster.grade_level = status_norms.grade AND status_norms.fallwinterspring='Fall')
        )
     WHERE stu_roster.grade_level <= 3
    ) sub


UNION ALL


--MATH AND READING FOR ES 4
SELECT sub.*
      ,sub.baseline_rit + sub.rutgers_ready_goal AS rutgers_ready_rit
FROM
    (
     SELECT stu_roster.*
           ,math_read.measurementscale
           ,map_base.testritscore AS baseline_rit
           ,map_base.testpercentile AS baseline_percentile
           ,map_base.termname AS derived_from           
           ,norm.r22 AS keep_up_goal
           ,map_base.testritscore + norm.r22 AS keep_up_rit
           ,CASE 
             --bottom quartile
             WHEN CAST(status_norms.percentile AS INT) > 0   AND CAST(status_norms.percentile AS INT) < 25 THEN ROUND(CAST(norm.r22 AS FLOAT) * 2, 0)
             --2nd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 25 AND CAST(status_norms.percentile AS INT) < 50 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.75, 0)
             --3rd quartile
             WHEN CAST(status_norms.percentile AS INT) >= 50 AND CAST(status_norms.percentile AS INT) < 75 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.5, 0)
             --top quartile
             WHEN CAST(status_norms.percentile AS INT) >= 75 AND CAST(status_norms.percentile AS INT) < 100 THEN ROUND(CAST(norm.r22 AS FLOAT) * 1.25, 0)
            END AS rutgers_ready_goal  
     FROM stu_roster
     JOIN math_read
       ON 1=1      
     --baseline (composite of Spring and Fall; pick best)
     LEFT OUTER JOIN KIPP_NJ..MAP$best_baseline#static map_base WITH(NOLOCK)
       ON stu_roster.studentid = map_base.studentid 
      AND stu_roster.year = map_base.year
      AND math_read.measurementscale = map_base.measurementscale
     LEFT OUTER JOIN KIPP_NJ..MAP$growth_norms_data_extended#2011 norm WITH(NOLOCK)
       ON math_read.measurementscale = norm.subject
      AND map_base.testritscore = norm.startrit
      AND stu_roster.grade_level-1 = norm.startgrade
      LEFT OUTER JOIN KIPP_NJ..MAP$norm_table#2011 status_norms
        ON math_read.measurementscale = status_norms.measurementscale
        AND map_base.testritscore = status_norms.RIT
        AND (
          (stu_roster.grade_level > 0 AND stu_roster.grade_level-1 = status_norms.grade AND status_norms.fallwinterspring='Spring') OR
          (stu_roster.grade_level = 0 AND stu_roster.grade_level = status_norms.grade AND status_norms.fallwinterspring='Fall')
        )
     WHERE stu_roster.grade_level = 4
    ) sub