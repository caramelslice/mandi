USE KIPP_NJ
GO

ALTER VIEW PS$terms AS 

SELECT *
FROM OPENQUERY(PS_TEAM,'
  SELECT *
  FROM terms
')