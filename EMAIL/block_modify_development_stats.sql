/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
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
 ('Development: Current Network Stats'
 ,'auto'
 ,'2013-10-07 11:59:30.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 22


--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN
  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'Development: Current Network Stats'
   ,@send_again = @fake OUTPUT
END

*/

USE KIPP_NJ
GO

DECLARE @this_job_name      NCHAR(100) = 'Development: Current Network Stats'
       
BEGIN

MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
USING 
  (VALUES 
     ( --'amartin@teamschools.org'
       'bcope@teamschools.org;jshetsen@teamschools.org;lphillips@teamschools.org;aansari@teamschools.org;plebre@teamschools.org;tdesimon@teamschools.org;ldesimon@teamschools.org;MAlderman@teamschools.org;efisher@teamschools.org;mbertsch@teamschools.org;ssmall@teamschools.org;EGrohman@teamschools.org;vmarigna@teamschools.org;bcalvert@teamschools.org;gdifilippo@teamschools.org'
       ,'Development: Current Network Stats'
       --figure out SEND AGAIN
       ,'DATEADD(DAY, 7, GETDATE())'
       ,4
        --stat query 1
       ,'SELECT COUNT(*) AS N
         FROM KIPP_NJ..STUDENTS
         WHERE students.enroll_status = 0
        '
        --stat query 2
       ,'SELECT CAST(ROUND(AVG(dummy) * 100, 1) AS FLOAT) AS value
         FROM
               (SELECT s.ID
                      ,CASE
                         WHEN s.lunchstatus IN (''F'', ''R'') THEN 1.0
                         ELSE 0.0
                       END AS dummy
                FROM KIPP_NJ..STUDENTS s
                WHERE s.enroll_status = 0
                ) sub'
         --stat query 3
        ,'SELECT CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
          FROM
                (SELECT s.ID
                       ,CASE
                          WHEN cust.spedlep LIKE ''%SPED%'' THEN 1.0
                          ELSE 0.0
                        END AS dummy
                 FROM KIPP_NJ..STUDENTS s
                 JOIN KIPP_NJ..CUSTOM_STUDENTS cust
                   ON s.id = cust.studentid
                 WHERE s.enroll_status = 0
                 ) sub 
         '
         --stat query 4
        ,'SELECT CAST(CAST(ROUND(AVG(dummy) * 100, 1) AS NUMERIC(4,1)) AS NVARCHAR) AS value
          FROM
                (SELECT s.ID
                       ,CASE
                          WHEN s.exitcode = ''G1'' THEN 0.0
                          WHEN s.enroll_status > 0 THEN 1.0
                          ELSE 0.0
                        END AS dummy
                 FROM KIPP_NJ..STUDENTS s
                 WHERE s.ENTRYDATE > ''01-AUG-14''
                   AND DATEDIFF(day,s.entrydate,s.exitdate) > 2
                 ) sub
         '
         --stat labels 1-4
        ,'Total Students'
        ,'% Free/Reduced'
        ,'% Special Ed'
        ,'% Attrition (Any Start, YTD)'
        --image stuff
        ,0
        --dynamic filepath
        ,' '
        ,' '
        --regular text (use single space for nulls)
        ,'This table of useful network stats pulled from TEAM''s data warehouse.  All data is live and reflects currently 
          enrolled students unless otherwise specified.  This report currently comes out weekly on Mondays at noon.<center>'
        ,'</center>'
        ,' '
        ,' '
        --csv stuff
        ,'On'
        ,'SELECT statistic
                ,org_unit
                ,value
                ,N
          FROM KIPP_NJ..REPORTING$development_stats'
        --table query 1
        ,'SELECT statistic
                ,org_unit
                ,value
                ,N
          FROM KIPP_NJ..REPORTING$development_stats'
          --table query 2
         ,' '
         --table query 3
         ,' '
          --table style parameters
         ,'CSS_medium'
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