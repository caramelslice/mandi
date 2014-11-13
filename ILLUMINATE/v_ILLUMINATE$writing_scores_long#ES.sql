USE KIPP_NJ
GO

ALTER VIEW ILLUMINATE$writing_scores_long#ES AS

WITH valid_assessments AS (
  SELECT DISTINCT repository_id
  FROM ILLUMINATE$summary_assessments#static
  WHERE scope = 'Interim Assessment'
    AND subject = 'Writing'
    AND grade_level < 5
 )

,raw_data AS (
  SELECT repo.student_id AS student_number
        ,repo.repository_row_id      
        ,fields.label AS field
        ,repo.value
  FROM ILLUMINATE$summary_assessment_results_long#static repo WITH(NOLOCK)
  JOIN ILLUMINATE$repository_fields fields WITH(NOLOCK)
    ON repo.repository_id = fields.repository_id
   AND repo.field = fields.name 
  WHERE repo.repository_id IN (SELECT repository_id FROM valid_assessments WITH(NOLOCK))
 )

,test_metadata AS (
  SELECT student_number
        ,repository_row_id
        ,date_administered
        ,assmt_notes
        ,writing_type
        ,total_points
        ,total_prof
  FROM
      (
       SELECT student_number
             ,repository_row_id
             ,[Date of Administration] AS date_administered
             ,[Anecdotal Notes] AS assmt_notes
             ,[Writing Type] AS writing_type
             ,[Total Points] AS total_points
             ,[Total Proficiency] AS total_prof
       FROM raw_data WITH(NOLOCK)
       PIVOT(
         MAX(value)
         FOR field IN ([Date of Administration],[Anecdotal Notes],[Writing Type],[Total Points],[Total Proficiency])
        ) p
      ) sub
  LEFT OUTER JOIN REPORTING$dates dt WITH(NOLOCK)
    ON sub.date_administered >= dt.start_date
   AND sub.date_administered <= dt.end_date
   AND dt.identifier = 'RT'
   AND dt.schoolid = 73254
   AND dt.academic_year = 2014
 )

SELECT student_number
      ,repository_row_id
      ,date_administered
      ,writing_type      
      ,total_points
      ,total_prof
      ,assmt_notes
      ,writing_obj
      ,[score]
      ,[proficiency]
      ,'writing_obj_' + CONVERT(VARCHAR,
                          ROW_NUMBER() OVER(
                            PARTITION BY student_number, repository_row_id
                              ORDER BY writing_obj ASC)) AS pivot_hash_obj
      ,'writing_prof_' + CONVERT(VARCHAR,
                          ROW_NUMBER() OVER(
                            PARTITION BY student_number, repository_row_id
                              ORDER BY writing_obj ASC)) AS pivot_hash_prof
FROM 
    (
     SELECT md.student_number                 
           ,md.repository_row_id
           ,md.date_administered
           ,md.writing_type
           ,md.assmt_notes           
           ,md.total_points
           ,md.total_prof
           ,LTRIM(RTRIM(LEFT(scores.field,CHARINDEX(CASE WHEN scores.field LIKE '%score' THEN 'Score' ELSE 'Proficiency' END, scores.field) - 1))) AS writing_obj
           ,LOWER(LTRIM(RTRIM(SUBSTRING(scores.field, CHARINDEX(CASE WHEN scores.field LIKE '%score' THEN 'Score' ELSE 'Proficiency' END, scores.field), 15)))) AS measure
           ,CASE WHEN scores.value LIKE '%standard%' THEN STUFF(scores.value, 3, 0, '=') ELSE scores.value END AS value
           --,CASE WHEN scores.value LIKE '%standard%' THEN LEFT(scores.value, 1) ELSE scores.value END AS numeric_score -- we'll get back to this for the Tableau rollup           
     FROM test_metadata md WITH(NOLOCK)
     LEFT OUTER JOIN raw_data scores WITH(NOLOCK)
       ON md.student_number = scores.student_number
      AND md.repository_row_id = scores.repository_row_id
      AND scores.field NOT IN ('Date of Administration','Anecdotal Notes','Writing Type','Total Points','Total Proficiency')
    ) sub
PIVOT(
  MAX(value)
  FOR measure IN ([score], [proficiency])
 ) p