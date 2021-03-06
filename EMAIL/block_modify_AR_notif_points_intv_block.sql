/*
--to examine the queue
SELECT *
FROM KIPP_NJ..email$template_queue
ORDER BY id DESC

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
 ('Independent Reading: Triplett, Corey'
 ,'auto'
 ,'2014-04-14 06:40:00.000')

--to delete from the queue
DELETE 
FROM KIPP_NJ..email$template_queue
WHERE id = 1596

BEGIN TRANSACTION
DELETE
FROM KIPP_NJ..EMAIL$template_jobs
WHERE id = 
ROLLBACK TRANSACTION
--COMMIT TRANSACTION

--to send a job as a test
DECLARE @fake NVARCHAR(4000)
BEGIN

  EXEC dbo.sp_EMAIL$send_template_job
    @job_name = 'AR Progress Monitoring NCA Independent Reading: Richardson, Mimi'
   ,@send_again = @fake OUTPUT

END

*/


USE KIPP_NJ
GO

DECLARE @helper_group       NVARCHAR(50)
       ,@job_name_text      NVARCHAR(100)
       ,@email_list         VARCHAR(500)
       ,@standard_time      NVARCHAR(1000)
       ,@send_again         NVARCHAR(1000)
       ,@this_job_name      NCHAR(100)
       ,@curterm            NVARCHAR(10)

SET @standard_time = 'CASE
              WHEN DATEPART(WEEKDAY, GETDATE()) = 6
                THEN DATEADD(DAY, 3, 
                DateAdd(mi, 45, DateAdd(hh, 10,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
              ELSE DATEADD(DAY, 1, 
                DateAdd(mi, 45, DateAdd(hh, 10,
                  (DateAdd(yy, DATEPART(YYYY, GETDATE())-1900, 
                     DateAdd(m,  DATEPART(MM, GETDATE()) - 1, DATEPART(DD, GETDATE()) - 1))) 
                  ))
                )
            END'
    
SELECT @curterm = time_per_name FROM REPORTING$dates WHERE schoolid = 73253 AND identifier = 'RT' AND GETDATE() >= start_date AND GETDATE() <= end_date

DECLARE db_cursor CURSOR FOR  
  SELECT helper_group
        ,job_name_text
          /*-- Override: --*/
        --,'amartin@teamschools.org;cbini@teamschools.org' AS email_list
        --,'cbini@teamschools.org' AS email_list
        --,'amartin@teamschools.org;tdockins@teamschools.org;dglaubinger@teamschools.org' AS email_list
        ,email_list
        ,send_again
  FROM
     (SELECT 'AR Intervention: McCormack, Jessica' AS helper_group
            ,'' AS job_name_text
            ,'jmccormack@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'AR Intervention: Proto, Marisa' AS helper_group
            ,'' AS job_name_text
            ,'mproto@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'AR Intervention: Sgalambro, Jonathan' AS helper_group
            ,'' AS job_name_text
            ,'jsgalambro@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'AR Intervention: White, Charisse' AS helper_group
            ,'' AS job_name_text
            ,'cwhite@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Bernard, Pascale' AS helper_group
            ,'' AS job_name_text
            ,'pbernard@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Blasi, Faith' AS helper_group
            ,'' AS job_name_text
            ,'fblasi@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Bolden, Sharmaine' AS helper_group
            ,'' AS job_name_text
            ,'sbolden@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Cangialosi, Vincent' AS helper_group
            ,'' AS job_name_text
            ,'vcangialosi@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Fleming, Jeff' AS helper_group
            ,'' AS job_name_text
            ,'jfleming@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Galbraith, Jay' AS helper_group
            ,'' AS job_name_text
            ,'jgalbraith@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Ibeh, Katie' AS helper_group
            ,'' AS job_name_text
            ,'kibeh@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION      
      SELECT 'Independent Reading: Lisa Cucciniello' AS helper_group
            ,'' AS job_name_text
            ,'lcucciniello@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Melgarejo, Jose' AS helper_group
            ,'' AS job_name_text
            ,'jmelgarejo@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Morrison, Jessica' AS helper_group
            ,'' AS job_name_text
            ,'jmorrison@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: OLeary, Kaitlyn' AS helper_group
            ,'' AS job_name_text
            ,'koleary@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Richardson, Deanna' AS helper_group
            ,'' AS job_name_text
            ,'drichardson@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Richardson, Mimi' AS helper_group
            ,'' AS job_name_text
            ,'mrichardson@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Sarah Gray' AS helper_group
            ,'' AS job_name_text
            ,'sgray@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Weissglass, Elysha' AS helper_group
            ,'' AS job_name_text
            ,'EWeissglass@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION      
      SELECT 'Independent Reading: Triplett, Corey' AS helper_group
            ,'' AS job_name_text
            ,'CTriplett@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Reading Enrichment: Halpern, Katelyn' AS helper_group
            ,'' AS job_name_text
            ,'khalpern@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Reading Enrichment: Love/Taylor' AS helper_group
            ,'' AS job_name_text
            ,'slove@teamschools.org;ktaylor@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Reading Enrichment: Proft, Kristin' AS helper_group
            ,'' AS job_name_text
            ,'kproft@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Bonnet, Andrea' AS helper_group
            ,'' AS job_name_text
            ,'abonnet@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Cardosa, Karen' AS helper_group
            ,'' AS job_name_text
            ,'kcardosa@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Frohman, Terri' AS helper_group
            ,'' AS job_name_text
            ,'tfrohman@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Gillam, Norah' AS helper_group
            ,'' AS job_name_text
            ,'ngillam@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Goodlow, Gigg' AS helper_group
            ,'' AS job_name_text
            ,'ggoodlow@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Hawthorn, Eric' AS helper_group
            ,'' AS job_name_text
            ,'ehawthorn@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Lopez, Lynette' AS helper_group
            ,'' AS job_name_text
            ,'llopez@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Mustapha, Sherry' AS helper_group
            ,'' AS job_name_text
            ,'smustapha@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Rogers, Lavinia' AS helper_group
            ,'' AS job_name_text
            ,'lrogers@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Teichman, Elliot' AS helper_group
            ,'' AS job_name_text
            ,'eteichman@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Thaler, Melissa' AS helper_group
            ,'' AS job_name_text
            ,'mthaler@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Woolgar, Chris' AS helper_group
            ,'' AS job_name_text
            ,'cwoolgar@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Apollon, Roger' AS helper_group
            ,'' AS job_name_text
            ,'rapollon@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'AR Intervention: Cham, Rebecca' AS helper_group
            ,'' AS job_name_text
            ,'rcham@teamschools.org;kswearingen@teamschools.org' AS email_list
            ,@standard_time AS send_again
      UNION
      SELECT 'ReadLIVE: Walters, Anthony' AS helper_group
                    ,'' AS job_name_text
                    ,'awalters@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'ReadLIVE: DeFinis, Victoria' AS helper_group
                    ,'' AS job_name_text
                    ,'vdefinis@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'Math RtI: Wright, Bri' AS helper_group
                    ,'' AS job_name_text
                    ,'bwright@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'Study Hall: Blasi, Faith' AS helper_group
                    ,'' AS job_name_text
                    ,'fblasi@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'ReadLIVE: Galbraith, Jay' AS helper_group
                    ,'' AS job_name_text
                    ,'jgalbraith@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'Independent Reading: Cham, Rebecca' AS helper_group
                    ,'' AS job_name_text
                    ,'rcham@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'ReadLIVE: Scorzafava, Tina' AS helper_group
                    ,'' AS job_name_text
                    ,'tscorzafava@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'Math RtI: Kendig, Ashley' AS helper_group
                    ,'' AS job_name_text
                    ,'akendig@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'Math RtI: Esteban/McKenzie' AS helper_group
                    ,'' AS job_name_text
                    ,'jesteban@teamschools.org;bmckenzie@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
      UNION
      SELECT 'Math RtI: Dockins' AS helper_group
                    ,'' AS job_name_text
                    ,'tdockins@teamschools.org;kswearingen@teamschools.org' AS email_list
                    ,@standard_time AS send_again
     ) sub

OPEN db_cursor
WHILE 1=1
  BEGIN

   FETCH NEXT FROM db_cursor INTO @helper_group, @job_name_text, @email_list, @send_again

   IF @@fetch_status <> 0
     BEGIN
        BREAK
     END     

   SET @this_job_name = 'AR Progress Monitoring NCA ' + @helper_group + @job_name_text 

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
       ,'SELECT CASE WHEN AVG(ar.stu_status_points_numeric) IS NULL THEN CAST(0 AS VARCHAR) ELSE CAST(CAST(ROUND(AVG(ar.stu_status_points_numeric + 0.0) * 100,0) AS FLOAT) AS NVARCHAR) + ''%'' END AS pct_on_track
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv
             ON ar.studentid = intv.studentid
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$assignments] a
             ON intv.assignmentid = a.assignmentid
            AND a.subgroup = ''' + @helper_group + '''
          WHERE yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''' + @curterm + '''
        '
        --stat query 2
       ,'SELECT CASE WHEN AVG(ar.points) IS NULL THEN CAST(0 AS FLOAT) ELSE replace(convert(varchar,convert(Money, CAST(ROUND(AVG(ar.points),1) AS FLOAT)),1),''.00'','''') END AS avg_points
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv
             ON ar.studentid = intv.studentid
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$assignments] a
             ON intv.assignmentid = a.assignmentid
            AND a.subgroup = ''' + @helper_group + '''
          WHERE yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''' + @curterm + '''
         '
         --stat query 3
        ,'SELECT CASE WHEN AVG(ar.mastery) IS NULL THEN 0 ELSE CAST(ROUND(AVG(ar.mastery),1) AS FLOAT) END AS avg_mastery
            FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv
             ON ar.studentid = intv.studentid
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$assignments] a
             ON intv.assignmentid = a.assignmentid
            AND a.subgroup = ''' + @helper_group + '''
          WHERE yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''' + @curterm + '''
         '
         --stat query 4
        ,'SELECT CASE WHEN AVG(ar.pct_fiction) IS NULL THEN 0 ELSE CAST(ROUND(AVG(ar.pct_fiction),1) AS FLOAT) END AS avg_fiction
            FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv
             ON ar.studentid = intv.studentid
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$assignments] a
             ON intv.assignmentid = a.assignmentid
            AND a.subgroup = ''' + @helper_group + '''
          WHERE yearid = 2300
            AND time_hierarchy = 2
            AND time_period_name = ''' + @curterm + '''
         '
         --stat labels 1-4
        ,'% On Track'
        ,'Avg points'
        ,'Avg Mastery'
        ,'Avg % Fiction'
        --image stuff
        ,2
        --dynamic filepath
        ,'\\WINSQL01\r_images\DATEKEY_ar_prog_monitoring_points_group_' + REPLACE(REPLACE(REPLACE(@helper_group, ' ', '_'), '/', '_'), ':', '_') + '.png'
        ,'\\WINSQL01\r_images\DATEKEY_ar_prog_monitoring_avg_lexile_group_' + REPLACE(REPLACE(REPLACE(@helper_group, ' ', '_'), '/', '_'), ':', '_') + '.png'

        --regular text (use single space for nulls)
        --regular text (use single space for nulls)
        ,'Students currently ON track to meet their quarterly goal:'
        ,'Students currently OFF track to meet their quarterly goal:'
        ,' '
        ,' '
        ,' '
        --csv stuff
        ,'On'
        --csv query -- all students, no restriction on status
        ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                 ,CAST(s.grade_level AS NVARCHAR) AS ''grade''
                 ,ar.time_period_name AS term
                 ,replace(convert(varchar,convert(Money, ar.points_goal),1),''.00'','''') AS ''points_goal''
                 ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS ''points''        
                 ,replace(convert(varchar,convert(Money, CAST(ROUND(ar.ontrack_points, 0) AS FLOAT)),1),''.00'','''') AS ''cur_target''
                 ,ar.stu_status_points AS ''status''
                 ,ar.mastery
                 ,ar.avg_lexile
                 ,ar.pct_fiction
                 ,ar.n_passed AS passed
                 ,ar.n_total AS total
                 ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                 ,ar.last_book
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv
             ON ar.studentid = intv.studentid
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$assignments] a
             ON intv.assignmentid = a.assignmentid
            AND a.subgroup = ''' + @helper_group + '''
          WHERE ar.yearid = 2300
            AND ar.time_hierarchy = 2
            AND ar.time_period_name = ''' + @curterm + '''
           ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
          '
          --table query 1
         ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                 ,CAST(s.grade_level AS NVARCHAR) AS grade
                 ,ar.time_period_name AS term
                 ,replace(convert(varchar,convert(Money, ar.points_goal),1),''.00'','''') AS points_goal
                 ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS cur_points          
                 ,replace(convert(varchar,convert(Money, ar_year.points),1),''.00'','''') AS year_points
                 ,ar.mastery
                 ,ar.avg_lexile AS ''Avg Lexile''
                 ,ar.pct_fiction AS ''Pct Fiction''
                 ,ar.n_passed AS passed
                 ,ar.n_total AS total
                 ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                 ,ar.last_book
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv
             ON ar.studentid = intv.studentid
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$assignments] a
             ON intv.assignmentid = a.assignmentid
            AND a.subgroup = ''' + @helper_group + '''
          LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_year
            ON ar.studentid = ar_year.studentid
           AND ar_year.yearid = 2300
           AND ar_year.time_hierarchy = 1
          WHERE ar.yearid = 2300
            AND ar.time_hierarchy = 2
            AND ar.time_period_name = ''' + @curterm + '''
            AND ar.stu_status_points_numeric = 1
           ORDER BY DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 DESC
          '
          --table query 2
         ,'SELECT TOP 1000000000 s.first_name + '' '' + s.last_name AS name
                 ,CAST(s.grade_level AS NVARCHAR) AS grade
                 ,ar.time_period_name AS term
                 ,replace(convert(varchar,convert(Money, ar.points_goal),1),''.00'','''') AS points_goal
                 ,replace(convert(varchar,convert(Money, ar.points),1),''.00'','''') AS cur_points          
                 ,replace(convert(varchar,convert(Money, ar_year.points),1),''.00'','''') AS year_points
                 ,ar.mastery
                 ,ar.avg_lexile AS ''Avg Lexile''
                 ,ar.pct_fiction AS ''Pct Fiction''
                 ,ar.n_passed AS passed
                 ,ar.n_total AS total
                 ,DATEDIFF(day, ar.last_book_date, GETDATE()) - 1 AS days_ago
                 ,ar.last_book
           FROM KIPP_NJ..AR$progress_to_goals_long#static ar
           JOIN KIPP_NJ..STUDENTS s
             ON ar.studentid = s.id
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$intervention_block#NCA] intv
             ON ar.studentid = intv.studentid
           JOIN KIPP_NJ..[CUSTOM_GROUPINGS$assignments] a
             ON intv.assignmentid = a.assignmentid
            AND a.subgroup = ''' + @helper_group + '''
          LEFT OUTER JOIN KIPP_NJ..AR$progress_to_goals_long#static ar_year
            ON ar.studentid = ar_year.studentid
           AND ar_year.yearid = 2300
           AND ar_year.time_hierarchy = 1
          WHERE ar.yearid = 2300
            AND ar.time_hierarchy = 2
            AND ar.time_period_name = ''' + @curterm + '''
            AND ar.stu_status_points_numeric = 0
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

