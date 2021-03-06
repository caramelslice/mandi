USE KIPP_NJ
GO

ALTER VIEW AR$goals_staging AS

WITH goals AS (
  /* NCA */
  SELECT [SN] AS student_number
        ,73253 AS schoolid                  
        ,NULL AS words_goal      
        ,CONVERT(FLOAT,[Points Goal]) AS points_goal
        ,2400 AS yearid
        ,CASE
          WHEN [term] = 'Q1' THEN 'Reporting Term 1'
          WHEN [term] = 'Q2' THEN 'Reporting Term 2'
          WHEN [term] = 'Q3' THEN 'Reporting Term 3'
          WHEN [term] = 'Q4' THEN 'Reporting Term 4'
          WHEN [term] = 'Y1' THEN 'Year'
         END AS time_period_name
        ,CASE
          WHEN [term] IN ('Q1','Q2','Q3','Q4') THEN 2
          WHEN [term] = 'Y1' THEN 1
         END AS time_period_hierarchy
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_AR_NCA] WITH(NOLOCK)
  WHERE [sn] IS NOT NULL
  /* NCA */

  UNION ALL

  /* TEAM */
  -- Hex goals, based off of independent level 
  -- can be overridden by the GDoc
  SELECT co.student_number
        ,co.schoolid
        ,COALESCE(REPLACE(gdoc.[Adjusted Goal],',',''), tier.words_goal) AS words_goal
        ,NULL AS points_goal
        ,dbo.fn_Global_Term_Id() AS yearid
        ,dt.time_per_name AS time_period_name
        ,2 AS time_period_hierarchy
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)
  JOIN REPORTING$dates dt WITH(NOLOCK)
    ON 1 = 1
   AND co.schoolid = dt.schoolid
   AND dt.academic_year = dbo.fn_Global_Academic_Year()
   AND dt.identifier = 'HEX'
  LEFT OUTER JOIN LIT$achieved_by_round#static achv WITH(NOLOCK)
    ON co.studentid = achv.STUDENTID
   AND CASE
        WHEN dt.time_per_name = 'Hexameter 1' THEN 'BOY'
        WHEN dt.time_per_name IN ('Hexameter 2','Hexameter 3') THEN 'T1'
        WHEN dt.time_per_name IN ('Hexameter 4','Hexameter 5') THEN 'T2'
        WHEN dt.time_per_name = 'Hexameter 6' THEN 'T3'
       END = achv.test_round
   AND achv.academic_year = dbo.fn_Global_Academic_Year()  
  LEFT OUTER JOIN LIT$GLEQ gleq WITH(NOLOCK)
    ON achv.indep_lvl = gleq.read_lvl
  LEFT OUTER JOIN AR$goal_criteria#MS goal WITH(NOLOCK)
    ON gleq.lvl_num >= goal.min
   AND gleq.lvl_num <= goal.max
   AND goal.criteria = 'lvl_num'
  LEFT OUTER JOIN AR$tier_goals#MS tier WITH(NOLOCK)
    ON goal.tier = tier.tier
  LEFT OUTER JOIN [AUTOLOAD$GDOCS_AR_TEAM] gdoc WITH(NOLOCK)
    ON co.student_number = gdoc.student_number
   AND dt.time_per_name = 'Hexameter ' + CONVERT(VARCHAR,[Cycle])
   AND gdoc.Cycle IS NOT NULL
  WHERE co.year = dbo.fn_Global_Academic_Year()
    AND co.schoolid = 133570965
    AND co.rn = 1
  UNION ALL
  -- year goals
  -- can be overridden by the GDoc
  SELECT co.student_number
        ,co.schoolid
        ,COALESCE(gdoc.[Adjusted Goal], tier.words_goal) AS words_goal
        ,NULL AS points_goal
        ,dbo.fn_Global_Term_Id() AS yearid
        ,'Year' AS time_period_name
        ,1 AS time_period_hierarchy
  FROM COHORT$identifiers_long#static co WITH(NOLOCK)
  LEFT OUTER JOIN LIT$test_events#identifiers achv WITH(NOLOCK)
    ON co.student_number = achv.student_number
   AND achv.achv_curr_all = 1
  LEFT OUTER JOIN LIT$GLEQ gleq WITH(NOLOCK)
    ON achv.indep_lvl = gleq.read_lvl
  LEFT OUTER JOIN AR$goal_criteria#MS goal WITH(NOLOCK)
    ON gleq.lvl_num >= goal.min
   AND gleq.lvl_num <= goal.max
   AND goal.criteria = 'lvl_num'
  LEFT OUTER JOIN AR$tier_goals#MS tier WITH(NOLOCK)
    ON goal.tier = tier.tier
  LEFT OUTER JOIN [AUTOLOAD$GDOCS_AR_TEAM] gdoc WITH(NOLOCK)
    ON co.student_number = gdoc.student_number   
   AND gdoc.Cycle IS NULL
  WHERE co.year = dbo.fn_Global_Academic_Year()
    AND co.schoolid = 133570965
    AND co.rn = 1
  /* TEAM */

  UNION ALL

  SELECT [student_number]
        ,73252 AS schoolid
        ,COALESCE([Adjusted Goal], [Words Goal]) AS words_goal
        ,NULL AS points_goal
        ,2400 AS yearid      
        ,CASE WHEN cycle = 'Y' THEN 'Year' ELSE 'Hexameter ' + CONVERT(VARCHAR,[Cycle]) END AS time_period_name
        ,CASE WHEN Cycle = 'Y' THEN 1 ELSE 2 END AS time_period_hierarchy
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_AR_Rise] WITH(NOLOCK)
  WHERE student_number IS NOT NULL      
 )

SELECT goals.student_number
      ,goals.schoolid
      ,goals.words_goal
      ,goals.points_goal
      ,goals.yearid
      ,goals.time_period_name      
      ,dt.start_date AS time_period_start
      ,dt.end_date AS time_period_end
      ,goals.time_period_hierarchy
      ,ROW_NUMBER() OVER(
         PARTITION BY goals.student_number, goals.time_period_name
           ORDER BY goals.time_period_name) AS rn
FROM goals
JOIN REPORTING$dates dt WITH(NOLOCK)
  ON (goals.schoolid = dt.schoolid OR (dt.identifier = 'SY' AND dt.schoolid IS NULL))
 AND LEFT(goals.yearid, 2) = dt.yearid
 AND goals.time_period_name = CASE WHEN dt.time_per_name = 'Y1' THEN 'Year' ELSE dt.time_per_name END
 AND dt.identifier IN ('RT_IR', 'HEX', 'SY')
WHERE (goals.schoolid != 73253 AND goals.words_goal IS NOT NULL) OR (goals.schoolid = 73253 AND goals.points_goal IS NOT NULL)