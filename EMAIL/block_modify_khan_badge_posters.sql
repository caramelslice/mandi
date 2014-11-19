/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue WITH (NOLOCK)
WHERE id >= 878
  AND sent IS NULL
ORDER BY send_at DESC

--to examine the jobs
SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY id DESC


DELETE
FROM KIPP_NJ..email$template_jobs
WHERE id IN (211, 210, 209)

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('Khan Badge Posters Rise Gr 8'
 ,'auto'
 ,'2014-11-17 06:25:00.000')

--to delete from the queue
BEGIN TRANSACTION
DELETE 
--SELECT *
FROM KIPP_NJ..email$template_queue
--WHERE id IN (879, 882, 884, 886, 888, 890, 892, 894, 896,
WHERE job_name LIKE '%90/90%'
  AND send_at IS NULL

BEGIN TRANSACTION
DELETE
FROM KIPP_NJ..EMAIL$template_jobs
WHERE id IN ( 
--ROLLBACK TRANSACTION
COMMIT TRANSACTION

81 AND id <= 88

--future jobs or nulls?
SELECT *
FROM KIPP_NJ..EMAIL$template_queue
WHERE send_at > GETDATE()
  OR send_at IS NULL
ORDER BY job_name

 --to send a job as a test
 DECLARE @fake NVARCHAR(4000)
 BEGIN

   EXEC dbo.sp_EMAIL$send_template_job
     @job_name = 'Khan Badge Posters TEAM Gr 8'
    ,@send_again = @fake OUTPUT

 END



*/

USE KIPP_NJ
GO

DECLARE @helper_grade_level INT
       ,@helper_schoolid    INT
       ,@helper_school      NVARCHAR(5)
       ,@job_name_text      NVARCHAR(100)
       ,@email_list         VARCHAR(500)
       ,@standard_time      VARCHAR(1000)
       ,@send_again         VARCHAR(1000)
       ,@this_job_name      NCHAR(100)

SET @standard_time = 'CASE
              WHEN DATEPART(WEEKDAY, GETDATE()) = 6
                THEN DATEADD(DAY, 3, 
                DateAdd(mi, 35, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
              ELSE DATEADD(DAY, 7, 
                DateAdd(mi, 35, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
            END'

DECLARE db_cursor CURSOR FOR  
  SELECT grade_level
        ,schoolid
        ,school
        ,job_name_text
         --override:
        --,'amartin@teamschools.org' AS email_list
        ,email_list
        ,send_again
  FROM
     (SELECT 5 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'mjoseph@teamschools.org;jbrooks@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
     
      SELECT 6 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'tdempsey@teamschools.org;rthomas@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time
      UNION
     
      SELECT 7 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'aburke@teamschools.org;kkell@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time
      UNION
     
      SELECT 8 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'' AS job_name_text
            ,'nrouhanifard@teamschools.org;tluna@teamschools.org;lepstein@teamschools.org' AS email_list
            ,@standard_time
      UNION
     
      SELECT 8 AS grade_level
            ,133570965 AS schoolid
            ,'TEAM' AS school
            ,'' AS job_name_text
            ,'edunn@teamschools.org' AS email_list
            ,@standard_time
     ) sub

OPEN db_cursor
WHILE 1=1
  BEGIN

   FETCH NEXT FROM db_cursor INTO @helper_grade_level, @helper_schoolid, @helper_school, @job_name_text, @email_list, @send_again

   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   SET @this_job_name = 'Khan Badge Posters ' + CAST(@helper_school AS NVARCHAR) + ' Gr ' + CAST(@helper_grade_level AS NVARCHAR) + @job_name_text

   --poor man's print
   DECLARE @msg_value varchar(200) = RTRIM(@this_job_name)
   DECLARE @msg nvarchar(200) = '''%s'''
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT
   SET @msg_value = RTRIM(@email_list)
   RAISERROR (@msg, 0, 1, @msg_value) WITH NOWAIT

   MERGE KIPP_NJ..EMAIL$template_jobs AS TARGET
   USING 
     (VALUES 
        ( @email_list
         ,@this_job_name
          --figure out SEND AGAIN
         ,@send_again
         ,1
          --stat query 1
         ,'SELECT ''...are attached!''
           FROM KIPP_NJ..UTIL$row_generator g
           WHERE g.n=100
          '
          --stat query 2
         ,' '
          --stat query 3
         ,' '
          --stat query 4
         ,' '
          --stat labels 1-4
         ,'Classroom badge posters...'
         ,' '
         ,' '
         ,' '
           --image stuff
         ,0
         --dynamic filepath
         ,' '
         ,' '
         --regular text (use single space for nulls)
         ,'Most recent badges earned:'
         ,' '
         ,' '
         ,' '
         ,' '
         --csv stuff
         ,'On'
         --csv query -- all students, no restriction on status
         ,'SELECT badge
                ,stu_name
                ,school
                ,CAST(grade_level AS VARCHAR) AS grade_level
                ,CAST(CAST(date_earned AS date) AS VARCHAR) AS date_earned    
          FROM
                (SELECT TOP 10000 e.*
                       ,b.studentid
                       ,s.first_name + '' '' + s.last_name AS stu_name
                       ,s.lastfirst
                       ,sch.abbreviation AS school
                       ,s.grade_level
                       ,b.date_earned
                       ,ks.profile_root
                 FROM (SELECT TOP 1000 description AS badge
                             ,slug
                             ,points
                             ,safe_extended_description AS badge_description
                             ,icon_large
                       FROM Khan..badge_metadata m WITH (NOLOCK)
                       WHERE m.description IN (''Work Horse'',''Five Times Ten to the Fifth'')
                         OR (m.badge_category = 3 AND m.points > 0)
                       ORDER BY m.badge_category ASC
                               ,m.points ASC) e
                 LEFT OUTER JOIN 
                  (SELECT b.* 
                     FROM Khan..badge_detail#identifiers b WITH (NOLOCK)
                     JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
                       ON b.studentid = s.id
                      AND b.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
                      AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
                      AND s.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                    ) b
                   ON e.slug = b.slug
                 LEFT OUTER JOIN Khan..stu_detail ks WITH (NOLOCK)
                   ON b.student = ks.student
                 LEFT OUTER JOIN 
                   (SELECT s.grade_level
                          ,s.id
                          ,s.schoolid
                          ,s.first_name
                          ,s.last_name
                          ,s.lastfirst
                    FROM KIPP_NJ..STUDENTS s WITH (NOLOCK)
                    WHERE s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
                    ) s 
                   ON b.studentid = s.id
                 LEFT OUTER JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
                   ON s.schoolid = sch.school_number
                 ORDER BY e.points
                         ,e.badge
                         ,b.date_earned ASC
                 ) sub'
         --additional attachment
         ,'\\WINSQL01\r_images\sch_' + @helper_school + '_gr_' + CAST(@helper_grade_level AS VARCHAR) + '_khan_posters.pdf'
         --table query 1
         ,'SELECT badge
                ,stu_name
                ,school
                ,CAST(grade_level AS VARCHAR) AS grade_level
                ,CAST(CAST(date_earned AS date) AS VARCHAR) AS date_earned    
          FROM
                (SELECT TOP 10000 e.*
                       ,b.studentid
                       ,s.first_name + '' '' + s.last_name AS stu_name
                       ,s.lastfirst
                       ,sch.abbreviation AS school
                       ,s.grade_level
                       ,b.date_earned
                       ,ks.profile_root
                 FROM (SELECT TOP 1000 description AS badge
                             ,slug
                             ,points
                             ,safe_extended_description AS badge_description
                             ,icon_large
                       FROM Khan..badge_metadata m WITH (NOLOCK)
                       WHERE m.description IN (''Work Horse'',''Five Times Ten to the Fifth'')
                         OR (m.badge_category = 3 AND m.points > 0)
                       ORDER BY m.badge_category ASC
                               ,m.points ASC) e
                 LEFT OUTER JOIN 
                  (SELECT b.* 
                     FROM Khan..badge_detail#identifiers b
                     JOIN KIPP_NJ..STUDENTS s WITH (NOLOCK)
                       ON b.studentid = s.id
                      AND b.academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
                      AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
                      AND s.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                    ) b
                   ON e.slug = b.slug
                 LEFT OUTER JOIN Khan..stu_detail ks WITH (NOLOCK)
                   ON b.student = ks.student
                 LEFT OUTER JOIN 
                   (SELECT s.grade_level
                          ,s.id
                          ,s.schoolid
                          ,s.first_name
                          ,s.last_name
                          ,s.lastfirst
                    FROM KIPP_NJ..STUDENTS s WITH (NOLOCK)
                    ) s 
                   ON b.studentid = s.id
                 LEFT OUTER JOIN KIPP_NJ..SCHOOLS sch WITH (NOLOCK)
                   ON s.schoolid = sch.school_number
                 ORDER BY b.date_earned DESC
                 ) sub'
          --table query 2
         ,' '
          --table query 3
         ,' '
          --table query 4
         ,' '
          --table style parameters
         ,'CSS_medium'
         ,' '
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
       ,[explanatory_text5]
       ,[csv_toggle]
       ,[csv_query]
       ,[additional_attachment]
       ,[table_query1]
       ,[table_query2]
       ,[table_query3]
       ,[table_query4]
       ,[table_style1]
       ,[table_style2]
       ,[table_style3]
       ,[table_style4]
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
          ,target.explanatory_text5 =  source.explanatory_text5
          ,target.csv_toggle =  source.csv_toggle
          ,target.csv_query =  source.csv_query
          ,target.additional_attachment = source.additional_attachment
          ,target.table_query1 =  source.table_query1
          ,target.table_query2 =  source.table_query2
          ,target.table_query3 =  source.table_query3
          ,target.table_query4 =  source.table_query4
          ,target.table_style1 =  source.table_style1
          ,target.table_style2 =  source.table_style2
          ,target.table_style3 =  source.table_style3
          ,target.table_style4 =  source.table_style4
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
        ,[explanatory_text5]
        ,[csv_toggle]
        ,[csv_query]
        ,[additional_attachment]
        ,[table_query1]
        ,[table_query2]
        ,[table_query3]
        ,[table_query4]
        ,[table_style1]
        ,[table_style2]
        ,[table_style3]
        ,[table_style4]
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
        ,source.explanatory_text5
        ,source.csv_toggle
        ,source.csv_query
        ,source.additional_attachment
        ,source.table_query1
        ,source.table_query2
        ,source.table_query3
        ,source.table_query4
        ,source.table_style1
        ,source.table_style2
        ,source.table_style3
        ,source.table_style4
      );

  END

CLOSE db_cursor
DEALLOCATE db_cursor

