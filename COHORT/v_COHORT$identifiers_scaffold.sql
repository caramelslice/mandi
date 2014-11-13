USE KIPP_NJ
GO

ALTER VIEW COHORT$identifiers_scaffold AS

SELECT co.year
      ,co.schoolid
      ,co.school_name
      ,co.grade_level
      ,co.studentid
      ,co.student_number
      ,co.lastfirst
      ,co.team
      ,co.advisor
      ,co.GENDER
      ,co.ETHNICITY
      ,co.LUNCHSTATUS
      ,co.SPEDLEP
      ,co.enroll_status
      ,CONVERT(DATE,rd.date) AS date
      ,rd.reporting_hash
      ,dt.alt_name AS term
FROM COHORT$identifiers_long#static co WITH(NOLOCK)
JOIN UTIL$reporting_days#static rd WITH(NOLOCK)
  ON co.entrydate <= rd.date
 AND co.exitdate >= rd.date
LEFT OUTER JOIN REPORTING$dates dt WITH(NOLOCK)
  ON co.schoolid = dt.schoolid
 AND co.year = dt.academic_year
 AND dt.identifier = 'RT'
 AND rd.date >= dt.start_date
 AND rd.date <= dt.end_date
WHERE co.schoolid != 999999