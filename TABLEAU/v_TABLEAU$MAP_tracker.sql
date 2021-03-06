USE KIPP_NJ
GO

ALTER VIEW TABLEAU$MAP_tracker AS

WITH map_long AS (
  SELECT base.studentid
        ,base.year
        ,terms.fallwinterspring
        ,base.measurementscale
        ,base.testritscore AS base_rit
        ,base.testpercentile AS base_pct
        ,CASE WHEN base.lexile_score = 'BR' THEN 0 ELSE base.lexile_score END AS base_lex
        ,rr.keep_up_goal
        ,rr.keep_up_rit
        ,rr.rutgers_ready_goal
        ,rr.rutgers_ready_rit      
        ,CASE  
          WHEN terms.fallwinterspring = 'Fall' THEN COALESCE(base.testpercentile, map.percentile_2011_norms)                 
          ELSE map.percentile_2011_norms 
         END AS pct
        ,CASE  
          WHEN terms.fallwinterspring = 'Fall' THEN COALESCE(base.testritscore, map.testritscore)
          ELSE map.testritscore
         END AS rit      
        ,CASE  
          WHEN terms.fallwinterspring = 'Fall' THEN COALESCE(REPLACE(base.lexile_score, 'BR', 0), REPLACE(map.rittoreadingscore, 'BR', 0))
          ELSE REPLACE(map.rittoreadingscore, 'BR', 0)
         END AS lex      
  FROM MAP$best_baseline#static base WITH(NOLOCK)
  JOIN (
        SELECT 'Fall' AS fallwinterspring
        UNION
        SELECT 'Winter'
        UNION
        SELECT 'Spring'
       ) terms
    ON 1 = 1
  LEFT OUTER JOIN MAP$rutgers_ready_student_goals rr WITH(NOLOCK)
    ON base.year = rr.year
   AND REPLACE(base.measurementscale,' Usage','') = rr.measurementscale
   AND base.studentid = rr.studentid
  LEFT OUTER JOIN MAP$comprehensive#identifiers#static map WITH(NOLOCK)
    ON base.studentid = map.ps_studentid
   AND base.year = map.map_year_academic
   AND base.measurementscale = map.measurementscale
   AND terms.fallwinterspring = map.fallwinterspring
   AND map.rn = 1
 )

,map_curr AS (
  SELECT map.ps_studentid AS studentid
        ,map.map_year_academic AS year
        ,map.measurementscale
        ,map.fallwinterspring
        ,CONVERT(INT,map.testritscore) AS rit
        ,CONVERT(INT,map.percentile_2011_norms) AS pct
        ,CONVERT(INT,REPLACE(map.rittoreadingscore, 'BR', 0)) AS lexile
  FROM KIPP_NJ..MAP$comprehensive#identifiers#static map WITH(NOLOCK)
  WHERE rn_curr = 1
 )

,read_lvl AS (
  SELECT academic_year
        ,studentid
        ,test_round
        ,read_lvl      
        ,CASE
          WHEN test_round IN ('BOY','DR') THEN 'Fall'
          WHEN test_round = 'T2' THEN 'Winter'
          WHEN test_round = 'T3' THEN 'Spring'
          ELSE NULL
         END AS fallwinterspring
  FROM LIT$achieved_by_round#static WITH(NOLOCK)
 )

SELECT r.year
      ,r.studentid
      ,r.student_number
      ,r.lastfirst
      ,r.schoolid
      ,r.grade_level
      ,r.cohort
      ,r.team        
      ,r.SPEDLEP
      ,map_long.measurementscale
      ,map_long.base_rit
      ,map_long.base_pct
      ,map_long.base_lex
      ,map_long.keep_up_goal
      ,map_long.keep_up_rit
      ,map_long.rutgers_ready_goal
      ,map_long.rutgers_ready_rit
      ,map_long.fallwinterspring      
      ,map_long.rit       
      ,map_long.pct       
      ,map_long.lex       
      ,map_curr.rit AS cur_rit       
      ,map_curr.pct AS cur_pct       
      ,map_curr.lexile AS cur_lex
      ,CASE 
        WHEN map_long.pct >= 0 AND map_long.pct < 25 THEN 1
        WHEN map_long.pct >= 25 AND map_long.pct < 50 THEN 2
        WHEN map_long.pct >= 50 AND map_long.pct < 75 THEN 3
        WHEN map_long.pct >= 75 AND map_long.pct < 100 THEN 4
        ELSE NULL
       END AS quartile
      ,CASE WHEN map_curr.fallwinterspring = 'Fall' THEN NULL ELSE map_curr.rit - map_long.base_rit END AS ytd_rit_growth
      ,CASE WHEN map_curr.fallwinterspring = 'Fall' THEN NULL ELSE map_curr.pct - map_long.base_pct END AS ytd_pct_growth
      ,CASE WHEN map_curr.fallwinterspring = 'Fall' THEN NULL ELSE map_curr.lexile - map_long.base_lex END AS ytd_lex_growth
      ,map_curr.pct - 75 AS dist_from_75
      ,CASE WHEN map_long.fallwinterspring = map_curr.fallwinterspring THEN 1 ELSE 0 END AS is_current
      ,enr.CREDITTYPE
      ,enr.COURSE_NUMBER
      ,enr.COURSE_NAME
      ,enr.teacher_name AS teacher
      ,enr.teacher_coach
      ,enr.period      
      ,rs.read_lvl
FROM COHORT$identifiers_long#static r WITH(NOLOCK)
LEFT OUTER JOIN map_long
  ON r.studentid = map_long.studentid
 AND r.year = map_long.year 
LEFT OUTER JOIN KIPP_NJ..PS$enrollments_rollup#static enr WITH(NOLOCK)
  ON r.studentid = enr.STUDENTID
 AND r.year = enr.academic_year
 AND map_long.measurementscale = enr.measurementscale
LEFT OUTER JOIN map_curr
  ON r.studentid = map_curr.studentid
 AND r.year = map_curr.year 
 AND map_long.measurementscale = map_curr.measurementscale
LEFT OUTER JOIN read_lvl rs
  ON r.studentid = rs.studentid
 AND r.year = rs.academic_year
 AND map_long.fallwinterspring = rs.fallwinterspring
WHERE r.schoolid != 999999
  AND r.rn = 1    