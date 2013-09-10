USE KIPP_NJ
GO

WITH roster AS
  (SELECT studentid
         ,c.grade_level
         ,c.schoolid
         ,s.lastfirst
         ,s.FIRST_NAME + ' ' + s.LAST_NAME AS name
         ,sch.abbreviation AS school
   FROM KIPP_NJ..COHORT$comprehensive_long#static c
   JOIN KIPP_NJ..SCHOOLS sch
     ON c.schoolid = sch.school_number
   JOIN KIPP_NJ..STUDENTS s
     ON c.studentid = s.id
    AND s.enroll_status = 0
    AND s.ID = 4772
   WHERE year = 2013
     AND rn = 1
     AND c.schoolid != 999999
     AND c.schoolid IN (73252, 133570965)
  )
 
  ,sri_lexile AS
    (SELECT *
     FROM OPENQUERY(KIPP_NWK, '
       SELECT *
       FROM sri_testing_history')
    )
    
SELECT roster.*
      ,gr.course_number
      ,gr.course_name
      ,gr.T1 AS cur_term_rdg_gr
      ,gr.Y1 AS y1_rdg_gr
      ,ele.grade_1 AS cur_term_rdg_hw_avg
      ,ele.simple_avg AS y1_rdg_hw_avg
      ,fp_base.letter_level AS fp_base_lettter
      ,fp_cur.letter_level AS fp_cur_letter
      ,CASE 
         WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.TestRITScore
         WHEN map_fall.TestRITScore IS NULL THEN map_spr.TestRITScore
         ELSE map_fall.TestRITScore
       END AS map_baseline
      ,cur_rit.TestRITScore AS cur_RIT
       --use MAP for lexile      
      ,CASE 
         WHEN map_fall.testritscore > map_spr.testritscore THEN map_fall.RITtoReadingScore
         WHEN map_fall.TestRITScore IS NULL THEN map_spr.RITtoReadingScore
         ELSE map_fall.RITtoReadingScore
       END AS lexile_baseline_MAP
       --readlive
      ,rl.wpm AS starting_fluency
      ,rl.wpm AS cur_fluency
 
       --AR cur
      ,ar_cur.words AS hex_words
      ,ar_cur.words_goal AS hex_goal
      ,ar_cur.ontrack_words AS hex_needed

FROM roster
--GRADES
LEFT OUTER JOIN KIPP_NJ..GRADES$DETAIL#MS gr
  ON roster.studentid = gr.studentid
 AND gr.credittype LIKE '%ENG%'

--HW
LEFT OUTER JOIN KIPP_NJ..GRADES$elements ele
  ON roster.studentid = ele.studentid
 AND gr.course_number = ele.course_number
 AND ele.pgf_type = 'H'
 AND ele.yearid = 23

--F&P
LEFT OUTER JOIN KIPP_NJ..LIT$FP_test_events_long#identifiers#static fp_base
  ON roster.studentid = fp_base.studentid
 AND fp_base.year = 2013
 AND fp_base.rn_asc = 1
LEFT OUTER JOIN KIPP_NJ..LIT$FP_test_events_long#identifiers#static fp_cur
  ON roster.studentid = fp_cur.studentid
 AND fp_cur.year = 2013
 AND fp_cur.rn_desc = 1

--RIT, NWEA LEXILE
LEFT OUTER JOIN KIPP_NJ..[MAP$comprehensive#identifiers] map_fall
  ON roster.studentid = map_fall.ps_studentid
 AND map_fall.measurementscale = 'Reading'
 AND map_fall.map_year_academic = 2013
 AND map_fall.TermName = 'Fall 2013-2014'

LEFT OUTER JOIN KIPP_NJ..[MAP$comprehensive#identifiers] map_spr
  ON roster.studentid = map_spr.ps_studentid
 AND map_spr.measurementscale = 'Reading'
 AND map_spr.map_year_academic = 2012
 AND map_spr.TermName = 'Spring 2012-2013'

--CURRENT NWEA RIT
LEFT OUTER JOIN       
    (SELECT sub_1.*
     FROM
          (SELECT ps_studentid
                 ,[map_year_academic]
                 ,[fallwinterspring]
                 ,[map_year]
                 ,[TermName]
                 ,[MeasurementScale]
                 ,[TestRITScore]
                 ,[RITtoReadingScore]
                 ,ROW_NUMBER () 
                    OVER (PARTITION BY ps_studentid 
                          ORDER BY map.teststartdate DESC) AS rn_desc
             FROM KIPP_NJ..MAP$comprehensive#identifiers map
             WHERE MeasurementScale = 'Reading'
               AND map_year_academic = 2013
           ) sub_1
     WHERE rn_desc = 1
     ) cur_rit
  ON roster.studentid = cur_rit.ps_studentid

LEFT OUTER JOIN KIPP_NJ..SRSLY_DIE_READLIVE rl
  ON CAST(roster.studentid AS NVARCHAR) = rl.studentid

--AR current
LEFT OUTER JOIN KIPP_NJ..[AR$progress_to_goals_long#static] ar_cur
  ON roster.studentid = ar_cur.studentid
 AND ar_cur.time_period_name = 'RT1'
 AND ar_cur.yearid = 2300


--LEFT OUTER JOIN sri_lexile
--  ON 1=2
