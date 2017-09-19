
-- Usage (must USE Databasename also)
-- List indexes by schema, table, index name with included columns and filter
SELECT SCHEMA_NAME(o.schema_id) 'Schema', OBJECT_NAME(u.object_id) 'Table', i.name, i.type_desc, c.name, ic.index_column_id, ic.is_included_column, i.has_filter, i.filter_definition, *
  FROM sys.dm_db_index_usage_stats u
  JOIN sys.indexes i
    ON u.object_id = i.object_id
   AND u.index_id = i.index_id
  JOIN sys.index_columns ic
    ON i.object_id = ic.object_id
   AND i.index_id = ic.index_id
  JOIN sys.columns c
    ON ic.object_id = c.object_id
   AND ic.column_id = c.column_id
  JOIN sys.objects o
    ON o.object_id = i.object_id
 WHERE database_id = db_id('Aetna')
   AND OBJECT_NAME(u.object_id) = 'EncounterResponseEDIValue'
 ORDER BY SCHEMA_NAME(o.schema_id), OBJECT_NAME(u.object_id), i.name, ic.index_column_id

-- Can be run in any db - don't need to use USE
-- TOP 100 most needed indexes with Details
SELECT TOP 100 migs.group_handle, mid.*, mis.avg_total_user_cost * mis.avg_user_impact * (mis.user_seeks + mis.user_scans) 'Total Impact', mis.avg_total_user_cost, mis.avg_user_impact, mis.user_seeks, mis.user_scans, migs.last_user_seek
FROM sys.dm_db_missing_index_group_stats AS migs
INNER JOIN sys.dm_db_missing_index_groups AS mig
    ON (migs.group_handle = mig.index_group_handle)
INNER JOIN sys.dm_db_missing_index_details AS mid
    ON (mig.index_handle = mid.index_handle)
INNER JOIN sys.dm_db_missing_index_group_stats AS mis
    ON (migs.group_handle = mis.group_handle)
    --WHERE statement LIKE '%EncounterServiceLines%'
	--WHERE mis.avg_total_user_cost >= 1000
	WHERE migs.last_user_seek > GETDATE() - 4
ORDER BY mis.avg_total_user_cost * mis.avg_user_impact * (mis.user_seeks + mis.user_scans) DESC