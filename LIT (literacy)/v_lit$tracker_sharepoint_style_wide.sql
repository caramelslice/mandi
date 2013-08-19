USE KIPP_NJ
GO

ALTER VIEW LIT$tracker_sharepoint_style_wide AS
SELECT unioned.[Student Number]
      ,unioned.[Grade Level]
      ,unioned.[TEAM]
      --step round in unioned view is just date; replace with appropriate round from 
      --sql server date decoding tables referenced in join
      --,unioned.[Step Round]
      ,step_rounds.Term_Name AS "Step Round"
      
      ,unioned.[Test Type]
      ,unioned.[Step Level]
      ,unioned.[STATUS]
      ,unioned.[Independent Level]
      ,unioned.[Instructional Level]
      ,unioned.[Pre _ Name]
      ,unioned.[Pre _ Ph. Aw.-Rhyme]
      ,unioned.[Pre - 1 _ Concepts about Print]
      ,unioned.[Pre - 2 _ LID Name]
      ,unioned.[Pre - 3 _ LID Sound]
      ,unioned.[STEP 1 _ PA-1st]
      ,unioned.[STEP 1 _ Reading Record]
      ,unioned.[STEP 1 - 3 _ Dev. Spell]
      ,unioned.[STEP 2_Reading Record: Bk1 Acc]
      ,unioned.[STEP 2_Reading Record: Bk2 Acc]
      ,unioned.[STEP 2 - 3 _ PA - seg]
      ,unioned.[STEP 2 - 3 _ Comprehension]
      ,unioned.[STEP 3 - 12 _ Acurracy]
      ,unioned.[STEP 4 - 12 _ Fluency]
      ,unioned.[STEP 4 - 5 _ Comprehension]
      ,unioned.[STEP 4 - 5 _ Dev. Spell]
      ,unioned.[STEP 4 - 12 _ Rate]
      ,unioned.[STEP 6 - 7 _ Comprehension]
      ,unioned.[STEP 6 - 7 _ Dev. Spell]
      ,unioned.[STEP 8  _ Comprehension]
      ,unioned.[STEP 8 - 12 _ Retell]
      ,unioned.[STEP 8 - 10 _ Dev. Spell]
      ,unioned.[STEP 9 - 12 _ Comprehension]
      ,unioned.[STEP 11 - 12 _ Dev. Spell]
      ,unioned.[FP_L-Z_Rate]
      ,unioned.[FP_L-Z_Fluency]
      ,unioned.[FP_L-Z_Accuracy]
      ,unioned.[FP_L-Z_Comprehension]
FROM OPENQUERY(PS_TEAM, '
  SELECT *
  FROM PS.KIPP_NWK$STEP_TEST_EVENTS step
  
  UNION ALL
  
  SELECT 
      lastfirst || ''_'' || student_number AS "Student Number"
      ,grade_level AS "Grade Level"
      ,team
      --,read_teacher AS "Guided Reading Teacher"      
	  ,test_date AS step_round
      ,NULL AS "Test Type"      
      ,''FP_'' || step_level AS "Step Level"      
      ,status
      ,NULL AS "Independent Level"
      ,NULL AS "Instructional Level"
      ,NULL AS "Pre _ Name"
      ,NULL AS "Pre _ Ph. Aw.-Rhyme"
      ,NULL AS "Pre - 1 _ Concepts about Print"
      ,NULL AS "Pre - 2 _ LID Name"
      ,NULL AS "Pre - 3 _ LID Sound"
      ,NULL AS "STEP 1 _ PA-1st"
      ,NULL AS "STEP 1 _ Reading Record"
      ,NULL AS "STEP 1 - 3 _ Dev. Spell"
      ,NULL AS "STEP 2_Reading Record: Bk1 Acc"
      ,NULL AS "STEP 2_Reading Record: Bk2 Acc"
      ,NULL AS "STEP 2 - 3 _ PA - seg"
      ,NULL AS "STEP 2 - 3 _ Comprehension"
      ,NULL AS "STEP 3 - 12 _ Acurracy"
      ,NULL AS "STEP 4 - 12 _ Fluency"
      ,NULL AS "STEP 4 - 5 _ Comprehension"
      ,NULL AS "STEP 4 - 5 _ Dev. Spell"
      ,NULL AS "STEP 4 - 12 _ Rate"
      ,NULL AS "STEP 6 - 7 _ Comprehension"
      ,NULL AS "STEP 6 - 7 _ Dev. Spell"
      ,NULL AS "STEP 8  _ Comprehension"
      ,NULL AS "STEP 8 - 12 _ Retell"
      ,NULL AS "STEP 8 - 10 _ Dev. Spell"
      ,NULL AS "STEP 9 - 12 _ Comprehension"
      ,NULL AS "STEP 11 - 12 _ Dev. Spell"
      
      -- FP:      ACCURACY      
      ,CASE
        --testid 3273, F&P
        WHEN testid = 3273 AND fp_accuracy = 0 THEN ''Meets_100%''
        WHEN testid = 3273 AND fp_accuracy = 1 THEN ''Meets_99%''
        WHEN testid = 3273 AND fp_accuracy = 2 THEN ''Meets_98%''
        WHEN testid = 3273 AND fp_accuracy = 3 THEN ''Meets_97%''
        WHEN testid = 3273 AND fp_accuracy = 4 THEN ''Meets_96%''
        WHEN testid = 3273 AND fp_accuracy = 5 THEN ''Meets_95%''
        WHEN testid = 3273 AND fp_accuracy > 5 THEN ''Below_Below 95%''      
      END AS "FP_L-Z_Accuracy"
      
      -- FP:      RATE
      ,CASE
        --testid 3273, F&P
        WHEN testid = 3273 AND fp_wpmrate >= 126                        THEN ''Meets_Above (126+ w/m)''
        WHEN testid = 3273 AND fp_wpmrate <= 125 AND fp_wpmrate >= 75   THEN ''Meets_Target (75-125 w/m)''
        WHEN testid = 3273 AND fp_wpmrate <= 74                         THEN ''Below_Below (-74 w/m)''
      END AS "FP_L-Z_Rate"
      
      -- FP:      FLUENCY
      ,CASE
        --testid 3273, F&P
        WHEN testid = 3273 AND fp_fluency = 3 THEN ''Meets_3''
        WHEN testid = 3273 AND fp_fluency = 2 THEN ''Meets_2- Target''
        WHEN testid = 3273 AND fp_fluency = 1 THEN ''Below_1''
        WHEN testid = 3273 AND fp_fluency = 0 THEN ''Below_0''
      END AS "FP_L-Z_Fluency"
      
      -- FP:      COMPREHENSION
      ,CASE
        --testid 3273, F&P
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 0 THEN ''Below_0/9- Unsatisfactory''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 1 THEN ''Below_1/9- Unsatisfactory''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 2 THEN ''Below_2/9- Unsatisfactory''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 3 THEN ''Below_3/9- Unsatisfactory''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 4 THEN ''Below_4/9- Unsatisfactory''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 5 THEN ''Below_5/9- Limited''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about > 5 THEN ''Below_6/9- Limited''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 5 THEN ''Meets_7/9- Satisfactory''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 5 THEN ''Meets_8/9- Satisfactory''
        WHEN testid = 3273 AND fp_comp_within + fp_comp_beyond + fp_comp_about = 5 THEN ''Meets_9/9- Excellent''
      END AS "FP_L-Z_Comprehension"
FROM           
     (SELECT 
             s.id AS studentid                                    
            ,s.lastfirst
            ,s.student_number
            ,s.grade_level
            ,s.team
            ,user_defined_date AS test_date
            ,user_defined_text AS step_level
            ,foreignkey_alpha AS testid
            ,user_defined_text2 AS status            
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field1'')  AS fp_wpmrate                  
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field2'')  AS fp_fluency
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field3'')  AS fp_accuracy
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field4'')  AS fp_comp_within
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field5'')  AS fp_comp_beyond
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field6'')  AS fp_comp_about
            ,PS_CUSTOMFIELDS.GETCF(''readingScores'',scores.unique_id,''Field7'')  AS fp_keylever
      FROM virtualtablesdata3 scores
      JOIN students s
        ON s.id = scores.foreignKey 
      WHERE scores.related_to_table = ''readingScores'' 
        AND user_defined_text is not null 
        AND foreignkey_alpha = ''3273''
        AND user_defined_date > TO_DATE(''01-AUG-13'', ''DD-MON-YY'')
        --AND s.id = 3904
        --AND scores.schoolid = 73252
        --AND scores.user_defined_date LIKE ''%AUG-13''
      ) sub_1
') unioned
JOIN LIT$step_rounds step_rounds
  ON unioned."Step Round" >= step_rounds.Start_Date
 AND unioned."Step Round" <= step_rounds.End_Date