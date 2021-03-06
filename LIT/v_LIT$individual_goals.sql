USE KIPP_NJ
GO

ALTER VIEW LIT$individual_goals AS

WITH gdoc_long AS (
  SELECT [schoolid]
        ,[student_number]      
        ,UPPER(LEFT(field, CHARINDEX('_', field) - 1)) AS test_round
        ,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(goal, '_', ' '),'STEP',''),'FP',''))) AS goal
  FROM [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_LIT_Goals] WITH(NOLOCK)

  UNPIVOT (
    goal
    FOR field IN ([dr_goal]
                 ,[t1_goal]
                 ,[t2_goal]
                 ,[t3_goal]
                 ,[eoy_goal])
   ) u
 )

SELECT g.schoolid
      ,s.id AS studentid      
      ,g.student_number
      ,g.test_round
      ,g.goal
      ,gleq.GLEQ
      ,gleq.lvl_num
FROM gdoc_long g
JOIN STUDENTS s WITH(NOLOCK)
  ON g.student_number = s.STUDENT_NUMBER
LEFT OUTER JOIN LIT$gleq gleq
  ON g.goal = gleq.read_lvl