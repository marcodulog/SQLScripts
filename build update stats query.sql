set transaction isolation level read uncommitted

SELECT 
'UPDATE STATISTICS [' + x.schemaname + '].[' + x.objectname + '] with FULLSCAN;', 
rows 
FROM (        SELECT DISTINCT      s.name as schemaname, 
                           o.name as objectname,
                           (SELECT max(rowcnt) as rowcnt FROM dbo.sysindexes si WHERE si.id = ix.object_id  ) as rows
                     FROM sys.Indexes ix 
                           join sys.objects o 
                                  on o.object_id =ix.object_id
                           join sys.schemas s 
                                  on s.schema_id = o.schema_id 
                      WHERE o.is_ms_shipped = 0) as x 
WHERE x.rows > 10000
ORDER BY rows desc;
