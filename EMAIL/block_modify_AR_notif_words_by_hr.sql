/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue WITH (NOLOCK)
WHERE id >= 5100
ORDER BY job_name

--to examine the jobs
SELECT *
FROM KIPP_NJ..email$template_jobs
ORDER BY id

--to push a job into the queue for the first time
INSERT INTO KIPP_NJ..email$template_queue
  (job_name
  ,run_type
  ,send_at)
VALUES
 ('AR Progress Monitoring Rise Hr Jones 6'
 ,'auto'
 ,'2014-11-14 06:40:00.000')

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
    @job_name = 'AR Progress Monitoring Rise Hr Elguero 7'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Hr Joseph 7'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Hr Sorresso 7'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Hr Jones 6'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Hr Geiger 5'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Hr Pasheluk 5'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Hr Williams 5'
   ,@send_again = @fake OUTPUT

END
 
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Gr 5'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Gr 6'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Gr 7'
   ,@send_again = @fake OUTPUT

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring Rise Gr 8'
   ,@send_again = @fake OUTPUT

END



*/

USE KIPP_NJ
GO

DECLARE @helper_grade_level INT
       ,@helper_schoolid    INT
       ,@helper_school      NVARCHAR(10)
       ,@helper_hr_last     NVARCHAR(50)
       ,@helper_term        VARCHAR(5)
       ,@helper_term_long   VARCHAR(20)
       ,@job_name_text      NVARCHAR(100)
       ,@email_list         VARCHAR(500)
       ,@standard_time      VARCHAR(1000)
       ,@send_again         VARCHAR(1000)
       ,@this_job_name      NCHAR(100)

SET @standard_time = 'CASE
              WHEN DATEPART(WEEKDAY, GETDATE()) = 6
                THEN DATEADD(DAY, 3, 
                DateAdd(mi, 40, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
              ELSE DATEADD(DAY, 1, 
                DateAdd(mi, 40, DateAdd(hh, 6,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
            END'

DECLARE db_cursor CURSOR FOR  
  SELECT grade_level
        ,schoolid
        ,school
        ,hr_last
        ,job_name_text
         --override:
        --,'amartin@teamschools.org' AS email_list
        --,'cbini@teamschools.org' AS email_list
        ,email_list
        ,send_again
        ,rt
        ,term_long
  FROM
     (SELECT 5 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'Pasheluk' AS hr_last
            ,'' AS job_name_text
            ,'kpasheluk@teamschools.org;kgalarza@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,'RT4' AS rt
            ,'Hexameter 4' AS term_long
       UNION
       SELECT 5 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'Geiger' AS hr_last
            ,'' AS job_name_text
            ,'kpasheluk@teamschools.org;ageiger@teamschools.org;kgalarza@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,'RT4' AS rt
            ,'Hexameter 4' AS term_long
       UNION
       SELECT 5 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'Williams' AS hr_last
            ,'' AS job_name_text
            ,'kpasheluk@teamschools.org;swilliams@teamschools.org;kgalarza@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,'RT4' AS rt
            ,'Hexameter 4' AS term_long
       UNION
       SELECT 6 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'Jones' AS hr_last
            ,'' AS job_name_text
            ,'jjones@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,'RT4' AS rt
            ,'Hexameter 4' AS term_long
       UNION
       SELECT 7 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'Joseph' AS hr_last
            ,'' AS job_name_text
            ,'ljoseph@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,'RT4' AS rt
            ,'Hexameter 4' AS term_long
       UNION
       SELECT 7 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'Sorresso' AS hr_last
            ,'' AS job_name_text
            ,'msorresso@teamschools.org;ljoseph@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,'RT4' AS rt
            ,'Hexameter 4' AS term_long
       UNION
       SELECT 7 AS grade_level
            ,73252 AS schoolid
            ,'Rise' AS school
            ,'Elguero' AS hr_last
            ,'' AS job_name_text
            ,'melguero@teamschools.org;ljoseph@teamschools.org' AS email_list
            ,@standard_time AS send_again
            ,'RT4' AS rt
            ,'Hexameter 4' AS term_long
     ) sub

OPEN db_cursor
WHILE 1=1
  BEGIN

   FETCH NEXT FROM db_cursor INTO @helper_grade_level, @helper_schoolid, @helper_school, @helper_hr_last, @job_name_text, @email_list, @send_again, @helper_term, @helper_term_long

   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   SET @this_job_name = 'AR Progress Monitoring ' + CAST(@helper_school AS NVARCHAR) + ' Hr ' + @helper_hr_last + ' ' + CAST(@helper_grade_level AS NVARCHAR) + @job_name_text

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
          ,4
           --stat query 1
          ,'SELECT CAST(CAST(ROUND(AVG(ar.stu_status_words_numeric + 0.0) * 100,0) AS FLOAT) AS NVARCHAR) + ''%'' AS pct_on_track
              FROM KIPP_NJ..AR$progress_to_goals_long#static ar
              JOIN KIPP_NJ..STUDENTS s
                ON ar.studentid = s.id
               AND s.enroll_status = 0
               AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
              JOIN KIPP_NJ..CC cc
                ON s.id = cc.studentid
               AND cc.dateenrolled <= GETDATE()
               AND cc.dateleft >= GETDATE()
              JOIN KIPP_NJ..COURSES
                ON cc.course_number = courses.course_number
               AND courses.course_number LIKE ''%HR%''
              JOIN KIPP_NJ..SECTIONS sect
                ON cc.sectionid = sect.id
              JOIN KIPP_NJ..TEACHERS t
                ON sect.teacher = t.id
               AND t.last_name = ''' + @helper_hr_last + '''
             WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
               AND yearid = 2400
               AND time_hierarchy = 2
               AND time_period_name = ''' + @helper_term + '''
           '
           --stat query 2
          ,'SELECT replace(convert(varchar,convert(Money, CAST(ROUND(AVG(ar.words),1) AS FLOAT)),1),''.00'','''') AS avg_words
              FROM KIPP_NJ..AR$progress_to_goals_long#static ar
              JOIN KIPP_NJ..STUDENTS s
                ON ar.studentid = s.id
               AND s.enroll_status = 0
               AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
              JOIN KIPP_NJ..CC cc
                ON s.id = cc.studentid
               AND cc.dateenrolled <= GETDATE()
               AND cc.dateleft >= GETDATE()
              JOIN KIPP_NJ..COURSES
                ON cc.course_number = courses.course_number
               AND courses.course_number LIKE ''%HR%''
              JOIN KIPP_NJ..SECTIONS sect
                ON cc.sectionid = sect.id
              JOIN KIPP_NJ..TEACHERS t
                ON sect.teacher = t.id
               AND t.last_name = ''' + @helper_hr_last + '''
             WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
               AND yearid = 2400
               AND time_hierarchy = 2
               AND time_period_name = ''' + @helper_term + '''
            '
            --stat query 3
           ,'SELECT CAST(ROUND(AVG(ar.mastery),1) AS FLOAT) AS avg_mastery
               FROM KIPP_NJ..AR$progress_to_goals_long#static ar
               JOIN KIPP_NJ..STUDENTS s
                 ON ar.studentid = s.id
               AND s.enroll_status = 0
               AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
              JOIN KIPP_NJ..CC cc
                ON s.id = cc.studentid
               AND cc.dateenrolled <= GETDATE()
               AND cc.dateleft >= GETDATE()
              JOIN KIPP_NJ..COURSES
                ON cc.course_number = courses.course_number
               AND courses.course_number LIKE ''%HR%''
              JOIN KIPP_NJ..SECTIONS sect
                ON cc.sectionid = sect.id
              JOIN KIPP_NJ..TEACHERS t
                ON sect.teacher = t.id
               AND t.last_name = ''' + @helper_hr_last + '''
             WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                AND yearid = 2400
                AND time_hierarchy = 2
                AND time_period_name = ''' + @helper_term + '''
            '
            --stat query 4
           ,'SELECT CAST(ROUND(AVG(ar.pct_fiction),1) AS FLOAT) AS avg_mastery
               FROM KIPP_NJ..AR$progress_to_goals_long#static ar
               JOIN KIPP_NJ..STUDENTS s
                 ON ar.studentid = s.id
               AND s.enroll_status = 0
               AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
              JOIN KIPP_NJ..CC cc
                ON s.id = cc.studentid
               AND cc.dateenrolled <= GETDATE()
               AND cc.dateleft >= GETDATE()
              JOIN KIPP_NJ..COURSES
                ON cc.course_number = courses.course_number
               AND courses.course_number LIKE ''%HR%''
              JOIN KIPP_NJ..SECTIONS sect
                ON cc.sectionid = sect.id
              JOIN KIPP_NJ..TEACHERS t
                ON sect.teacher = t.id
               AND t.last_name = ''' + @helper_hr_last + '''
             WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                AND yearid = 2400
                AND time_hierarchy = 2
                AND time_period_name = ''' + @helper_term + '''
            '
            --stat labels 1-4
           ,'% On Track'
           ,'Avg Words'
           ,'Avg Mastery'
           ,'Avg % Fiction'
           --image stuff
           ,0
           --dynamic filepath
           ,' '
           --,'\\WINSQL01\r_images\DATEKEY_ar_prog_monitoring_pct_fiction_' + @helper_school + '_gr_' + CAST(@helper_grade_level AS NVARCHAR) + '.png'
           ,' '
           --regular text (use single space for nulls)
           ,'Students currently ON track to meet their goal:'
           ,'Students currently OFF track to meet their goal:'
           ,' '
           ,' '
           ,' '
           --csv stuff
           ,'On'
           --csv query -- all students, no restriction on status
           ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                    ,s.grade_level AS grade
                    ,ar.time_period_name AS term
                    ,replace(convert(varchar,convert(Money, ar.words_goal),1),''.00'','''') AS hex_goal
                    ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS hex_words          
                    ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_words, 0) AS FLOAT)),1),''.00'','''') AS ''cur_target''
                    ,ar.stu_status_words AS status
                    ,ar.mastery
                    ,ar.avg_lexile AS ''Avg Lexile''
                    ,ar.pct_fiction AS ''Pct Fiction''
                    ,ar.n_passed AS passed
                    ,ar.n_total AS total
                    ,replace(convert(varchar,convert(Money, ar_year.words),1),''.00'','''') AS year_words         
                    ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                    ,ar.last_book
              FROM KIPP_NJ..AR$progress_to_goals_long#static ar
              JOIN KIPP_NJ..STUDENTS s
                ON ar.studentid = s.id
               AND s.enroll_status = 0
               AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
              JOIN KIPP_NJ..CC cc
                ON s.id = cc.studentid
               AND cc.dateenrolled <= GETDATE()
               AND cc.dateleft >= GETDATE()
              JOIN KIPP_NJ..COURSES
                ON cc.course_number = courses.course_number
               AND courses.course_number LIKE ''%HR%''
              JOIN KIPP_NJ..SECTIONS sect
                ON cc.sectionid = sect.id
              JOIN KIPP_NJ..TEACHERS t
                ON sect.teacher = t.id
               AND t.last_name = ''' + @helper_hr_last + '''
              LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_year
                ON ar.studentid = ar_year.studentid
               AND ar_year.yearid = 2400
               AND ar_year.time_hierarchy = 1
              WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                AND ar.yearid = 2400
                AND ar.time_hierarchy = 2
                AND ar.time_period_name = ''' + @helper_term + '''
              ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
             '
            --table query 1
            ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                    ,s.grade_level AS grade
                    ,ar.time_period_name AS term
                    ,replace(convert(varchar,convert(Money, ar.words_goal),1),''.00'','''') AS hex_goal
                    ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS hex_words          
                    ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_words, 0) AS FLOAT)),1),''.00'','''') AS ''cur_target''
                    ,ar.stu_status_words AS ''Stu Status''
                    ,ar.mastery
                    ,ar.avg_lexile AS ''Avg Lexile''
                    ,ar.pct_fiction AS ''Pct Fiction''
                    ,ar.n_passed AS passed
                    ,ar.n_total AS total
                    ,replace(convert(varchar,convert(Money, ar_year.words),1),''.00'','''') AS year_words         
                    ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                    ,ar.last_book
              FROM KIPP_NJ..AR$progress_to_goals_long#static ar
              JOIN KIPP_NJ..STUDENTS s
                ON ar.studentid = s.id
               AND s.enroll_status = 0
               AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
              JOIN KIPP_NJ..CC cc
                ON s.id = cc.studentid
               AND cc.dateenrolled <= GETDATE()
               AND cc.dateleft >= GETDATE()
              JOIN KIPP_NJ..COURSES
                ON cc.course_number = courses.course_number
               AND courses.course_number LIKE ''%HR%''
              JOIN KIPP_NJ..SECTIONS sect
                ON cc.sectionid = sect.id
              JOIN KIPP_NJ..TEACHERS t
                ON sect.teacher = t.id
               AND t.last_name = ''' + @helper_hr_last + '''
              LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_year
                ON ar.studentid = ar_year.studentid
               AND ar_year.yearid = 2400
               AND ar_year.time_hierarchy = 1
              WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                AND ar.yearid = 2400
                AND ar.time_hierarchy = 2
                AND ar.time_period_name = ''' + @helper_term + '''
                AND ar.stu_status_words_numeric = 1
              ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
             '
             --table query 2
            ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                    ,s.grade_level AS grade
                    ,ar.time_period_name AS term
                    ,replace(convert(varchar,convert(Money, ar.words_goal),1),''.00'','''') AS hex_goal
                    ,replace(convert(varchar,convert(Money, ar.words),1),''.00'','''') AS hex_words     
                    ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_words, 0) AS FLOAT)),1),''.00'','''') AS ''cur_target''
                    ,ar.stu_status_words AS ''Stu Status''
                    ,ar.mastery
                    ,ar.avg_lexile AS ''Avg Lexile''
                    ,ar.pct_fiction AS ''Pct Fiction''
                    ,ar.n_passed AS passed
                    ,ar.n_total AS total
                    ,replace(convert(varchar,convert(Money, ar_year.words),1),''.00'','''') AS year_words         
                    ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                    ,ar.last_book
              FROM KIPP_NJ..AR$progress_to_goals_long#static ar
              JOIN KIPP_NJ..STUDENTS s
                ON ar.studentid = s.id
               AND s.enroll_status = 0
               AND s.grade_level = ' + CAST(@helper_grade_level AS NVARCHAR) + '
              JOIN KIPP_NJ..CC cc
                ON s.id = cc.studentid
               AND cc.dateenrolled <= GETDATE()
               AND cc.dateleft >= GETDATE()
              JOIN KIPP_NJ..COURSES
                ON cc.course_number = courses.course_number
               AND courses.course_number LIKE ''%HR%''
              JOIN KIPP_NJ..SECTIONS sect
                ON cc.sectionid = sect.id
              JOIN KIPP_NJ..TEACHERS t
                ON sect.teacher = t.id
               AND t.last_name = ''' + @helper_hr_last + '''
              LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_year
                ON ar.studentid = ar_year.studentid
               AND ar_year.yearid = 2400
               AND ar_year.time_hierarchy = 1
              WHERE ar.schoolid = ' + CAST(@helper_schoolid AS NVARCHAR) + '
                AND ar.yearid = 2400
                AND ar.time_hierarchy = 2
                AND ar.time_period_name = ''' + @helper_term + '''
                AND ar.stu_status_words_numeric = 0
              ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
              '
             --table query 3
            ,' '
             --table query 4
            ,' '
             --table style parameters
            ,'CSS_small'
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
       ,[explanatory_text5]
       ,[csv_toggle]
       ,[csv_query]
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

