USE [ProdSupport]
GO

/****** Object:  View [dbo].[vwMonitorDeprecatedEvents]    Script Date: 05/09/2017 09:10:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwMonitorDeprecatedEvents] 
/******************************************************************************
Object: vwMonitorDeprecatedEvents
Date: 05/05/2017
Purpose: allow developers to read the events being logged
******************************************************************************/
AS
SELECT d.NAME AS dbname
   ,CONVERT(DATETIME, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, v.[TIMESTAMP]), DATENAME(TzOffset, SYSDATETIMEOFFSET()))) AS ColumnInLocalTime
   ,v.Feature
   ,v.MESSAGE
   ,v.SessionID
   ,v.SQLText
   ,v.EventName
FROM (
   SELECT FinalData.R.value('@name', 'nvarchar(255)') AS EventName
      ,FinalData.R.value('@timestamp', 'DATETIME2') AS TIMESTAMP
      ,FinalData.R.value('data(data/value)[1]', 'nvarchar(500)') AS Feature
      ,FinalData.R.value('data(data/value)[2]', 'nvarchar(500)') AS MESSAGE
      ,FinalData.R.value('(action/.)[1]', 'INT') AS DatabaseID
      ,FinalData.R.value('(action/.)[2]', 'nvarchar(MAX)') AS SQLText
      ,FinalData.R.value('(action/.)[3]', 'INT') AS SessionID
   FROM (
      SELECT CONVERT(XML, event_data) AS xmldata
      FROM sys.fn_xe_file_target_read_file('G:\Monitor_Deprecated_Discontinued_features*.etl', 'G:\Monitor_Deprecated_Discontinued_features*.mta', NULL, NULL)
      ) AsyncFileData
   CROSS APPLY xmldata.nodes('//event') AS FinalData(R)
   ) v
JOIN sys.databases d ON d.database_id = v.databaseid
WHERE d.NAME NOT IN ('msdb', 'master', 'dba', 'demo')
   AND v.SQLText NOT LIKE '%sys.traces%'

GO

use [ProdSupport]
GO
GRANT REFERENCES ON [dbo].[vwMonitorDeprecatedEvents] TO [HRP\HRP Developers]
GRANT SELECT ON [dbo].[vwMonitorDeprecatedEvents] TO [HRP\HRP RAG - HIM UAT AppData Reader]
GO


