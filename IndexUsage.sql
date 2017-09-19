use Aetna
go

/*-----------------------------------------------------------------------------
Object: C:\Scripts\SQL\IndexUsage.sql
Date: 09/12/2016
Purpose: Get information on the index that is requested in @object_name

Maintenance Log
09/12/2016 MQD - Intial Creation
-----------------------------------------------------------------------------*/
-- vardecs
DECLARE @object_name VARCHAR(100) = 'stg.LineBundling'

-- temp table to hold the index data for the table... we want the key values
IF EXISTS (select 1 from tempdb.sys.objects so WHERE so.name like '%temp_helpindex%')
	DROP TABLE #temp_helpindex

CREATE TABLE #temp_helpindex
(index_name VARCHAR(255)
, index_description VARCHAR(255)
, index_keys VARCHAR(MAX)
)

INSERT INTO #temp_helpindex
EXEC sp_helpindex @object_name

-- main query to pull the data out and joining it to the sp_helpindex table
SELECT S.name as schema_name
,OBJECT_NAME(I.object_id) as table_name
,COALESCE(I.name, space(0)) as index_name
,PS.partition_number
,PS.row_count
,Cast((PS.reserved_page_count * 8)/1024. as decimal(12,2)) as size_in_mb
,COALESCE(IUS.user_seeks,0) as user_seeks
,COALESCE(IUS.user_scans,0) as user_scans
,COALESCE(IUS.user_lookups,0) as user_lookups
,I.type_desc
,A.LEAF_INSERT_COUNT 
,A.LEAF_UPDATE_COUNT 
,A.LEAF_DELETE_COUNT 
,TH.index_keys
FROM sys.all_objects T

INNER JOIN sys.schemas S
on T.schema_id = S.schema_id

INNER JOIN sys.indexes I 
ON T.object_id = I.object_id

INNER JOIN SYS.DM_DB_INDEX_OPERATIONAL_STATS (NULL,NULL,NULL,NULL ) A
ON I.[OBJECT_ID] = A.[OBJECT_ID] 
AND I.INDEX_ID = A.INDEX_ID 

INNER JOIN sys.dm_db_partition_stats PS 
ON I.object_id = PS.object_id 
AND I.index_id = PS.index_id

LEFT OUTER JOIN sys.dm_db_index_usage_stats IUS 
ON IUS.database_id = db_id() 
AND I.object_id = IUS.object_id 
AND I.index_id = IUS.index_id

LEFT JOIN #temp_helpindex TH
ON TH.index_name = I.name

WHERE I.object_id = OBJECT_ID(@object_name) --only pull the object selected
ORDER BY S.name, OBJECT_NAME(I.object_id) , I.name

IF EXISTS (select 1 from tempdb.sys.objects so WHERE so.name like '%temp_helpindex%')
	DROP TABLE #temp_helpindex
GO
