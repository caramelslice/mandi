USE KIPP_NJ
GO

ALTER VIEW REPORTING$report_card_term#NCA AS

WITH curterm AS (
  SELECT 'RT' + CONVERT(VARCHAR,(RIGHT(time_per_name,1) - 1)) AS time_per_name
        ,'Q' + CONVERT(VARCHAR,(RIGHT(alt_name,1) - 1)) AS term
  FROM KIPP_NJ..REPORTING$dates WITH(NOLOCK)
  WHERE identifier = 'RT'
    AND academic_year = KIPP_NJ.dbo.fn_Global_Academic_Year()
    AND schoolid = 73253
    AND start_date <= CONVERT(DATE,GETDATE())
    AND end_date >= CONVERT(DATE,GETDATE())
 )

,roster AS (
  SELECT co.schoolid
        ,co.student_number AS base_student_number
        ,co.studentid AS base_studentid
        ,co.lastfirst AS stu_lastfirst
        ,co.first_name AS stu_firstname
        ,co.last_name AS stu_lastname
        ,co.grade_level AS stu_grade_level
        ,co.FAMILY_WEB_ID AS web_id
        ,co.FAMILY_WEB_PASSWORD AS web_password
        ,co.student_web_id AS student_web_id
        ,co.student_web_password AS student_web_password
        ,co.street
        ,co.city
        ,co.home_phone
        ,co.advisor
        ,co.advisor_email
        ,co.advisor_cell
        ,co.mother_cell
        ,COALESCE(co.mother_home, co.mother_day) AS mother_daytime
        ,co.father_cell
        ,COALESCE(co.father_home, co.father_day) AS father_daytime
        ,co.GUARDIANEMAIL           
        ,co.SPEDLEP AS SPED
        ,co.lunch_balance AS lunch_balance
        ,curterm.term AS curterm
        ,curterm.time_per_name AS rt
        ,CONVERT(VARCHAR,DATENAME(MONTH,GETDATE())) + ' ' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())) + ', ' + CONVERT(VARCHAR,DATEPART(YEAR,GETDATE())) AS today_words
  FROM KIPP_NJ..COHORT$identifiers_long#static co WITH (NOLOCK)
  JOIN curterm
    ON 1 = 1  
  WHERE year = dbo.fn_Global_Academic_Year()
    AND co.rn = 1
    AND co.schoolid = 73253    
 )

,comments AS (
  SELECT sec.schoolid
        ,sec.studentid
        ,sec.student_number
        ,sec.course_number
        ,sec.sectionid
        ,sec.term
        ,comm.teacher_comment
        ,comm.advisor_comment
  FROM GRADES$sections_by_term sec WITH(NOLOCK)
  JOIN PS$comments#static comm WITH(NOLOCK)
    ON sec.studentid = comm.studentid
   AND sec.course_number = comm.course_number
   AND sec.sectionid = comm.sectionid
   AND sec.term = comm.term
  WHERE sec.term IN (SELECT term FROM curterm)
 )  

SELECT roster.*

--Attendance & Tardies
--ATT_MEM$attendance_percentages
--ATT_MEM$attendance_counts      
    
    /*--Year--*/
      ,att_counts.y1_abs_all AS Y1_absences_total
      ,att_counts.y1_a AS Y1_absences_undoc
      ,ROUND(att_pct.Y1_att_pct_total,0) AS Y1_att_pct_total
      ,ROUND(att_pct.Y1_att_pct_undoc,0) AS Y1_att_pct_undoc      
      ,att_counts.y1_t_all AS Y1_tardies_total
      ,ROUND(att_pct.Y1_tardy_pct_total,0) AS Y1_tardy_pct_total      

    /*--Current--*/            
      --CUR--
      -- HARD CODED TEMPORARILY, CURTERM IS ACTUAL CURTERM, NOT PREVIOUS TERM
      ,att_counts.RT2_ABS_ALL AS curterm_absences_total
      ,att_counts.RT2_A AS curterm_absences_undoc
      ,ROUND(att_pct.RT2_att_pct_total,0) AS curterm_att_pct_total
      ,ROUND(att_pct.RT2_att_pct_undoc,0) AS curterm_att_pct_undoc      
      ,att_counts.RT2_T_ALL AS curterm_tardies_total
      ,ROUND(att_pct.RT2_tardy_pct_total,0) AS curterm_tardy_pct_total
      
      
--GPA
--GPA$detail#nca
--GPA$cumulative#NCA
    /*--Academic Year/Current Term--*/      
      ,gpa_long.GPA_all AS gpa_curterm
      ,nca_gpa.gpa_Y1
      /*--Cumulative--*/
      ,gpa_cumulative.cumulative_Y1_gpa      
      
--Course Grades
--GRADES$wide_all
    /*--RC1--*/
      ,gr_wide.rc1_course_name
      ,gr_wide.rc1_teacher_last      
      
      ,ROUND(gr_wide.rc1_q1,0) AS rc1_q1_term_pct
      ,ROUND(gr_wide.rc1_q2,0) AS rc1_q2_term_pct
      ,ROUND(gr_wide.rc1_q3,0) AS rc1_q3_term_pct
      ,ROUND(gr_wide.rc1_q4,0) AS rc1_q4_term_pct
            
      ,ROUND(gr_wide.rc1_y1,0) AS rc1_y1_pct
      ,gr_wide.rc1_y1_ltr
      ,gr_wide.rc1_credit_hours_Y1
      ,gr_wide.rc1_gpa_points_Y1      
      --,CASE WHEN gr_wide.rc1_y1 >= 70 THEN gr_wide.rc1_credit_hours_Y1 ELSE NULL END AS rc1_earned_crhrs

    /*--RC2--*/
      ,gr_wide.RC2_course_name
      ,gr_wide.RC2_teacher_last      
      
      ,ROUND(gr_wide.RC2_q1,0) AS RC2_q1_term_pct
      ,ROUND(gr_wide.RC2_q2,0) AS RC2_q2_term_pct
      ,ROUND(gr_wide.RC2_q3,0) AS RC2_q3_term_pct
      ,ROUND(gr_wide.RC2_q4,0) AS RC2_q4_term_pct
      
      ,ROUND(gr_wide.RC2_y1,0) AS RC2_y1_pct
      ,gr_wide.RC2_y1_ltr
      ,gr_wide.RC2_credit_hours_Y1
      ,gr_wide.RC2_gpa_points_Y1
      --,CASE WHEN gr_wide.RC2_y1 >= 70 THEN gr_wide.RC2_credit_hours_Y1 ELSE NULL END AS RC2_earned_crhrs

    /*--RC3--*/
      ,gr_wide.RC3_course_name
      ,gr_wide.RC3_teacher_last
      
      ,ROUND(gr_wide.RC3_q1,0) AS RC3_q1_term_pct
      ,ROUND(gr_wide.RC3_q2,0) AS RC3_q2_term_pct
      ,ROUND(gr_wide.RC3_q3,0) AS RC3_q3_term_pct
      ,ROUND(gr_wide.RC3_q4,0) AS RC3_q4_term_pct
      
      ,ROUND(gr_wide.RC3_y1,0) AS RC3_y1_pct
      ,gr_wide.RC3_y1_ltr
      ,gr_wide.RC3_credit_hours_Y1
      ,gr_wide.RC3_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC3_y1 >= 70 THEN gr_wide.RC3_credit_hours_Y1 ELSE NULL END AS RC3_earned_crhrs

    /*--RC4--*/
      ,gr_wide.RC4_course_name
      ,gr_wide.RC4_teacher_last
      
      ,ROUND(gr_wide.RC4_q1,0) AS RC4_q1_term_pct
      ,ROUND(gr_wide.RC4_q2,0) AS RC4_q2_term_pct
      ,ROUND(gr_wide.RC4_q3,0) AS RC4_q3_term_pct
      ,ROUND(gr_wide.RC4_q4,0) AS RC4_q4_term_pct
      
      ,ROUND(gr_wide.RC4_y1,0) AS RC4_y1_pct
      ,gr_wide.RC4_y1_ltr
      ,gr_wide.RC4_credit_hours_Y1
      ,gr_wide.RC4_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC4_y1 >= 70 THEN gr_wide.RC4_credit_hours_Y1 ELSE NULL END AS RC4_earned_crhrs

    /*--RC5--*/
      ,gr_wide.RC5_course_name
      ,gr_wide.RC5_teacher_last
      
      ,ROUND(gr_wide.RC5_q1,0) AS RC5_q1_term_pct
      ,ROUND(gr_wide.RC5_q2,0) AS RC5_q2_term_pct
      ,ROUND(gr_wide.RC5_q3,0) AS RC5_q3_term_pct
      ,ROUND(gr_wide.RC5_q4,0) AS RC5_q4_term_pct
      
      ,ROUND(gr_wide.RC5_y1,0) AS RC5_y1_pct
      ,gr_wide.RC5_y1_ltr
      ,gr_wide.RC5_credit_hours_Y1
      ,gr_wide.RC5_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC5_y1 >= 70 THEN gr_wide.RC5_credit_hours_Y1 ELSE NULL END AS RC5_earned_crhrs
      
    /*--RC6--*/
      ,gr_wide.RC6_course_name
      ,gr_wide.RC6_teacher_last
      
      ,ROUND(gr_wide.RC6_q1,0) AS RC6_q1_term_pct
      ,ROUND(gr_wide.RC6_q2,0) AS RC6_q2_term_pct
      ,ROUND(gr_wide.RC6_q3,0) AS RC6_q3_term_pct
      ,ROUND(gr_wide.RC6_q4,0) AS RC6_q4_term_pct
      
      ,ROUND(gr_wide.RC6_y1,0) AS RC6_y1_pct
      ,gr_wide.RC6_y1_ltr
      ,gr_wide.RC6_credit_hours_Y1
      ,gr_wide.RC6_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC6_y1 >= 70 THEN gr_wide.RC6_credit_hours_Y1 ELSE NULL END AS RC6_earned_crhrs      

    /*--RC7--*/
      ,gr_wide.RC7_course_name
      ,gr_wide.RC7_teacher_last
            
      ,ROUND(gr_wide.RC7_q1,0) AS RC7_q1_term_pct
      ,ROUND(gr_wide.RC7_q2,0) AS RC7_q2_term_pct
      ,ROUND(gr_wide.RC7_q3,0) AS RC7_q3_term_pct
      ,ROUND(gr_wide.RC7_q4,0) AS RC7_q4_term_pct
      
      ,ROUND(gr_wide.RC7_y1,0) AS RC7_y1_pct
      ,gr_wide.RC7_y1_ltr
      ,gr_wide.RC7_credit_hours_Y1
      ,gr_wide.RC7_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC7_y1 >= 70 THEN gr_wide.RC7_credit_hours_Y1 ELSE NULL END AS RC7_earned_crhrs
      
    /*--RC8--*/
      ,gr_wide.RC8_course_name
      ,gr_wide.RC8_teacher_last
      
      ,ROUND(gr_wide.RC8_q1,0) AS RC8_q1_term_pct
      ,ROUND(gr_wide.RC8_q2,0) AS RC8_q2_term_pct
      ,ROUND(gr_wide.RC8_q3,0) AS RC8_q3_term_pct
      ,ROUND(gr_wide.RC8_q4,0) AS RC8_q4_term_pct
      
      ,ROUND(gr_wide.RC8_y1,0) AS RC8_y1_pct
      ,gr_wide.RC8_y1_ltr
      ,gr_wide.RC8_credit_hours_Y1
      ,gr_wide.RC8_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC8_y1 >= 70 THEN gr_wide.RC8_credit_hours_Y1 ELSE NULL END AS RC8_earned_crhrs      

    /*--RC9--*/
      ,gr_wide.RC9_course_name
      ,gr_wide.RC9_teacher_last
      
      ,ROUND(gr_wide.RC9_q1,0) AS RC9_q1_term_pct
      ,ROUND(gr_wide.RC9_q2,0) AS RC9_q2_term_pct
      ,ROUND(gr_wide.RC9_q3,0) AS RC9_q3_term_pct
      ,ROUND(gr_wide.RC9_q4,0) AS RC9_q4_term_pct
      
      ,ROUND(gr_wide.RC9_y1,0) AS RC9_y1_pct
      ,gr_wide.RC9_y1_ltr
      ,gr_wide.RC9_credit_hours_Y1
      ,gr_wide.RC9_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC9_y1 >= 70 THEN gr_wide.RC9_credit_hours_Y1 ELSE NULL END AS RC9_earned_crhrs
      
    /*--RC10--*/
      ,gr_wide.RC10_course_name
      ,gr_wide.RC10_teacher_last      
      
      ,ROUND(gr_wide.RC10_q1,0) AS RC10_q1_term_pct
      ,ROUND(gr_wide.RC10_q2,0) AS RC10_q2_term_pct
      ,ROUND(gr_wide.RC10_q3,0) AS RC10_q3_term_pct
      ,ROUND(gr_wide.RC10_q4,0) AS RC10_q4_term_pct      
      
      ,ROUND(gr_wide.RC10_y1,0) AS RC10_y1_pct
      ,gr_wide.RC10_y1_ltr
      ,gr_wide.RC10_credit_hours_Y1
      ,gr_wide.RC10_gpa_points_Y1      
      --,CASE WHEN gr_wide.RC10_y1 >= 70 THEN gr_wide.RC10_credit_hours_Y1 ELSE NULL END AS RC10_earned_crhrs      

    /*--Current component averages -- UPDATE TERM NUMBER (e.g. H1/H2/H3/H4) on FIELD to current term--*/
      /*--H--*/
      ,ele.rc1_h AS rc1_cur_hw_pct
      ,ele.rc2_h AS rc2_cur_hw_pct
      ,ele.rc3_H AS rc3_cur_hw_pct
      ,ele.rc4_h AS rc4_cur_hw_pct
      ,ele.rc5_h AS rc5_cur_hw_pct
      ,ele.rc6_h AS rc6_cur_hw_pct
      ,ele.rc7_h AS rc7_cur_hw_pct
      ,ele.rc8_h AS rc8_cur_hw_pct
      ,ele.rc9_h AS rc9_cur_hw_pct
      ,ele.rc10_h AS rc10_cur_hw_pct      
      /*--A--*/
      ,ele.rc1_a AS rc1_cur_a_pct
      ,ele.rc2_a AS rc2_cur_a_pct
      ,ele.rc3_A AS rc3_cur_a_pct
      ,ele.rc4_a AS rc4_cur_a_pct
      ,ele.rc5_a AS rc5_cur_a_pct
      ,ele.rc6_a AS rc6_cur_a_pct
      ,ele.rc7_a AS rc7_cur_a_pct
      ,ele.rc8_a AS rc8_cur_a_pct
      ,ele.rc9_a AS rc9_cur_a_pct
      ,ele.rc10_a AS rc10_cur_a_pct
      /*--CW--*/
      ,ele.rc1_c AS rc1_cur_cw_pct
      ,ele.rc2_c AS rc2_cur_cw_pct
      ,ele.rc3_C AS rc3_cur_cw_pct
      ,ele.rc4_c AS rc4_cur_cw_pct
      ,ele.rc5_c AS rc5_cur_cw_pct
      ,ele.rc6_c AS rc6_cur_cw_pct
      ,ele.rc7_c AS rc7_cur_cw_pct
      ,ele.rc8_c AS rc8_cur_cw_pct
      ,ele.rc9_c AS rc9_cur_cw_pct
      ,ele.rc10_c AS rc10_cur_cw_pct
      /*--P--*/
      ,ele.rc1_p AS rc1_cur_p_pct
      ,ele.rc2_p AS rc2_cur_p_pct
      ,ele.rc3_P AS rc3_cur_p_pct
      ,ele.rc4_p AS rc4_cur_p_pct
      ,ele.rc5_p AS rc5_cur_p_pct
      ,ele.rc6_p AS rc6_cur_p_pct
      ,ele.rc7_p AS rc7_cur_p_pct
      ,ele.rc8_p AS rc8_cur_p_pct
      ,ele.rc9_p AS rc9_cur_p_pct
      ,ele.rc10_p AS rc10_cur_p_pct      
      
      /*** EXAMS **/
      /*--E1--*/ -- Exams
      ,gr_wide.rc1_E1 AS rc1_exam
      ,gr_wide.rc2_E1 AS rc2_exam
      ,gr_wide.rc3_E1 AS rc3_exam
      ,gr_wide.rc4_E1 AS rc4_exam
      ,gr_wide.rc5_E1 AS rc5_exam
      ,gr_wide.rc6_E1 AS rc6_exam
      ,gr_wide.rc7_E1 AS rc7_exam
      ,gr_wide.rc8_E1 AS rc8_exam
      ,gr_wide.rc9_E1 AS rc9_exam
      ,gr_wide.rc10_E1 AS rc10_exam
      /*--E2--*/
      ,gr_wide.rc1_E2 AS rc1_exam2
      ,gr_wide.rc2_E2 AS rc2_exam2
      ,gr_wide.rc3_E2 AS rc3_exam2
      ,gr_wide.rc4_E2 AS rc4_exam2
      ,gr_wide.rc5_E2 AS rc5_exam2
      ,gr_wide.rc6_E2 AS rc6_exam2
      ,gr_wide.rc7_E2 AS rc7_exam2
      ,gr_wide.rc8_E2 AS rc8_exam2
      ,gr_wide.rc9_E2 AS rc9_exam2
      ,gr_wide.rc10_E2 AS rc10_exam2

    /*--YTD absents and tardies by class--*/
       /*--Absences--*/
      ,gr_wide.rc1_current_absences
      ,gr_wide.rc2_current_absences
      ,gr_wide.rc3_current_absences
      ,gr_wide.rc4_current_absences
      ,gr_wide.rc5_current_absences
      ,gr_wide.rc6_current_absences
      ,gr_wide.rc7_current_absences
      ,gr_wide.rc8_current_absences
      ,gr_wide.rc9_current_absences
      ,gr_wide.rc10_current_absences
       /*--Tardies--*/
      ,gr_wide.rc1_current_tardies
      ,gr_wide.rc2_current_tardies
      ,gr_wide.rc3_current_tardies
      ,gr_wide.rc4_current_tardies
      ,gr_wide.rc5_current_tardies
      ,gr_wide.rc6_current_tardies
      ,gr_wide.rc7_current_tardies
      ,gr_wide.rc8_current_tardies
      ,gr_wide.rc9_current_tardies
      ,gr_wide.rc10_current_tardies
      
--Ed Tech
--AR$progress_to_goals_long#static

    /*--Accelerated Reader--*/
      /*--AR year--*/
      ,replace(convert(varchar,convert(Money, ar_yr.words),1),'.00','') AS words_read_yr
      ,replace(convert(varchar,convert(Money, ar_curr.words_goal * 6),1),'.00','') AS words_goal_yr
      ,ar_yr.points AS points_yr
      
      /*--AR current--*/      
      ,replace(convert(varchar,convert(Money, ar_curr.words),1),'.00','') AS words_read_cur_term
      ,replace(convert(varchar,convert(Money, ar_curr.words_goal),1),'.00','') AS words_goal_cur_term
      ,ar_curr.points AS points_curterm

--Literacy tracking
--MAP$comprehensive#identifiers
      --Lexile (from MAP)
        --base for year
      ,COALESCE(REPLACE(map_base.lexile_score, 'BR', 'Beginning Reader'), REPLACE(lex_base.RITtoReadingScore, 'BR', 'Beginning Reader')) AS lexile_base      
      ,COALESCE(map_base.testpercentile, lex_base.TestPercentile) AS lex_base_pct
        
      --current for year
      ,COALESCE(REPLACE(lex_curr.RITtoReadingScore, 'BR', 'Beginning Reader'), REPLACE(map_base.lexile_score, 'BR', 'Beginning Reader')) AS lexile_curr       
      ,COALESCE(lex_curr.TestPercentile, map_base.testpercentile) AS lex_curr_pct

--Comments
--PS$comments#static
      ,comment_rc1.teacher_comment  AS rc1_comment
      ,comment_rc2.teacher_comment  AS rc2_comment
      ,comment_rc3.teacher_comment  AS rc3_comment
      ,comment_rc4.teacher_comment  AS rc4_comment
      ,comment_rc5.teacher_comment  AS rc5_comment
      ,comment_rc6.teacher_comment  AS rc6_comment
      ,comment_rc7.teacher_comment  AS rc7_comment
      ,comment_rc8.teacher_comment  AS rc8_comment
      ,comment_rc9.teacher_comment  AS rc9_comment
      ,comment_rc10.teacher_comment AS rc10_comment
      ,comment_adv.advisor_comment  AS advisor_comment
    
--Discipline
--DISC$merits_demerits_count#NCA
    /*--Merits--*/
       /*--Year--*/
      ,merits.teacher_merits_y1 AS teacher_merits_yr
      ,merits.perfect_week_merits_y1 AS perfect_week_yr
      ,merits.total_merits_y1 AS total_merits_yr
       /*--Current--*/       
      ,merits.teacher_merits_rt2 AS teacher_merits_curr
      ,merits.perfect_week_merits_rt2 AS perfect_week_curr
      ,merits.total_merits_rt2 AS total_merits_curr
      
    /*--Demerits--*/
       /*--Year--*/
      ,merits.total_demerits_y1
       /*--Current--*/       
      ,merits.total_demerits_rt2

    /*-Perf Review-*/
      ,pr.Q1 AS perf_rev_Q1
      ,pr.Q3 AS perf_rev_Q3

FROM roster WITH (NOLOCK)

--ATTENDANCE
LEFT OUTER JOIN ATT_MEM$attendance_counts#static att_counts WITH (NOLOCK)
  ON roster.base_studentid = att_counts.studentid
LEFT OUTER JOIN ATT_MEM$att_percentages att_pct WITH (NOLOCK)
  ON roster.base_studentid = att_pct.studentid
  
--GRADES & GPA
LEFT OUTER JOIN GRADES$wide_all#NCA#static gr_wide WITH (NOLOCK)
  ON roster.base_studentid = gr_wide.studentid
LEFT OUTER JOIN GPA$detail#NCA nca_gpa WITH (NOLOCK)
  ON roster.base_studentid = nca_gpa.studentid
LEFT OUTER JOIN GPA$cumulative gpa_cumulative WITH (NOLOCK)
  ON roster.base_studentid = gpa_cumulative.studentid
 AND roster.schoolid = gpa_cumulative.schoolid
LEFT OUTER JOIN GPA$detail_long gpa_long WITH(NOLOCK)
  ON roster.base_studentid = gpa_long.studentid
 AND roster.curterm = gpa_long.term
LEFT OUTER JOIN KIPP_NJ..GRADES$rc_elements_by_term ele WITH(NOLOCK)
  ON roster.base_studentid = ele.studentid
 AND roster.curterm = ele.term

--MERITS & DEMERITS
LEFT OUTER JOIN DISC$culture_counts#NCA merits WITH (NOLOCK)
  ON roster.base_studentid = merits.studentid

--ED TECH
--ACCELERATED READER
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_yr WITH (NOLOCK)
  ON roster.base_studentid = ar_yr.studentid 
 AND ar_yr.time_period_name = 'Year' 
 AND ar_yr.yearid = dbo.fn_Global_Term_Id()
LEFT OUTER JOIN AR$progress_to_goals_long#static ar_curr WITH (NOLOCK)
  ON roster.base_studentid = ar_curr.studentid 
 AND ar_curr.time_period_name = roster.rt
 AND ar_curr.yearid = dbo.fn_Global_Term_Id()

--LEXILE
LEFT OUTER JOIN MAP$best_baseline#static map_base WITH (NOLOCK)
  ON roster.base_studentid = map_base.studentid
 AND map_base.MeasurementScale = 'Reading' 
 AND map_base.year = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_base WITH (NOLOCK)
  ON roster.base_student_number = lex_base.StudentID
 AND lex_base.MeasurementScale = 'Reading'
 AND lex_base.rn_base = 1
 AND lex_base.map_year_academic = dbo.fn_Global_Academic_Year()
LEFT OUTER JOIN MAP$comprehensive#identifiers lex_curr WITH (NOLOCK)
  ON roster.base_student_number = lex_curr.StudentID
 AND lex_curr.MeasurementScale = 'Reading'
 AND lex_curr.rn_curr = 1
 AND lex_curr.map_year_academic = dbo.fn_Global_Academic_Year()

--GRADEBOOK COMMMENTS
LEFT OUTER JOIN comments comment_rc1 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc1.studentid
 AND gr_wide.rc1_course_number = comment_rc1.course_number
 AND comment_rc1.term = roster.curterm
LEFT OUTER JOIN comments comment_rc2 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc2.studentid
 AND gr_wide.rc2_course_number = comment_rc2.course_number
 AND comment_rc2.term = roster.curterm
LEFT OUTER JOIN comments comment_rc3 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc3.studentid
 AND gr_wide.rc3_course_number = comment_rc3.course_number
 AND comment_rc3.term = roster.curterm
LEFT OUTER JOIN comments comment_rc4 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc4.studentid
 AND gr_wide.rc4_course_number = comment_rc4.course_number
 AND comment_rc4.term = roster.curterm
LEFT OUTER JOIN comments comment_rc5 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc5.studentid
 AND gr_wide.rc5_course_number = comment_rc5.course_number
 AND comment_rc5.term = roster.curterm
LEFT OUTER JOIN comments comment_rc6 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc6.studentid
 AND gr_wide.rc6_course_number = comment_rc6.course_number
 AND comment_rc6.term = roster.curterm
LEFT OUTER JOIN comments comment_rc7 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc7.studentid
 AND gr_wide.rc7_course_number = comment_rc7.course_number
 AND comment_rc7.term = roster.curterm
LEFT OUTER JOIN comments comment_rc8 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc8.studentid
 AND gr_wide.rc8_course_number = comment_rc8.course_number
 AND comment_rc8.term = roster.curterm
LEFT OUTER JOIN comments comment_rc9 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc9.studentid
 AND gr_wide.rc9_course_number = comment_rc9.course_number
 AND comment_rc9.term = roster.curterm
LEFT OUTER JOIN comments comment_rc10 WITH (NOLOCK)
  ON gr_wide.studentid = comment_rc10.studentid
 AND gr_wide.rc10_course_number = comment_rc10.course_number
 AND comment_rc10.term = roster.curterm
LEFT OUTER JOIN PS$comments#static comment_adv WITH (NOLOCK)
  ON roster.base_studentid = comment_adv.studentid
 AND comment_adv.course_number = 'HR'
 AND comment_adv.term = roster.curterm

-- Performance Review Grades
LEFT OUTER JOIN [KIPP_NJ].[dbo].[AUTOLOAD$GDOCS_PR_Performance_Review] pr WITH(NOLOCK)
  ON roster.base_student_number = pr.[SN]