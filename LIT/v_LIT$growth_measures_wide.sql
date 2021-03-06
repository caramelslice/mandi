USE KIPP_NJ
GO

ALTER VIEW LIT$growth_measures_wide AS

WITH roster AS (
  SELECT STUDENTID
        ,lastfirst
        ,SCHOOLID
        ,GRADE_LEVEL
        ,COHORT
        ,YEAR
  FROM COHORT$comprehensive_long#static WITH(NOLOCK)
  WHERE grade_level < 9
    AND rn = 1  
 )

,term_cur AS (
  SELECT academic_year      
        ,studentid
        ,[DR_cur_read_lvl]
        ,[DR_cur_GLEQ]
        ,[DR_cur_lvl_num]            
        ,[T1_cur_read_lvl]
        ,[T1_cur_GLEQ]
        ,[T1_cur_lvl_num]
        ,[T2_cur_read_lvl]
        ,[T2_cur_GLEQ]
        ,[T2_cur_lvl_num]
        ,[T3_cur_read_lvl]
        ,[T3_cur_GLEQ]
        ,[T3_cur_lvl_num]
        ,[EOY_cur_read_lvl]
        ,[EOY_cur_GLEQ]
        ,[EOY_cur_lvl_num]
  FROM
      (
       SELECT academic_year           
             ,studentid
             ,identifier + '_' + field AS identifier
             ,value
       FROM
           ( 
            SELECT academic_year
                  ,REPLACE(test_round, 'BOY', 'DR') + '_cur' AS identifier
                  ,studentid
                  ,CONVERT(VARCHAR,read_lvl) AS read_lvl
                  ,CONVERT(VARCHAR,GLEQ) AS GLEQ
                  ,CONVERT(VARCHAR,lvl_num) AS lvl_num
            FROM LIT$achieved_by_round#static WITH(NOLOCK)            
           ) sub

       UNPIVOT (
         value
         FOR field IN (read_lvl
                      ,GLEQ
                      ,lvl_num)
        ) unpiv
      ) sub2

  PIVOT (
    MAX(value)
    FOR identifier IN ([DR_cur_read_lvl]
                      ,[DR_cur_GLEQ]
                      ,[DR_cur_lvl_num]            
                      ,[T1_cur_read_lvl]
                      ,[T1_cur_GLEQ]
                      ,[T1_cur_lvl_num]
                      ,[T2_cur_read_lvl]
                      ,[T2_cur_GLEQ]
                      ,[T2_cur_lvl_num]
                      ,[T3_cur_read_lvl]
                      ,[T3_cur_GLEQ]
                      ,[T3_cur_lvl_num]
                      ,[EOY_cur_read_lvl]
                      ,[EOY_cur_GLEQ]
                      ,[EOY_cur_lvl_num])
   ) piv
 ) 

,year_cur AS (
  SELECT academic_year      
        ,studentid
        ,[yr_cur_read_lvl]
        ,[yr_cur_GLEQ]
        ,[yr_cur_lvl_num]        
        ,[yr_cur_color]
        ,[yr_cur_genre]
        ,[yr_cur_keylever]
        ,[yr_cur_wpmrate]
  FROM
      (
       SELECT academic_year           
             ,studentid
             ,identifier + '_' + field AS identifier
             ,value
       FROM
           ( 
            SELECT academic_year
                  ,'yr_cur' AS identifier
                  ,studentid
                  ,CONVERT(VARCHAR,read_lvl) AS read_lvl
                  ,CONVERT(VARCHAR,GLEQ) AS GLEQ
                  ,CONVERT(VARCHAR,lvl_num) AS lvl_num
                  ,CONVERT(VARCHAR,color) AS color
                  ,CONVERT(VARCHAR,genre) AS genre
                  ,CONVERT(VARCHAR,fp_keylever) AS keylever
                  ,CONVERT(VARCHAR,fp_wpmrate) AS wpmrate                  
            FROM LIT$test_events#identifiers WITH(NOLOCK)
            WHERE achv_curr_yr = 1
           ) sub

       UNPIVOT (
         value
         FOR field IN (read_lvl
                      ,GLEQ
                      ,lvl_num
                      ,color
                      ,genre
                      ,keylever
                      ,wpmrate)
        ) unpiv
      ) sub2

  PIVOT (
    MAX(value)
    FOR identifier IN ([yr_cur_read_lvl]
                      ,[yr_cur_GLEQ]
                      ,[yr_cur_lvl_num]
                      ,[yr_cur_color]
                      ,[yr_cur_genre]
                      ,[yr_cur_keylever]
                      ,[yr_cur_wpmrate])
   ) piv
 )
 
,term_dna AS (
  SELECT academic_year      
        ,studentid
        ,[DR_dna_read_lvl]
        ,[DR_dna_reason]
        ,[T1_dna_read_lvl]
        ,[T1_dna_reason]
        ,[T2_dna_read_lvl]
        ,[T2_dna_reason]
        ,[T3_dna_read_lvl]
        ,[T3_dna_reason]        
        ,[EOY_dna_read_lvl]
        ,[EOY_dna_reason]
  FROM
      (
       SELECT academic_year           
             ,studentid
             ,identifier + '_' + field AS identifier
             ,value
       FROM
           ( 
            SELECT academic_year
                  ,REPLACE(test_round, 'BOY', 'DR') + '_dna' AS identifier
                  ,rs.studentid
                  ,CONVERT(VARCHAR,rs.read_lvl) AS read_lvl
                  ,CONVERT(VARCHAR,dna.dna_reason) AS reason
            FROM LIT$test_events#identifiers rs WITH(NOLOCK)
            JOIN LIT$dna_reasons dna WITH(NOLOCK)
              ON rs.unique_id = dna.unique_id
            WHERE dna_round = 1
           ) sub

       UNPIVOT (
         value
         FOR field IN (read_lvl
                      ,reason)
        ) unpiv
      ) sub2

  PIVOT (
    MAX(value)
    FOR identifier IN ([T1_dna_read_lvl]
                      ,[T1_dna_reason]
                      ,[T2_dna_read_lvl]
                      ,[T2_dna_reason]
                      ,[T3_dna_read_lvl]
                      ,[T3_dna_reason]
                      ,[DR_dna_read_lvl]
                      ,[DR_dna_reason]
                      ,[EOY_dna_read_lvl]
                      ,[EOY_dna_reason])
   ) piv
 )

,yr_dna AS (
  SELECT academic_year      
        ,studentid
        ,[yr_dna_read_lvl]
        ,[yr_dna_reason]        
  FROM
      (
       SELECT academic_year           
             ,studentid
             ,identifier + '_' + field AS identifier
             ,value
       FROM
           ( 
            SELECT academic_year
                  ,'yr_dna' AS identifier
                  ,rs.studentid
                  ,CONVERT(VARCHAR,rs.read_lvl) AS read_lvl
                  ,CONVERT(VARCHAR,dna.dna_reason) AS reason
            FROM LIT$test_events#identifiers rs WITH(NOLOCK)
            JOIN LIT$dna_reasons dna WITH(NOLOCK)
              ON rs.unique_id = dna.unique_id
            WHERE dna_yr = 1
           ) sub

       UNPIVOT (
         value
         FOR field IN (read_lvl
                      ,reason)
        ) unpiv
      ) sub2

  PIVOT (
    MAX(value)
    FOR identifier IN ([yr_dna_read_lvl]
                      ,[yr_dna_reason])
   ) piv
 )
 
SELECT YEAR
      ,COHORT            
      ,GRADE_LEVEL
      ,SCHOOLID
      ,r.STUDENTID
      ,yr_cur_GLEQ
      ,yr_cur_lvl_num
      ,yr_cur_read_lvl
      ,yr_cur_color
      ,yr_cur_genre
      ,yr_cur_keylever
      ,yr_cur_wpmrate
      ,yr_dna_read_lvl
      ,yr_dna_reason      
      ,DR_cur_GLEQ
      ,DR_cur_lvl_num
      ,DR_cur_read_lvl
      ,DR_dna_read_lvl
      ,DR_dna_reason            
      ,T1_cur_GLEQ
      ,T1_cur_lvl_num
      ,T1_cur_read_lvl
      ,T1_dna_read_lvl
      ,T1_dna_reason      
      ,T2_cur_GLEQ
      ,T2_cur_lvl_num
      ,T2_cur_read_lvl
      ,T2_dna_read_lvl
      ,T2_dna_reason      
      ,T3_cur_GLEQ
      ,T3_cur_lvl_num
      ,T3_cur_read_lvl
      ,T3_dna_read_lvl
      ,T3_dna_reason     
      ,EOY_cur_GLEQ
      ,EOY_cur_lvl_num
      ,EOY_cur_read_lvl
      ,EOY_dna_read_lvl
      ,EOY_dna_reason    
      ,CONVERT(FLOAT,yr_cur_GLEQ) - CONVERT(FLOAT,COALESCE(DR_cur_GLEQ, T1_cur_GLEQ, T2_cur_GLEQ, T3_cur_GLEQ, EOY_cur_GLEQ)) AS yr_growth_GLEQ
      ,CONVERT(INT,yr_cur_lvl_num) - CONVERT(INT,COALESCE(DR_cur_lvl_num, T1_cur_lvl_num, T2_cur_lvl_num, T3_cur_lvl_num, EOY_cur_lvl_num)) AS yr_growth_lvl
      ,CONVERT(FLOAT,T1_cur_GLEQ) - CONVERT(FLOAT,DR_cur_GLEQ) AS t1_growth_GLEQ
      ,CONVERT(INT,T1_cur_lvl_num) - CONVERT(INT,DR_cur_lvl_num) AS t1_growth_lvl
      ,CONVERT(FLOAT,T2_cur_GLEQ) - CONVERT(FLOAT,DR_cur_GLEQ) AS t2_growth_GLEQ
      ,CONVERT(INT,T2_cur_lvl_num) - CONVERT(INT,DR_cur_lvl_num) AS t2_growth_lvl
      ,CONVERT(FLOAT,t3_cur_GLEQ) - CONVERT(FLOAT,DR_cur_GLEQ) AS t3_growth_GLEQ
      ,CONVERT(INT,t3_cur_lvl_num) - CONVERT(INT,DR_cur_lvl_num) AS t3_growth_lvl
      ,CONVERT(FLOAT,T2_cur_GLEQ) - CONVERT(FLOAT,T1_cur_GLEQ) AS t1t2_growth_GLEQ
      ,CONVERT(INT,T2_cur_lvl_num) - CONVERT(INT,T1_cur_lvl_num) AS t1t2_growth_lvl      
      ,CONVERT(FLOAT,t3_cur_GLEQ) - CONVERT(FLOAT,T2_cur_GLEQ) AS t2t3_growth_GLEQ
      ,CONVERT(INT,t3_cur_lvl_num) - CONVERT(INT,T2_cur_lvl_num) AS t2t3_growth_lvl
      ,CONVERT(FLOAT,EOY_cur_GLEQ) - CONVERT(FLOAT,T3_cur_GLEQ) AS t3EOY_growth_GLEQ
      ,CONVERT(INT,EOY_cur_lvl_num) - CONVERT(INT,T3_cur_lvl_num) AS t3EOY_growth_lvl
FROM roster r
LEFT OUTER JOIN year_cur yc
  ON r.STUDENTID = yc.studentid
 AND r.YEAR = yc.academic_year
LEFT OUTER JOIN term_cur tc
  ON r.STUDENTID = tc.studentid
 AND r.YEAR = tc.academic_year
LEFT OUTER JOIN term_dna td
  ON r.STUDENTID = td.studentid
 AND r.YEAR = td.academic_year
LEFT OUTER JOIN yr_dna yd
  ON r.STUDENTID = yd.studentid
 AND r.YEAR = yd.academic_year