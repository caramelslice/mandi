USE KIPP_NJ
GO

ALTER VIEW GDOCS$TA_standards_clean AS

WITH dirty_data AS (
  SELECT CASE
          WHEN school_name = 'SPARK' THEN 73254
          WHEN school_name = 'THRIVE' THEN 73255
          WHEN school_name = 'Seek' THEN 73256
          WHEN school_name = 'Life' THEN 73257
          WHEN school_name = 'Revolution' THEN 179901
         END AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,TA_num
        ,ccss_standard
        ,other_standard
        ,objective        
  FROM [AUTOLOAD$GDOCS_TA_CCSS_Standards] WITH(NOLOCK)
  WHERE school_name != 'All'

  UNION ALL

  SELECT sch.SCHOOL_NUMBER AS schoolid
        ,CASE WHEN CONVERT(VARCHAR,grade_level) = 'K' OR grade_level IS NULL THEN 0 ELSE grade_level END AS grade_level
        ,subject
        ,TA_num
        ,ccss_standard
        ,other_standard
        ,objective        
  FROM [AUTOLOAD$GDOCS_TA_CCSS_Standards] std WITH(NOLOCK)
  JOIN SCHOOLS sch WITH(NOLOCK)
    ON std.school_name = 'All'
   AND sch.LOW_GRADE = 0
   AND sch.SCHOOL_NUMBER != 999999
  WHERE std.school_name = 'All'
 )

SELECT schoolid
      ,grade_level
      ,subject
      ,term
      ,ccss_standard
      ,other_standard
      ,objective
      ,objective_dirty
      ,ROW_NUMBER() OVER (
         PARTITION BY grade_level
                     ,schoolid
                     ,subject
                     ,term
                     ,ccss_standard
           ORDER BY ccss_standard) AS dupe_audit
FROM
    (
     SELECT dirty_data.schoolid
           ,dirty_data.grade_level
           ,REPLACE(dirty_data.subject, 'Math', 'Mathematics') AS subject
           ,REPLACE(dirty_data.ta_num,'A','') AS term
           ,COALESCE(dirty_data.ccss_standard, dirty_data.other_standard) AS ccss_standard
           ,dirty_data.other_standard
           ,dirty_data.objective AS objective_dirty      
           ,dbo.fn_StripCharacters(REPLACE(REPLACE(REPLACE(CONVERT(NVARCHAR(512),dirty_data.objective), 'Êº', ''''), '€™', ''''), '€˜', ''''), '"Â') AS objective            
     FROM dirty_data
     WHERE dirty_data.grade_level IS NOT NULL
       AND dirty_data.subject IS NOT NULL
       AND dirty_data.TA_num IS NOT NULL  
    ) sub