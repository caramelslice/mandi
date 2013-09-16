USE [KIPP_NJ]
GO

/****** Object:  StoredProcedure [dbo].[spSTUDENTS_REFRESH]    Script Date: 15.06.2013 17:23:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[sp_PS$STUDENTS_refresh]
AS
BEGIN

 BEGIN TRANSACTION
	
 DECLARE @sql AS VARCHAR(MAX)='';

	 --STEP 1: make sure no temp table
		IF OBJECT_ID(N'tempdb..#PS$STUDENTS|refresh') IS NOT NULL
		BEGIN
						DROP TABLE [#PS$STUDENTS|refresh]
		END
	
	-- Step 2: insert into staging table
		SELECT CONVERT(INT, DCID) AS DCID,
		   CONVERT(INT, ID) AS ID,
		   LASTFIRST,
		   FIRST_NAME,
		   MIDDLE_NAME,
		   LAST_NAME,
		   STUDENT_NUMBER,
		   CONVERT(INT,ENROLL_STATUS) AS ENROLL_STATUS,
		   CONVERT(INT,GRADE_LEVEL) AS GRADE_LEVEL,
		   BALANCE1,
		   BALANCE2,
		   CONVERT(INT,PHONE_ID) AS PHONE_ID,
		   LUNCH_ID,
		   CONVERT(INT,PHOTOFLAG) AS PHOTOFLAG,
		   GENDER,
		   ENTRYDATE,
		   EXITDATE,
		   WEB_ID,
		   WEB_PASSWORD,
		   CONVERT(INT,SDATARN) AS SDATARN,
		   CONVERT(INT,SCHOOLID) AS SCHOOLID,
		   DOB,
		   STREET,
		   CITY,
		   STATE,
		   ZIP,
		   GUARDIANEMAIL,
		   CONVERT(INT,ALLOWWEBACCESS) AS ALLOWWEBACCESS,
		   TRANSFERCOMMENT,
		   GUARDIANFAX,
		   SSN,
		   ENTRYCODE,
		   EXITCODE,
		   LUNCHSTATUS,
		   ETHNICITY,
		   CUMULATIVE_GPA,
		   SIMPLE_GPA,
		   CUMULATIVE_PCT,
		   LASTMEAL,
		   PL_LANGUAGE,
		   SIMPLE_PCT,
		   CONVERT(INT,CLASSOF) AS CLASSOF,
		   FAMILY_IDENT,
		   CONVERT(INT,NEXT_SCHOOL) AS NEXT_SCHOOL,
		   [LOG],
		   TRACK,
		   CONVERT(INT,EXCLUDE_FR_RANK) AS EXCLUDE_FR_RANK,
		   GRADREQSET,
		   CONVERT(INT,TEACHERGROUPID) AS TEACHERGROUPID,
		   CONVERT(INT,CAMPUSID) AS CAMPUSID,
		   BALANCE3,
		   BALANCE4,
		   CONVERT(INT,ENROLLMENT_SCHOOLID) AS ENROLLMENT_SCHOOLID,
		   CONVERT(INT,GRADREQSETID) AS GRADREQSETID,
		   APPLIC_SUBMITTED_DATE,
		   APPLIC_RESPONSE_RECVD_DATE,
		   STUDENT_WEB_ID,
		   STUDENT_WEB_PASSWORD,
		   CONVERT(INT,STUDENT_ALLOWWEBACCESS) AS STUDENT_ALLOWWEBACCESS,
		   BUS_ROUTE,
		   BUS_STOP,
		   DOCTOR_NAME,
		   DOCTOR_PHONE,
		   EMERG_CONTACT_1,
		   EMERG_CONTACT_2,
		   EMERG_PHONE_1,
		   EMERG_PHONE_2,
		   FATHER,
		   HOME_PHONE,
		   HOME_ROOM,
		   LOCKER_COMBINATION,
		   LOCKER_NUMBER,
		   MAILING_CITY,
		   MAILING_STREET,
		   MAILING_STATE,
		   MAILING_ZIP,
		   MOTHER,
		   WM_STATUS,
		   WM_STATUSDATE,
		   CONVERT(INT,WM_TIER) AS WM_TIER,
		   WM_ADDRESS,
		   WM_PASSWORD,
		   WM_CREATEDATE,
		   CONVERT(INT,WM_CREATETIME) AS WM_CREATETIME,
		   CONVERT(INT,SCHED_YEAROFGRADUATION) AS SCHED_YEAROFGRADUATION,
		   SCHED_NEXTYEARHOUSE,
		   SCHED_NEXTYEARBUILDING,
		   SCHED_NEXTYEARTEAM,
		   SCHED_NEXTYEARHOMEROOM,
		   CONVERT(INT,SCHED_NEXTYEARGRADE) AS SCHED_NEXTYEARGRADE,
		   SCHED_NEXTYEARBUS,
		   CONVERT(INT,SCHED_SCHEDULED) AS SCHED_SCHEDULED,
		   SCHED_LOCKSTUDENTSCHEDULE,
		   WM_TA_FLAG,
		   WM_TA_DATE,
		   CONVERT(INT,SCHED_PRIORITY) AS SCHED_PRIORITY,
		   DISTRICTENTRYDATE,
		   CONVERT(INT,DISTRICTENTRYGRADELEVEL) AS DISTRICTENTRYGRADELEVEL,
		   SCHOOLENTRYDATE,
		   CONVERT(INT,SCHOOLENTRYGRADELEVEL) AS SCHOOLENTRYGRADELEVEL,
		   GRADUATED_SCHOOLNAME,
		   CONVERT(INT,GRADUATED_SCHOOLID) AS GRADUATED_SCHOOLID,
		   CONVERT(INT,GRADUATED_RANK) AS GRADUATED_RANK,
		   ALERT_DISCIPLINE,
		   ALERT_DISCIPLINEEXPIRES,
		   ALERT_GUARDIAN,
		   ALERT_GUARDIANEXPIRES,
		   ALERT_MEDICAL,
		   ALERT_MEDICALEXPIRES,
		   ALERT_OTHER,
		   ALERT_OTHEREXPIRES,
		   CUSTOMRANK_GPA,
		   STATE_STUDENTNUMBER,
		   CONVERT(INT,STATE_EXCLUDEFROMREPORTING) AS STATE_EXCLUDEFROMREPORTING,
		   CONVERT(INT,STATE_ENROLLFLAG) AS STATE_ENROLLFLAG,
		   DISTRICTOFRESIDENCE,
		   ENROLLMENTTYPE,
		   CONVERT(INT,ENROLLMENTCODE) AS ENROLLMENTCODE,
		   FULLTIMEEQUIV_OBSOLETE,
		   MEMBERSHIPSHARE,
		   CONVERT(INT,TUITIONPAYER) AS TUITIONPAYER,
		   ENROLLMENT_TRANSFER_DATE_PEND,
		   ENROLLMENT_TRANSFER_INFO,
		   EXITCOMMENT,
		   CONVERT(INT,FEE_EXEMPTION_STATUS) AS FEE_EXEMPTION_STATUS,
		   TEAM,
		   HOUSE,
		   BUILDING,
		   FTEID,
		   WITHDRAWAL_REASON_CODE,
		   GUARDIAN_STUDENTCONT_GUID,
		   FATHER_STUDENTCONT_GUID,
		   MOTHER_STUDENTCONT_GUID,
		   STUDENTPERS_GUID,
		   STUDENTPICT_GUID,
		   STUDENTSCHLENRL_GUID,
		   CONVERT(INT,SCHED_LOADLOCK) AS SCHED_LOADLOCK,
		   CONVERT(INT,PERSON_ID) AS PERSON_ID,
		   CONVERT(INT,LDAPENABLED) AS LDAPENABLED,
		   CONVERT(INT,SUMMERSCHOOLID) AS SUMMERSCHOOLID,
		   SUMMERSCHOOLNOTE,
		   GEOCODE,
		   MAILING_GEOCODE,
		   CONVERT(INT,FEDETHNICITY) AS FEDETHNICITY,
		   CONVERT(INT,FEDRACEDECLINE) AS FEDRACEDECLINE,
		   GPENTRYYEAR,
		   CONVERT(INT,ENROLLMENTID) AS ENROLLMENTID
	INTO [#PS$STUDENTS|refresh]
	FROM OPENQUERY(PS_TEAM, 'SELECT TO_CHAR(dcid) as DCID, 
								TO_CHAR(id) as ID,
								lastfirst,
								first_name,
								middle_name,
								last_name,
								student_number, 
								TO_CHAR(ENROLL_STATUS) AS ENROLL_STATUS,
								TO_CHAR(GRADE_LEVEL) AS GRADE_LEVEL,
								BALANCE1,
								BALANCE2,
								TO_CHAR(PHONE_ID) AS PHONE_ID,
								LUNCH_ID,
								TO_CHAR(PHOTOFLAG) AS PHOTOFLAG,
								GENDER,
								ENTRYDATE,
								EXITDATE,
								WEB_ID,
								WEB_PASSWORD,
								TO_CHAR(SDATARN) AS SDATARN,
								TO_CHAR(SCHOOLID) AS SCHOOLID,
								DOB,
								STREET,
								CITY,
								STATE,
								ZIP,
								DBMS_LOB.SUBSTR(GUARDIANEMAIL, 2000) AS GUARDIANEMAIL,
								TO_CHAR(ALLOWWEBACCESS) AS ALLOWWEBACCESS,
								DBMS_LOB.SUBSTR(TRANSFERCOMMENT, 2000) AS TRANSFERCOMMENT,
								DBMS_LOB.SUBSTR(GUARDIANFAX, 2000) AS GUARDIANFAX,
								SSN,
								ENTRYCODE,
								EXITCODE,
								LUNCHSTATUS,
								ETHNICITY,
								CUMULATIVE_GPA,
								SIMPLE_GPA,
								CUMULATIVE_PCT,
								LASTMEAL,
								PL_LANGUAGE,
								SIMPLE_PCT,
								TO_CHAR(CLASSOF) AS CLASSOF,
								FAMILY_IDENT,
								TO_CHAR(NEXT_SCHOOL) AS NEXT_SCHOOL,
								DBMS_LOB.SUBSTR(LOG, 2000) AS LOG,
								TRACK,
								TO_CHAR(EXCLUDE_FR_RANK) AS EXCLUDE_FR_RANK,
								GRADREQSET,
								TO_CHAR(TEACHERGROUPID) AS TEACHERGROUPID,
								TO_CHAR(CAMPUSID) AS CAMPUSID,
								BALANCE3,
								BALANCE4,
								TO_CHAR(ENROLLMENT_SCHOOLID) AS ENROLLMENT_SCHOOLID,
								TO_CHAR(GRADREQSETID) AS GRADREQSETID,
								APPLIC_SUBMITTED_DATE,
								APPLIC_RESPONSE_RECVD_DATE,
								STUDENT_WEB_ID,
								STUDENT_WEB_PASSWORD,
								TO_CHAR(STUDENT_ALLOWWEBACCESS) AS STUDENT_ALLOWWEBACCESS,
								BUS_ROUTE,
								BUS_STOP,
								DOCTOR_NAME,
								DOCTOR_PHONE,
								EMERG_CONTACT_1,
								EMERG_CONTACT_2,
								EMERG_PHONE_1,
								EMERG_PHONE_2,
								FATHER,
								HOME_PHONE,
								HOME_ROOM,
								LOCKER_COMBINATION,
								LOCKER_NUMBER,
								MAILING_CITY,
								MAILING_STREET,
								MAILING_STATE,
								MAILING_ZIP,
								MOTHER,
								WM_STATUS,
								WM_STATUSDATE,
								TO_CHAR(WM_TIER) AS WM_TIER,
								WM_ADDRESS,
								DBMS_LOB.SUBSTR(WM_PASSWORD, 2000) AS WM_PASSWORD,
								WM_CREATEDATE,
								TO_CHAR(WM_CREATETIME) AS WM_CREATETIME,
								TO_CHAR(SCHED_YEAROFGRADUATION) AS SCHED_YEAROFGRADUATION,
								SCHED_NEXTYEARHOUSE,
								SCHED_NEXTYEARBUILDING,
								SCHED_NEXTYEARTEAM,
								SCHED_NEXTYEARHOMEROOM,
								TO_CHAR(SCHED_NEXTYEARGRADE) AS SCHED_NEXTYEARGRADE,
								SCHED_NEXTYEARBUS,
								TO_CHAR(SCHED_SCHEDULED) AS SCHED_SCHEDULED,
								TO_CHAR(SCHED_LOCKSTUDENTSCHEDULE) AS SCHED_LOCKSTUDENTSCHEDULE,
								WM_TA_FLAG,
								WM_TA_DATE,
								TO_CHAR(SCHED_PRIORITY) AS SCHED_PRIORITY,
								DISTRICTENTRYDATE,
								TO_CHAR(DISTRICTENTRYGRADELEVEL) AS DISTRICTENTRYGRADELEVEL,
								SCHOOLENTRYDATE,
								TO_CHAR(SCHOOLENTRYGRADELEVEL) AS SCHOOLENTRYGRADELEVEL,
								GRADUATED_SCHOOLNAME,
								TO_CHAR(GRADUATED_SCHOOLID) AS GRADUATED_SCHOOLID,
								TO_CHAR(GRADUATED_RANK) AS GRADUATED_RANK,
								DBMS_LOB.SUBSTR(ALERT_DISCIPLINE, 2000) AS ALERT_DISCIPLINE,
								ALERT_DISCIPLINEEXPIRES,
								DBMS_LOB.SUBSTR(ALERT_GUARDIAN, 2000) AS ALERT_GUARDIAN,
								ALERT_GUARDIANEXPIRES,
								DBMS_LOB.SUBSTR(ALERT_MEDICAL, 2000) AS ALERT_MEDICAL,
								ALERT_MEDICALEXPIRES,
								DBMS_LOB.SUBSTR(ALERT_OTHER, 2000) AS ALERT_OTHER,
								ALERT_OTHEREXPIRES,
								CUSTOMRANK_GPA,
								STATE_STUDENTNUMBER,
								TO_CHAR(STATE_EXCLUDEFROMREPORTING) AS STATE_EXCLUDEFROMREPORTING,
								TO_CHAR(STATE_ENROLLFLAG) AS STATE_ENROLLFLAG,
								DISTRICTOFRESIDENCE,
								ENROLLMENTTYPE,
								TO_CHAR(ENROLLMENTCODE) AS ENROLLMENTCODE,
								FULLTIMEEQUIV_OBSOLETE,
								MEMBERSHIPSHARE,
								TO_CHAR(TUITIONPAYER) AS TUITIONPAYER,
								ENROLLMENT_TRANSFER_DATE_PEND,
								DBMS_LOB.SUBSTR(ENROLLMENT_TRANSFER_INFO, 2000) AS ENROLLMENT_TRANSFER_INFO,
								DBMS_LOB.SUBSTR(EXITCOMMENT, 2000) AS EXITCOMMENT,
								TO_CHAR(FEE_EXEMPTION_STATUS) AS FEE_EXEMPTION_STATUS,
								TEAM,
								HOUSE,
								BUILDING,
								TO_CHAR(FTEID) AS FTEID,
								WITHDRAWAL_REASON_CODE,
								GUARDIAN_STUDENTCONT_GUID,
								FATHER_STUDENTCONT_GUID,
								MOTHER_STUDENTCONT_GUID,
								STUDENTPERS_GUID,
								STUDENTPICT_GUID,
								STUDENTSCHLENRL_GUID,
								TO_CHAR(SCHED_LOADLOCK) AS SCHED_LOADLOCK,
								TO_CHAR(PERSON_ID) AS PERSON_ID,
								TO_CHAR(LDAPENABLED) AS LDAPENABLED,
								TO_CHAR(SUMMERSCHOOLID) AS SUMMERSCHOOLID,
								SUMMERSCHOOLNOTE,
								GEOCODE,
								MAILING_GEOCODE,
								TO_CHAR(FEDETHNICITY) AS FEDETHNICITY,
								TO_CHAR(FEDRACEDECLINE) AS FEDRACEDECLINE,
								GPENTRYYEAR,
								TO_CHAR(ENROLLMENTID) AS ENROLLMENTID
							FROM students');
	
	--Step 3: truncate result table
	EXEC('TRUNCATE TABLE dbo.[STUDENTS]');

	-- Step 4: disable all nonclustered indexes on table
	SELECT @sql = @sql + 
		'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name + ' DISABLE;' +CHAR(13)+CHAR(10)
	FROM 
		sys.indexes
	JOIN 
		sys.objects 
		ON sys.indexes.object_id = sys.objects.object_id
	WHERE sys.indexes.type_desc = 'NONCLUSTERED'
		AND sys.objects.type_desc = 'USER_TABLE'
		AND sys.objects.name = 'STUDENTS';

	EXEC (@sql);

	-- step 5: insert rows from remote source
	INSERT INTO [dbo].[STUDENTS]
		([DCID]
		  ,[ID]
		  ,[LASTFIRST]
		  ,[FIRST_NAME]
		  ,[MIDDLE_NAME]
		  ,[LAST_NAME]
		  ,[STUDENT_NUMBER]
		  ,[ENROLL_STATUS]
		  ,[GRADE_LEVEL]
		  ,[BALANCE1]
		  ,[BALANCE2]
		  ,[PHONE_ID]
		  ,[LUNCH_ID]
		  ,[PHOTOFLAG]
		  ,[GENDER]
		  ,[ENTRYDATE]
		  ,[EXITDATE]
		  ,[WEB_ID]
		  ,[WEB_PASSWORD]
		  ,[SDATARN]
		  ,[SCHOOLID]
		  ,[DOB]
		  ,[STREET]
		  ,[CITY]
		  ,[STATE]
		  ,[ZIP]
		  ,[GUARDIANEMAIL]
		  ,[ALLOWWEBACCESS]
		  ,[TRANSFERCOMMENT]
		  ,[GUARDIANFAX]
		  ,[SSN]
		  ,[ENTRYCODE]
		  ,[EXITCODE]
		  ,[LUNCHSTATUS]
		  ,[ETHNICITY]
		  ,[CUMULATIVE_GPA]
		  ,[SIMPLE_GPA]
		  ,[CUMULATIVE_PCT]
		  ,[LASTMEAL]
		  ,[PL_LANGUAGE]
		  ,[SIMPLE_PCT]
		  ,[CLASSOF]
		  ,[FAMILY_IDENT]
		  ,[NEXT_SCHOOL]
		  ,[LOG]
		  ,[TRACK]
		  ,[EXCLUDE_FR_RANK]
		  ,[GRADREQSET]
		  ,[TEACHERGROUPID]
		  ,[CAMPUSID]
		  ,[BALANCE3]
		  ,[BALANCE4]
		  ,[ENROLLMENT_SCHOOLID]
		  ,[GRADREQSETID]
		  ,[APPLIC_SUBMITTED_DATE]
		  ,[APPLIC_RESPONSE_RECVD_DATE]
		  ,[STUDENT_WEB_ID]
		  ,[STUDENT_WEB_PASSWORD]
		  ,[STUDENT_ALLOWWEBACCESS]
		  ,[BUS_ROUTE]
		  ,[BUS_STOP]
		  ,[DOCTOR_NAME]
		  ,[DOCTOR_PHONE]
		  ,[EMERG_CONTACT_1]
		  ,[EMERG_CONTACT_2]
		  ,[EMERG_PHONE_1]
		  ,[EMERG_PHONE_2]
		  ,[FATHER]
		  ,[HOME_PHONE]
		  ,[HOME_ROOM]
		  ,[LOCKER_COMBINATION]
		  ,[LOCKER_NUMBER]
		  ,[MAILING_CITY]
		  ,[MAILING_STREET]
		  ,[MAILING_STATE]
		  ,[MAILING_ZIP]
		  ,[MOTHER]
		  ,[WM_STATUS]
		  ,[WM_STATUSDATE]
		  ,[WM_TIER]
		  ,[WM_ADDRESS]
		  ,[WM_PASSWORD]
		  ,[WM_CREATEDATE]
		  ,[WM_CREATETIME]
		  ,[SCHED_YEAROFGRADUATION]
		  ,[SCHED_NEXTYEARHOUSE]
		  ,[SCHED_NEXTYEARBUILDING]
		  ,[SCHED_NEXTYEARTEAM]
		  ,[SCHED_NEXTYEARHOMEROOM]
		  ,[SCHED_NEXTYEARGRADE]
		  ,[SCHED_NEXTYEARBUS]
		  ,[SCHED_SCHEDULED]
		  ,[SCHED_LOCKSTUDENTSCHEDULE]
		  ,[WM_TA_FLAG]
		  ,[WM_TA_DATE]
		  ,[SCHED_PRIORITY]
		  ,[DISTRICTENTRYDATE]
		  ,[DISTRICTENTRYGRADELEVEL]
		  ,[SCHOOLENTRYDATE]
		  ,[SCHOOLENTRYGRADELEVEL]
		  ,[GRADUATED_SCHOOLNAME]
		  ,[GRADUATED_SCHOOLID]
		  ,[GRADUATED_RANK]
		  ,[ALERT_DISCIPLINE]
		  ,[ALERT_DISCIPLINEEXPIRES]
		  ,[ALERT_GUARDIAN]
		  ,[ALERT_GUARDIANEXPIRES]
		  ,[ALERT_MEDICAL]
		  ,[ALERT_MEDICALEXPIRES]
		  ,[ALERT_OTHER]
		  ,[ALERT_OTHEREXPIRES]
		  ,[CUSTOMRANK_GPA]
		  ,[STATE_STUDENTNUMBER]
		  ,[STATE_EXCLUDEFROMREPORTING]
		  ,[STATE_ENROLLFLAG]
		  ,[DISTRICTOFRESIDENCE]
		  ,[ENROLLMENTTYPE]
		  ,[ENROLLMENTCODE]
		  ,[FULLTIMEEQUIV_OBSOLETE]
		  ,[MEMBERSHIPSHARE]
		  ,[TUITIONPAYER]
		  ,[ENROLLMENT_TRANSFER_DATE_PEND]
		  ,[ENROLLMENT_TRANSFER_INFO]
		  ,[EXITCOMMENT]
		  ,[FEE_EXEMPTION_STATUS]
		  ,[TEAM]
		  ,[HOUSE]
		  ,[BUILDING]
		  ,[FTEID]
		  ,[WITHDRAWAL_REASON_CODE]
		  ,[GUARDIAN_STUDENTCONT_GUID]
		  ,[FATHER_STUDENTCONT_GUID]
		  ,[MOTHER_STUDENTCONT_GUID]
		  ,[STUDENTPERS_GUID]
		  ,[STUDENTPICT_GUID]
		  ,[STUDENTSCHLENRL_GUID]
		  ,[SCHED_LOADLOCK]
		  ,[PERSON_ID]
		  ,[LDAPENABLED]
		  ,[SUMMERSCHOOLID]
		  ,[SUMMERSCHOOLNOTE]
		  ,[GEOCODE]
		  ,[MAILING_GEOCODE]
		  ,[FEDETHNICITY]
		  ,[FEDRACEDECLINE]
		  ,[GPENTRYYEAR]
		  ,[ENROLLMENTID])
	SELECT *
	FROM [#PS$STUDENTS|refresh];

	-- Step 4: rebuld all nonclustered indexes on table
	SELECT @sql = @sql + 
		'ALTER INDEX ' + indexes.name + ' ON  dbo.' + objects.name +' REBUILD;' +CHAR(13)+CHAR(10)
	FROM 
		sys.indexes
	JOIN 
		sys.objects 
		ON sys.indexes.object_id = sys.objects.object_id
	WHERE sys.indexes.type_desc = 'NONCLUSTERED'
		AND sys.objects.type_desc = 'USER_TABLE'
		AND sys.objects.name = 'STUDENTS';

	EXEC (@sql);

--need to commit after insert when this runs in a big Server Agent job
COMMIT TRANSACTION

END
