USE KIPP_NJ
GO

ALTER VIEW LIT$step_headline_long AS
SELECT studentid
      ,lastfirst
      ,student_number
      ,date_taken
      ,step_level
      ,testid
      ,status
      ,CASE WHEN status = 'Did Not Achieve' AND step_level_numeric = 0 THEN -1 ELSE step_level_numeric END AS step_level_numeric
FROM
      (SELECT s.id AS studentid                                    
             ,s.lastfirst
             ,s.student_number
             ,scores.test_date AS date_taken
             ,scores.step_ltr_level AS step_level
             ,scores.testid
             ,scores.status AS status
             ,CASE
                WHEN scores.step_ltr_level IN ('Pre', 'Pre DNA', 'PreDNA') THEN 0
                ELSE scores.step_ltr_level
              END AS step_level_numeric
       FROM LIT$readingscores#static scores
       JOIN students s
         ON s.id = scores.studentid
       WHERE step_ltr_level IS NOT NULL
         AND testid >= 3274
       ) sub