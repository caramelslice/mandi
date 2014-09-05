USE KIPP_NJ
GO

ALTER VIEW AR$goals_long_decode AS
SELECT CAST(sub_1.student_number AS VARCHAR) AS student_number
      ,sub_1.schoolid
      ,CASE
         WHEN ar_specific.student_number IS NULL THEN sub_1.words_goal
         ELSE ar_specific.words_goal
       END AS words_goal
      ,CASE
         WHEN ar_specific.student_number IS NULL THEN sub_1.points_goal
         ELSE ar_specific.points_goal
       END AS points_goal
      ,sub_1.yearid
      ,sub_1.time_period_name
      ,CASE
         WHEN ar_specific.student_number IS NULL THEN sub_1.time_period_start
         ELSE ar_specific.time_period_start
       END AS time_period_start
      ,CASE
         WHEN ar_specific.student_number IS NULL THEN sub_1.time_period_end
         ELSE ar_specific.time_period_end
       END AS time_period_end
      ,CASE
         WHEN ar_specific.student_number IS NULL THEN sub_1.time_period_hierarchy
         ELSE ar_specific.time_period_hierarchy
       END AS time_period_hierarchy
FROM
     (SELECT s.student_number
            ,cohort.schoolid
            ,cohort.year
            ,ar_default.words_goal
            ,ar_default.points_goal
            ,ar_default.yearid
            ,ar_default.time_period_name
            ,ar_default.time_period_start
            ,ar_default.time_period_end
            ,ar_default.time_period_hierarchy
      FROM COHORT$comprehensive_long#static cohort WITH (NOLOCK)
      JOIN STUDENTS s WITH (NOLOCK)
        ON cohort.studentid = s.id
       AND cohort.rn = 1
       --AND cohort.year >= 2011
       --AND s.STUDENT_NUMBER = 12726
       AND cohort.schoolid != 999999

      AND cohort.year = dbo.fn_Global_Academic_Year()
      --AND cohort.GRADE_LEVEL = 8
      --AND cohort.SCHOOLID = 73252

      JOIN AR$goals ar_default WITH (NOLOCK)
        ON 'Default_Gr' + CAST(cohort.grade_level AS VARCHAR) = CAST(ar_default.student_number AS VARCHAR)
       AND cohort.schoolid = ar_default.schoolid
       AND CAST(((cohort.year - 1990) * 100) AS INT) = ar_default.yearid  
      ) sub_1
LEFT OUTER JOIN (
  --YEAR
  SELECT sub.*
  FROM
        (SELECT sub.*
               ,ROW_NUMBER() OVER
                  (PARTITION BY student_number
                               ,schoolid
                               ,yearid
                               ,time_period_hierarchy
                   ORDER BY force_sort
                  ) AS rn
         FROM  
               (SELECT ar.* 
                      ,1 AS force_sort
                FROM AR$goals ar WITH (NOLOCK)
                WHERE student_number NOT LIKE 'Default%'
                  AND student_number IS NOT NULL
                  AND student_number != ''

                UNION ALL

                SELECT NULL AS ID
                      ,student_number
                      ,schoolid
                      ,proj_words_goal_year AS words_goal
                      ,proj_points_goal_year AS points_goal
                      ,yearid
                      ,'Year' AS time_period_name
                      ,CASE
                         WHEN schoolid = 73252 THEN '2013-06-15'
                         WHEN schoolid = 133570965 THEN '2013-08-12'
                         WHEN schoolid = 73253 THEN '2013-09-03' 
                       END AS time_period_start
                      ,CASE
                         WHEN schoolid = 73252 THEN '2014-06-06'
                         WHEN schoolid = 133570965 THEN '2014-08-12'
                         WHEN schoolid = 73253 THEN '2014-06-11' 
                       END AS time_period_end
                      ,1 AS time_period_hierarchy
                      ,2 AS force_sort
                FROM
                      (SELECT sub.*
                             ,ROUND(
                                --num
                                total_words_goal / 
                                --denom
                                (CAST(total_periods AS FLOAT) / 
                                   CASE
                                     --MS will set 6 goals
                                     WHEN schoolid = 73252 THEN 6
                                     WHEN schoolid = 133570965 THEN 6
                                     --HS will set 4 goals
                                     WHEN schoolid = 73253 THEN 4
                                   END
                                )
                              ,0) AS proj_words_goal_year
                             ,ROUND(
                                --num
                                total_points_goal / 
                                --denom
                                (CAST(total_periods AS FLOAT) / 
                                   CASE
                                     --MS will set 6 goals
                                     WHEN schoolid = 73252 THEN 6
                                     WHEN schoolid = 133570965 THEN 6
                                     --HS will set 4 goals
                                     WHEN schoolid = 73253 THEN 4
                                   END
                                )
                              ,0) AS proj_points_goal_year
                       FROM
                            (SELECT sub.student_number
                                   ,sub.schoolid
                                   ,sub.yearid
                                   ,SUM(words_goal) AS total_words_goal
                                   ,SUM(points_goal) AS total_points_goal
                                   ,SUM(num_days) AS total_days
                                   ,DATEDIFF(DAY, CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year()) + '-08-01'),	CONVERT(DATE,CONVERT(VARCHAR,dbo.fn_Global_Academic_Year() + 1) + '-06-30')) AS year_days
                                   ,COUNT(*) AS total_periods
                             FROM
                                   (SELECT ar.*
                                          ,DATEDIFF(day, ar.time_period_start, ar.time_period_end) AS num_days
                                    FROM KIPP_NJ..AR$goals ar WITH (NOLOCK)
                                    WHERE time_period_hierarchy = 2
                                      AND yearid = dbo.fn_Global_Term_Id()
                                      AND student_number IS NOT NULL
                                    ) sub
                             GROUP BY sub.student_number
                                     ,sub.schoolid
                                     ,sub.yearid
                             ) sub
                       ) sub
                ) sub
         ) sub
  WHERE rn = 1
  
  UNION ALL

  SELECT ar_spec_h2.*
        ,1 AS force_sort
        ,1 AS rn
  FROM AR$goals ar_spec_h2 WITH (NOLOCK)
  WHERE ar_spec_h2.time_period_hierarchy = 2
    AND student_number NOT LIKE 'Default%'
    AND student_number IS NOT NULL
    AND student_number != ''
  ) ar_specific
  ON CAST(sub_1.student_number AS VARCHAR) = CAST(ar_specific.student_number AS VARCHAR)
 AND sub_1.schoolid = ar_specific.schoolid
 AND sub_1.yearid = ar_specific.yearid
 AND sub_1.time_period_name = ar_specific.time_period_name
 AND sub_1.time_period_hierarchy = ar_specific.time_period_hierarchy

--union picks up any specific goals where there is NO corresponding default.

UNION
SELECT CAST(student_number AS VARCHAR)
      ,schoolid
      ,words_goal
      ,points_goal
      ,yearid
      ,time_period_name
      ,time_period_start
      ,time_period_end
      ,time_period_hierarchy
FROM AR$goals WITH (NOLOCK)
WHERE student_number NOT LIKE 'Default_%'