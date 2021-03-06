USE SPI
GO

ALTER VIEW SPI$lit_growth AS

SELECT school
      ,ISNULL(CONVERT(NVARCHAR,grade_level), 'campus') AS grade_level
      ,[year]
      --,AVG(end_step) AS avg_end_step
      ,ROUND(AVG(CONVERT(FLOAT,eoy_benchmark_dummy)) * 100, 1) AS avg_at_standards
      ,ROUND(AVG(CONVERT(FLOAT,growth_dummy)) * 100, 1) AS avg_typical_growth 
      ,school + '@' + ISNULL(CONVERT(NVARCHAR,grade_level), 'campus') AS hash
FROM
    (
     SELECT step.*
           ,s.abbreviation AS school
           ,CASE  
              WHEN end_step >= (grade_level * 3) + 3 THEN 1
              WHEN end_step <  (grade_level * 3) + 3 THEN 0
            END AS eoy_benchmark_dummy
           ,CASE
             WHEN end_step = 12 THEN 1
             WHEN step_change >= 3 THEN 1
             WHEN step_change < 3 THEN 0
            END AS growth_dummy
     FROM KIPP_NJ..LIT$STEP_growth_measures_long step WITH(NOLOCK)
     JOIN KIPP_NJ..SCHOOLS s WITH(NOLOCK)
       ON step.schoolid = s.school_number
     WHERE year = KIPP_NJ.dbo.fn_Global_Academic_Year()
       AND grade_level < 5
    ) sub
GROUP BY school
        ,ROLLUP(grade_level)
        ,[year]