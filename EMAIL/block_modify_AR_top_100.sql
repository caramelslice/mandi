/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
WHERE job_name LIKE '%Top%'
ORDER BY id

SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY ID

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('AR: TEAM Schools Top 100'
 ,'auto'
 ,'2013-11-22 7:20:30.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 22


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR: TEAM Schools Top 100'
   ,@send_again = @fake OUTPUT
END

*/

USE KIPP_NJ
GO

DECLARE @this_job_name      NCHAR(100) = 'AR: TEAM Schools Top 100'
       
BEGIN

MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     ( --'amartin@teamschools.org'
       'cbraman@teamschools.org;melguero@teamschools.org;kdjones@teamschools.org;dsonnier@teamschools.org;dglaubinger@teamschools.org'
       ,@this_job_name
       --figure out SEND AGAIN
       ,'DATEADD(DAY, 7, 
             DateAdd(mi, 20, DateAdd(hh, 7,
                --SETS THE YEAR PART OF THE DATE TO BE THIS YEAR
               (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                --SETS THE MONTH AND DAY PART TO TODAY
                  DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
               ))
             )'
       ,3
        --stat query 1
       ,'SELECT n
         FROM
               (SELECT sch.abbreviation AS school
                      ,COUNT(*) AS N
                FROM KIPP_NJ..AR$progress_to_goals_long#static ar
                JOIN KIPP_NJ..STUDENTS s
                  ON ar.studentid = s.id
                JOIN KIPP_NJ..SCHOOLS sch
                  ON s.schoolid = sch.school_number
                WHERE ar.yearid = 2300
                  AND ar.time_hierarchy = 1
                    AND (ar.rank_words_overall_in_network <= 100 OR ar.rank_points_overall_in_network <= 100)
                GROUP BY sch.abbreviation
                ) sub
         WHERE school = ''TEAM''
        '
        --stat query 2
       ,'SELECT n
         FROM
               (SELECT sch.abbreviation AS school
                      ,COUNT(*) AS N
                FROM KIPP_NJ..AR$progress_to_goals_long#static ar
                JOIN KIPP_NJ..STUDENTS s
                  ON ar.studentid = s.id
                JOIN KIPP_NJ..SCHOOLS sch
                  ON s.schoolid = sch.school_number
                WHERE ar.yearid = 2300
                  AND ar.time_hierarchy = 1
                    AND (ar.rank_words_overall_in_network <= 100 OR ar.rank_points_overall_in_network <= 100)
                GROUP BY sch.abbreviation
                ) sub
         WHERE school = ''Rise''
        '
         --stat query 3
       ,'SELECT n
         FROM
               (SELECT sch.abbreviation AS school
                      ,COUNT(*) AS N
                FROM KIPP_NJ..AR$progress_to_goals_long#static ar
                JOIN KIPP_NJ..STUDENTS s
                  ON ar.studentid = s.id
                JOIN KIPP_NJ..SCHOOLS sch
                  ON s.schoolid = sch.school_number
                WHERE ar.yearid = 2300
                  AND ar.time_hierarchy = 1
                    AND (ar.rank_words_overall_in_network <= 100 OR ar.rank_points_overall_in_network <= 100)
                GROUP BY sch.abbreviation
                ) sub
         WHERE school = ''NCA''
        '
        --stat query 4
        ,' '
         --stat labels 1-4
        ,'TEAM'
        ,'Rise'
        ,'NCA'
        ,' '
        --image stuff
        ,1
        --dynamic filepath
        ,'\\WINSQL01\r_images\DATEKEY_ar_top100_wide.png'
        ,' '
        --regular text (use single space for nulls)
        ,'These are the top 100 readers in TEAM Schools (words or points).<center>'
        ,'</center>'
        ,' '
        ,' '
        --csv stuff
        ,'On'
        ,'SELECT TOP 1000000 sch.abbreviation
                ,s.first_name + '' '' + s.last_name AS student_name
                ,CAST(s.grade_level AS VARCHAR) AS grade_level
                ,CAST(ar.rank_words_overall_in_network AS VARCHAR) AS rank_words
                ,CAST(ar.rank_points_overall_in_network AS VARCHAR) AS rank_points
                ,ar.time_period_name AS time_period
                ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words_yr
                ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS points
                ,CAST(ar.mastery AS VARCHAR) AS mastery 
                ,CAST(ar.avg_lexile AS VARCHAR) AS avg_lexile
                ,CAST(ar.n_passed AS VARCHAR) AS passed
                ,CAST(ar.n_total AS VARCHAR) AS taken
          FROM KIPP_NJ..AR$progress_to_goals_long#static ar
          JOIN KIPP_NJ..STUDENTS s
            ON ar.studentid = s.id
          JOIN KIPP_NJ..SCHOOLS sch
            ON s.schoolid = sch.school_number
          WHERE ar.yearid = 2300
            AND ar.time_hierarchy = 1
            AND (ar.rank_words_overall_in_network <= 100 OR ar.rank_points_overall_in_network <= 100)
          ORDER BY ar.rank_words_overall_in_network'
        --table query 1
        ,'SELECT TOP 1000000 sch.abbreviation
                ,s.first_name + '' '' + s.last_name AS student_name
                ,CAST(s.grade_level AS VARCHAR) AS grade_level
                ,CAST(ar.rank_words_overall_in_network AS VARCHAR) AS rank_words
                ,CAST(ar.rank_points_overall_in_network AS VARCHAR) AS rank_points
                ,ar.time_period_name AS time_period
                ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS words_yr
                ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS points
                ,CAST(ar.mastery AS VARCHAR) AS mastery 
                ,CAST(ar.avg_lexile AS VARCHAR) AS avg_lexile
                ,CAST(ar.n_passed AS VARCHAR) AS passed
                ,CAST(ar.n_total AS VARCHAR) AS taken
          FROM KIPP_NJ..AR$progress_to_goals_long#static ar
          JOIN KIPP_NJ..STUDENTS s
            ON ar.studentid = s.id
          JOIN KIPP_NJ..SCHOOLS sch
            ON s.schoolid = sch.school_number
          WHERE ar.yearid = 2300
            AND ar.time_hierarchy = 1
            AND (ar.rank_words_overall_in_network <= 100 OR ar.rank_points_overall_in_network <= 100)
          ORDER BY ar.rank_words_overall_in_network'
         --table query 2
        ,' '
        --table query 3
        ,' '
         --table style parameters
        ,'CSS_small'
        ,' '
        ,' '
     )
  ) AS SOURCE
  (  [email_recipients]
    ,[email_subject]
    ,[send_again]
    ,[stat_count]
    ,[stat_query1]
    ,[stat_query2]
    ,[stat_query3]
    ,[stat_query4]
    ,[stat_label1]
    ,[stat_label2]
    ,[stat_label3]
    ,[stat_label4]
    ,[image_count]
    ,[image_path1]
    ,[image_path2]
    ,[explanatory_text1]
    ,[explanatory_text2]
    ,[explanatory_text3]
    ,[explanatory_text4]
    ,[csv_toggle]
    ,[csv_query]
    ,[table_query1]
    ,[table_query2]
    ,[table_query3]
    ,[table_style1]
    ,[table_style2]
    ,[table_style3]
  )
  ON target.job_name = @this_job_name

WHEN MATCHED THEN
  UPDATE
    SET target.email_recipients = source.email_recipients
       ,target.email_subject    = source.email_subject
       ,target.send_again =  source.send_again
       ,target.stat_count =  source.stat_count
       ,target.stat_query1 =  source.stat_query1
       ,target.stat_query2 =  source.stat_query2
       ,target.stat_query3 =  source.stat_query3
       ,target.stat_query4 =  source.stat_query4
       ,target.stat_label1 =  source.stat_label1
       ,target.stat_label2 =  source.stat_label2
       ,target.stat_label3 =  source.stat_label3
       ,target.stat_label4 =  source.stat_label4
       ,target.image_count =  source.image_count
       ,target.image_path1 =  source.image_path1
       ,target.image_path2 =  source.image_path2
       ,target.explanatory_text1 =  source.explanatory_text1
       ,target.explanatory_text2 =  source.explanatory_text2
       ,target.explanatory_text3 =  source.explanatory_text3
       ,target.explanatory_text4 =  source.explanatory_text4
       ,target.csv_toggle =  source.csv_toggle
       ,target.csv_query =  source.csv_query
       ,target.table_query1 =  source.table_query1
       ,target.table_query2 =  source.table_query2
       ,target.table_query3 =  source.table_query3
       ,target.table_style1 =  source.table_style1
       ,target.table_style2 =  source.table_style2
       ,target.table_style3 =  source.table_style3
WHEN NOT MATCHED THEN
   INSERT
   (  [job_name]
     ,[email_recipients]
     ,[email_subject]
     ,[send_again]
     ,[stat_count]
     ,[stat_query1]
     ,[stat_query2]
     ,[stat_query3]
     ,[stat_query4]
     ,[stat_label1]
     ,[stat_label2]
     ,[stat_label3]
     ,[stat_label4]
     ,[image_count]
     ,[image_path1]
     ,[image_path2]
     ,[explanatory_text1]
     ,[explanatory_text2]
     ,[explanatory_text3]
     ,[explanatory_text4]
     ,[csv_toggle]
     ,[csv_query]
     ,[table_query1]
     ,[table_query2]
     ,[table_query3]
     ,[table_style1]
     ,[table_style2]
     ,[table_style3]
   )
   VALUES
   (  @this_job_name
     ,source.email_recipients
     ,source.email_subject
     ,source.send_again
     ,source.stat_count
     ,source.stat_query1
     ,source.stat_query2
     ,source.stat_query3
     ,source.stat_query4
     ,source.stat_label1
     ,source.stat_label2
     ,source.stat_label3
     ,source.stat_label4
     ,source.image_count
     ,source.image_path1
     ,source.image_path2
     ,source.explanatory_text1
     ,source.explanatory_text2
     ,source.explanatory_text3
     ,source.explanatory_text4
     ,source.csv_toggle
     ,source.csv_query
     ,source.table_query1
     ,source.table_query2
     ,source.table_query3
     ,source.table_style1
     ,source.table_style2
     ,source.table_style3
   );

END