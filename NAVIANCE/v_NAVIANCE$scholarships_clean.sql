USE [KIPP_NJ]
GO

ALTER VIEW NAVIANCE$scholarships_clean AS

SELECT [Newark Collegiate Academy] AS [Name]
      ,[F2] AS [Organization]
      ,[F3] AS [Description]
      ,[F4] AS [Max Amount]
      ,[F5] AS [Number Offered]
      ,[F6] AS [Type]
      ,[F7] AS [Deadline]
      ,[F8] AS [Is Active]
      ,[F9] AS [Primary Contact]
      ,[F10] AS [Address Line 1]
      ,[F11] AS [Address Line 2]
      ,[F12] AS [City]
      ,[F13] AS [State]
      ,[F14] AS [Zip]
      ,[F15] AS [Country]
      ,[F16] AS [Contact Other]
      ,[F17] AS [Phone]
      ,[F18] AS [Fax]
      ,[F19] AS [Email]
      ,[F20] AS [Website]
      ,[F21] AS [Categories]
      ,[F22] AS [Renewable]
      ,[F23] AS [Deadline Day]
      ,[F24] AS [Deadline Month]
      ,[F25] AS [Deadline Other]
      ,[F26] AS [Merit Based]
      ,[F27] AS [Need Based]
      ,[F28] AS [Essay Requirement]
      ,[F29] AS [Service Requirement]
      ,[F30] AS [Residency Requirement]
      ,[F31] AS [Academic Requirement]
      ,[F32] AS [Class Rank Requirement]
      ,[F33] AS [Citizenship Requirement]
      ,[F34] AS [Athletic Requirement]
      ,[F35] AS [Talent Requirement]
      ,[F36] AS [Club Requirement]
      ,[F37] AS [Disability Requirement]
      ,[F38] AS [Military Requirement]
      ,[F39] AS [Religion Requirement]
      ,[F40] AS [Ethnic Requirement]
      ,[F41] AS [US Citizenship]
      ,[F42] AS [Min GPA]
      ,[F43] AS [Min SAT]
      ,[F44] AS [Min PSAT]
      ,[F45] AS [Min Plan]
      ,[F46] AS [Min ACT]
      ,[F47] AS [Gender]
      ,[F48] AS [Ethnicity]
      ,[F49] AS [Grade Level]
      ,[F50] AS [Student Groups]      
FROM [dbo].[AUTOLOAD$NAVIANCE_scholarship] WITH(NOLOCK)
WHERE BINI_ID > 3