USE KIPP_NJ
GO

ALTER VIEW DEVFIN$external_data AS

-- CTEs clean up school roster, make DB-friendly
-- Newark (disaggregated), NJ, Essex County, Montclair
-- all counties = 99
-- all districts = 9999
-- all schools = 999
-- all grades = 99

WITH newark AS (
-- disaggregated by school to all for neighborhood comparisons
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,'Newark' AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname                
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99 -- breaking convention here but it's consistent with county/district/school code
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3570    
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL') -- exclude Pre-K and Graduated students
    AND PRGCODE != 'KH'
    
  UNION ALL
  
  -- no enrollment data for 2011, but we have it for NJASK, need to synthesize it for the roster
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,'Newark' AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3570    
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
 )
      
,nj_state AS (
-- state totals
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 99
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
    
  UNION ALL  
   
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 99
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
 )
 
,montclair AS (
-- because f%@# them
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3310
    AND [SCHOOL CODE] = 999
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
    
  UNION ALL  
   
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [DISTRICT CODE] = 3310
    AND [SCHOOL CODE] = 999
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
 )
 
,essex_county AS (
-- county total
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 13
    AND [DISTRICT CODE] = 9999
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
    
  UNION ALL  
   
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY CODE] = 13
    AND [DISTRICT CODE] = 9999
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
 )

,charter AS (
-- other NJ charters
  SELECT DISTINCT 
         DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY NAME] = 'CHARTERS'
    AND [DISTRICT NAME] != 'TEAM Academy Charter School'    
    AND [SCHOOL NAME] NOT IN ('District Total')
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
    
  UNION ALL
  
  SELECT DISTINCT 
         2011 AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,[COUNTY NAME] AS county_name
        ,[DISTRICT NAME] AS district_name
        ,CASE WHEN [SCHOOL CODE] IS NULL THEN 'DISTRICT TOTAL' ELSE [SCHOOL NAME] END AS schoolname        
        ,CASE
          WHEN grade_level = 'KG' THEN 0          
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
  FROM NJ_DOE..enr
  WHERE [COUNTY NAME] = 'CHARTERS'
    AND [DISTRICT NAME] != 'TEAM Academy Charter School'    
    AND [SCHOOL NAME] NOT IN ('District Total')
    AND GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
    AND PRGCODE != 'KH'
 )
 
,districts AS (
-- combine above CTEs to keep things clean
  SELECT *
  FROM newark
 UNION ALL
  SELECT *
  FROM nj_state
 UNION ALL
  SELECT *
  FROM essex_county
 UNION ALL
  SELECT *
  FROM montclair  
 UNION ALL  
  SELECT *
  FROM charter
 )
 
,enrollment_data AS (
-- and now for the actual data
  SELECT DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,CASE
          WHEN grade_level = 'KG' THEN 0        
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
        ,ROW_TOTAL AS enrollment
        ,[WH_M] + [WH_F] AS W
        ,[BL_M] + [BL_F] AS B
        ,[HI_M] + [HI_F] AS H
        ,[AS_M] 
          + [AS_F]
          + [AM_M] 
          + [AM_F]
          + [PI_M]
          + [PI_F]
          + [MU_M]
          + [MU_F]
          AS O
        ,[WH_M]
          + [BL_M]
          + [HI_M]
          + [AS_M]        
          + [AM_M]        
          + [PI_M]        
          + [MU_M]     
          AS M
        ,[WH_F]
          + [BL_F]
          + [HI_F]
          + [AS_F]        
          + [AM_F]        
          + [PI_F]        
          + [MU_F]
          AS F        
  FROM
      (
       SELECT [YEAR]
             ,[COUNTY CODE]
             ,[COUNTY NAME]
             ,[DISTRICT CODE]
             ,[DISTRICT NAME]
             ,[SCHOOL CODE]
             ,[SCHOOL NAME]      
             ,[GRADE_LEVEL]
             ,SUM([WH_M]) AS WH_M
             ,SUM([WH_F]) AS WH_F
             ,SUM([BL_M]) AS BL_M
             ,SUM([BL_F]) AS BL_F
             ,SUM([HI_M]) AS HI_M
             ,SUM([HI_F]) AS HI_F
             ,SUM([AS_M]) AS AS_M
             ,SUM([AS_F]) AS AS_F
             ,SUM([AM_M]) AS AM_M
             ,SUM([AM_F]) AS AM_F
             ,SUM([PI_M]) AS PI_M
             ,SUM([PI_F]) AS PI_F
             ,SUM([MU_M]) AS MU_M
             ,SUM([MU_F]) AS MU_F
             ,SUM([ROW_TOTAL]) AS ROW_TOTAL      
       FROM NJ_DOE..enr
       WHERE GRADE_LEVEL NOT IN ('PK','UG','TOTAL')
       GROUP BY [YEAR]
               ,[COUNTY CODE]
               ,[COUNTY NAME]
               ,[DISTRICT CODE]
               ,[DISTRICT NAME]
               ,[SCHOOL CODE]
               ,[SCHOOL NAME]      
               ,[GRADE_LEVEL]       
      ) sub
 ) 
 
,FARM AS (
-- and now for the actual data
  SELECT DATEPART(YEAR,CONVERT(DATE,LEFT([YEAR],4))) AS academic_year
        ,[COUNTY CODE] AS county_code
        ,[DISTRICT CODE] AS district_code
        ,[SCHOOL CODE] AS school_code
        ,CASE
          WHEN grade_level = 'KG' THEN 0        
          WHEN GRADE_LEVEL = 'TOTAL' THEN 99
          ELSE CONVERT(INT,grade_level)
         END AS grade_level
        ,ROW_TOTAL AS enrollment        
        ,[FREE_LUNCH] AS Free
        ,[REDUCED_PRICE_LUNCH] AS Reduced
        ,FREE_LUNCH + REDUCED_PRICE_LUNCH AS FARM
        ,ROW_TOTAL - [FREE_LUNCH] - [REDUCED_PRICE_LUNCH] AS Paid
        ,LEP AS LEP
  FROM NJ_DOE..enr  
  WHERE GRADE_LEVEL = 'TOTAL'
 )  

,NJASK AS (
  SELECT *
        ,ROUND((LAL_PP_pct / 100) * LAL_N_Valid,0) AS LAL_approx_N_PP
        ,ROUND((LAL_P_pct / 100) * LAL_N_Valid,0) AS LAL_approx_N_P
        ,ROUND((LAL_AP_pct / 100) * LAL_N_Valid,0) AS LAL_approx_N_AP
        ,ROUND((Math_PP_pct / 100) * Math_N_Valid,0) AS Math_approx_N_PP
        ,ROUND((Math_P_pct / 100) * Math_N_Valid,0) AS Math_approx_N_P
        ,ROUND((Math_AP_pct / 100) * Math_N_Valid,0) AS Math_approx_N_AP
        ,ROUND((SCI_PP_pct / 100) * SCI_N_Valid,0) AS SCI_approx_N_PP
        ,ROUND((SCI_P_pct / 100) * SCI_N_Valid,0) AS SCI_approx_N_P
        ,ROUND((SCI_AP_pct / 100) * SCI_N_Valid,0) AS SCI_approx_N_AP
  FROM
      (
       SELECT CASE WHEN [CountyCodeDFGAgrgegationCode] = 'ST' THEN 99 ELSE CONVERT(INT,[CountyCodeDFGAgrgegationCode]) END AS county_code
             ,CASE WHEN [DistrictCode] IS NULL THEN 9999 ELSE [DistrictCode] END AS district_code
             ,CASE WHEN [SchoolCode] IS NULL THEN 999 ELSE SchoolCode END AS school_code      
             ,[TestingYear] AS academic_year
             ,[Grade] AS grade_level
             ,[TOTALPOPULATIONLANGUAGEARTSNumberofValidScaleScores] AS LAL_N_Valid
             ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSPartiallyProficientPercentage]) / 10) AS LAL_PP_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSProficientPercentage]) / 10) AS LAL_P_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSAdvancedProficientPercentage]) / 10) AS LAL_AP_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONLANGUAGEARTSScaleScoreMean]) / 10) AS LAL_AvgScale
             ,[TOTALPOPULATIONMATHEMATICSNumberofValidScaleScores] AS Math_N_Valid
             ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSPartiallyProficientPercentage]) / 10) AS Math_PP_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSProficientPercentage]) / 10) AS Math_P_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSAdvancedProficientPercentage]) / 10) AS Math_AP_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONMATHEMATICSScaleScoreMean]) / 10) AS Math_AvgScale
             ,[TOTALPOPULATIONSCIENCENumberofValidScaleScores] AS SCI_N_Valid
             ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEPartiallyProficientPercentage]) / 10) AS SCI_PP_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEProficientPercentage]) / 10) AS SCI_P_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEAdvancedProficientPercentage]) / 10) AS SCI_AP_pct
             ,(CONVERT(FLOAT,[TOTALPOPULATIONSCIENCEScaleScoreMean]) / 10) AS SCI_AvgScale        
       FROM NJ_DOE..final_df WITH(NOLOCK)
       WHERE TestingYear IS NOT NULL
         AND CountyCodeDFGAgrgegationCode NOT IN ('NS','SN','A','V','B','CD','DE','FG','GH','I','J','N','R')         
       
       UNION ALL

       SELECT CASE WHEN [County Code] = 'ST' THEN 99 ELSE CONVERT(INT,[County Code]) END AS county_code
             ,CASE WHEN [District Code] IS NULL THEN 9999 ELSE [District Code] END AS district_code
             ,CASE WHEN [School Code] IS NULL THEN 999 ELSE [School Code] END AS school_code      
             ,academic_year
             ,grade_level
             ,REPLACE([TotalValid ScaleELA],'*','') AS LAL_N_Valid
             ,(CONVERT(FLOAT,REPLACE([TotalPPELA],'*',''))) AS LAL_PP_pct
             ,(CONVERT(FLOAT,REPLACE([TotalPELA],'*',''))) AS LAL_P_pct
             ,(CONVERT(FLOAT,REPLACE([TotalAPELA],'*',''))) AS LAL_AP_pct
             ,(CONVERT(FLOAT,REPLACE([TotalMean ScaleELA],'*',''))) AS LAL_AvgScale
             ,REPLACE([TotalValid ScaleMath],'*','') AS Math_N_Valid
             ,(CONVERT(FLOAT,REPLACE([TotalPPMath],'*',''))) AS Math_PP_pct
             ,(CONVERT(FLOAT,REPLACE([TotalPMath],'*',''))) AS Math_P_pct
             ,(CONVERT(FLOAT,REPLACE([TotalAPMath],'*',''))) AS Math_AP_pct
             ,(CONVERT(FLOAT,REPLACE([TotalMean ScaleMath],'*',''))) AS Math_AvgScale
             ,REPLACE([TotalValid ScaleScie],'*','') AS SCI_N_Valid
             ,(CONVERT(FLOAT,REPLACE([TotalPPScie],'*',''))) AS SCI_PP_pct
             ,(CONVERT(FLOAT,REPLACE([TotalPScie],'*',''))) AS SCI_P_pct
             ,(CONVERT(FLOAT,REPLACE([TotalAPScie],'*',''))) AS SCI_AP_pct
             ,(CONVERT(FLOAT,REPLACE([TotalMean ScaleScie],'*',''))) AS SCI_AvgScale        
       FROM NJ_DOE..NJASK$state_data_raw WITH(NOLOCK)
       WHERE academic_year = 2013
         AND [County Code] NOT IN ('NS','SN','A','V','B','CD','DE','FG','GH','I','J','N','R')

       UNION ALL

       SELECT CASE WHEN [County Code] = 'ST' THEN 99 ELSE CONVERT(INT,[County Code]) END AS county_code
             ,CASE WHEN [District Code] IS NULL THEN 9999 ELSE [District Code] END AS district_code
             ,CASE WHEN [School Code] IS NULL THEN 999 ELSE [School Code] END AS school_code      
             ,academic_year
             ,grade_level
             ,REPLACE([Total Valid Scale LANG],'*','') AS LAL_N_Valid
             ,(CONVERT(FLOAT,REPLACE([Total PP LANG],'*',''))) AS LAL_PP_pct
             ,(CONVERT(FLOAT,REPLACE([Total P LANG],'*',''))) AS LAL_P_pct
             ,(CONVERT(FLOAT,REPLACE([Total AP LANG],'*',''))) AS LAL_AP_pct
             ,(CONVERT(FLOAT,REPLACE([Total Scale LANG],'*',''))) AS LAL_AvgScale
             ,REPLACE([Total Valid Scale Math],'*','') AS Math_N_Valid
             ,(CONVERT(FLOAT,REPLACE([Total PP Math],'*',''))) AS Math_PP_pct
             ,(CONVERT(FLOAT,REPLACE([Total P Math],'*',''))) AS Math_P_pct
             ,(CONVERT(FLOAT,REPLACE([Total AP Math],'*',''))) AS Math_AP_pct
             ,(CONVERT(FLOAT,REPLACE([Total Scale Math],'*',''))) AS Math_AvgScale
             ,REPLACE([Total Valid Scale Scie],'*','') AS SCI_N_Valid
             ,(CONVERT(FLOAT,REPLACE([Total PP Scie],'*',''))) AS SCI_PP_pct
             ,(CONVERT(FLOAT,REPLACE([Total P Scie],'*',''))) AS SCI_P_pct
             ,(CONVERT(FLOAT,REPLACE([Total AP Scie],'*',''))) AS SCI_AP_pct
             ,(CONVERT(FLOAT,REPLACE([Total Scale Scie],'*',''))) AS SCI_AvgScale        
       FROM NJ_DOE..HSPA$state_data_raw WITH(NOLOCK)
       WHERE academic_year = 2013
         AND [County Code] NOT IN ('FG','GH','I','J','N','O','R','V','NS','SN','A','B','CD','DE')
      ) sub
  WHERE district_code IN (3310,3570,9999,6212)
 )  

SELECT districts.*
      ,enrollment_data.enrollment
      ,enrollment_data.W
      ,enrollment_data.B
      ,enrollment_data.H
      ,enrollment_data.O
      ,enrollment_data.M
      ,enrollment_data.F
      ,FARM.Free
      ,FARM.Reduced
      ,FARM.FARM
      ,FARM.Paid
      ,FARM.LEP      
      ,NJASK.LAL_N_Valid
      ,NJASK.LAL_AvgScale
      ,NJASK.LAL_PP_pct
      ,NJASK.LAL_P_pct
      ,NJASK.LAL_AP_pct
      ,NJASK.LAL_approx_N_PP
      ,NJASK.LAL_approx_N_P
      ,NJASK.LAL_approx_N_AP
      ,NJASK.MATH_N_Valid
      ,NJASK.MATH_AvgScale
      ,NJASK.MATH_PP_pct
      ,NJASK.MATH_P_pct
      ,NJASK.MATH_AP_pct
      ,NJASK.MATH_approx_N_PP
      ,NJASK.MATH_approx_N_P
      ,NJASK.MATH_approx_N_AP
      ,NJASK.SCI_N_Valid
      ,NJASK.SCI_AvgScale
      ,NJASK.SCI_PP_pct
      ,NJASK.SCI_P_pct
      ,NJASK.SCI_AP_pct
      ,NJASK.SCI_approx_N_PP
      ,NJASK.SCI_approx_N_P
      ,NJASK.SCI_approx_N_AP
FROM districts 
LEFT OUTER JOIN enrollment_data
  ON districts.academic_year = enrollment_data.academic_year
 AND districts.county_code = enrollment_data.county_code
 AND districts.district_code = enrollment_data.district_code
 AND districts.school_code = enrollment_data.school_code
 AND districts.grade_level = enrollment_data.grade_level
LEFT OUTER JOIN NJASK
  ON districts.academic_year = NJASK.academic_year
 AND districts.county_code = NJASK.county_code 
 AND districts.district_code = NJASK.district_code
 AND districts.school_code = NJASK.school_code 
 AND districts.grade_level = NJASK.grade_level
LEFT OUTER JOIN FARM
  ON districts.academic_year = FARM.academic_year
 AND districts.county_code = FARM.county_code
 AND districts.district_code = FARM.district_code
 AND districts.school_code = FARM.school_code  