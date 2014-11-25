USE KIPP_NJ
GO

ALTER VIEW GRADES$rc_elements_by_term AS

SELECT studentid
      ,student_number
      ,term
      ,[rc1_H]
      ,[rc1_Q]
      ,[rc1_S]
      ,[rc2_H]
      ,[rc2_Q]
      ,[rc2_S]
      ,[rc3_H]
      ,[rc3_Q]
      ,[rc3_S]
      ,[rc4_H]
      ,[rc4_Q]
      ,[rc4_S]
      ,[rc5_H]
      ,[rc5_Q]
      ,[rc5_S]
      ,[rc6_H]
      ,[rc6_Q]
      ,[rc6_S]
      ,[rc7_H]
      ,[rc7_Q]
      ,[rc7_S]
      ,[rc8_H]
      ,[rc8_Q]
      ,[rc8_S]
FROM
    (
     SELECT studentid
           ,student_number           
           --,LEFT(field, 3) AS class           
           --,UPPER(SUBSTRING(REVERSE(field),2,1)) AS element
           ,LEFT(field, 3) + '_' + UPPER(SUBSTRING(REVERSE(field),2,1)) AS pivot_hash
           ,'T' + CONVERT(VARCHAR,RIGHT(field, 1)) AS term           
           ,grade
     FROM
         (
          SELECT student_number
                ,studentid
                ,rc1_h1
                ,rc1_h2
                ,rc1_h3
                ,rc1_q1
                ,rc1_q2
                ,rc1_q3
                ,rc1_s1
                ,rc1_s2
                ,rc1_s3
                ,rc2_h1
                ,rc2_h2
                ,rc2_h3
                ,rc2_q1
                ,rc2_q2
                ,rc2_q3
                ,rc2_s1
                ,rc2_s2
                ,rc2_s3
                ,rc3_h1
                ,rc3_h2
                ,rc3_h3
                ,rc3_q1
                ,rc3_q2
                ,rc3_q3
                ,rc3_s1
                ,rc3_s2
                ,rc3_s3
                ,rc4_h1
                ,rc4_h2
                ,rc4_h3
                ,rc4_q1
                ,rc4_q2
                ,rc4_q3
                ,rc4_s1
                ,rc4_s2
                ,rc4_s3
                ,rc5_h1
                ,rc5_h2
                ,rc5_h3
                ,rc5_q1
                ,rc5_q2
                ,rc5_q3
                ,rc5_s1
                ,rc5_s2
                ,rc5_s3
                ,rc6_h1
                ,rc6_h2
                ,rc6_h3
                ,rc6_q1
                ,rc6_q2
                ,rc6_q3
                ,rc6_s1
                ,rc6_s2
                ,rc6_s3
                ,rc7_h1
                ,rc7_h2
                ,rc7_h3
                ,rc7_q1
                ,rc7_q2
                ,rc7_q3
                ,rc7_s1
                ,rc7_s2
                ,rc7_s3
                ,rc8_h1
                ,rc8_h2
                ,rc8_h3
                ,rc8_q1
                ,rc8_q2
                ,rc8_q3
                ,rc8_s1
                ,rc8_s2
                ,rc8_s3
          FROM GRADES$wide_all#MS#static WITH(NOLOCK)
         ) sub

     UNPIVOT (
       grade
       FOR field IN (rc1_h1
                    ,rc1_h2
                    ,rc1_h3
                    ,rc1_q1
                    ,rc1_q2
                    ,rc1_q3
                    ,rc1_s1
                    ,rc1_s2
                    ,rc1_s3
                    ,rc2_h1
                    ,rc2_h2
                    ,rc2_h3
                    ,rc2_q1
                    ,rc2_q2
                    ,rc2_q3
                    ,rc2_s1
                    ,rc2_s2
                    ,rc2_s3
                    ,rc3_h1
                    ,rc3_h2
                    ,rc3_h3
                    ,rc3_q1
                    ,rc3_q2
                    ,rc3_q3
                    ,rc3_s1
                    ,rc3_s2
                    ,rc3_s3
                    ,rc4_h1
                    ,rc4_h2
                    ,rc4_h3
                    ,rc4_q1
                    ,rc4_q2
                    ,rc4_q3
                    ,rc4_s1
                    ,rc4_s2
                    ,rc4_s3
                    ,rc5_h1
                    ,rc5_h2
                    ,rc5_h3
                    ,rc5_q1
                    ,rc5_q2
                    ,rc5_q3
                    ,rc5_s1
                    ,rc5_s2
                    ,rc5_s3
                    ,rc6_h1
                    ,rc6_h2
                    ,rc6_h3
                    ,rc6_q1
                    ,rc6_q2
                    ,rc6_q3
                    ,rc6_s1
                    ,rc6_s2
                    ,rc6_s3
                    ,rc7_h1
                    ,rc7_h2
                    ,rc7_h3
                    ,rc7_q1
                    ,rc7_q2
                    ,rc7_q3
                    ,rc7_s1
                    ,rc7_s2
                    ,rc7_s3
                    ,rc8_h1
                    ,rc8_h2
                    ,rc8_h3
                    ,rc8_q1
                    ,rc8_q2
                    ,rc8_q3
                    ,rc8_s1
                    ,rc8_s2
                    ,rc8_s3)
       ) u
    ) sub
PIVOT (
  MAX(grade)
  FOR pivot_hash IN ([rc1_H]
                    ,[rc1_Q]
                    ,[rc1_S]
                    ,[rc2_H]
                    ,[rc2_Q]
                    ,[rc2_S]
                    ,[rc3_H]
                    ,[rc3_Q]
                    ,[rc3_S]
                    ,[rc4_H]
                    ,[rc4_Q]
                    ,[rc4_S]
                    ,[rc5_H]
                    ,[rc5_Q]
                    ,[rc5_S]
                    ,[rc6_H]
                    ,[rc6_Q]
                    ,[rc6_S]
                    ,[rc7_H]
                    ,[rc7_Q]
                    ,[rc7_S]
                    ,[rc8_H]
                    ,[rc8_Q]
                    ,[rc8_S])
 ) p