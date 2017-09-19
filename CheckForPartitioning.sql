use HumanaArchive_2015_DOS
go

SELECT
SCHEMA_NAME(tbl.schema_id)+'.'+tbl.name as [table], --> something I added
p.partition_number AS [PartitionNumber],
prv.value AS [RightBoundaryValue],
 fg.name AS [FileGroupName],
CAST(pf.boundary_value_on_right AS int) AS [RangeType],
CAST(p.rows AS float) AS [RowCount],
p.data_compression AS [DataCompression]
FROM sys.tables AS tbl WITH (NOLOCK)
INNER JOIN sys.indexes AS idx  WITH (NOLOCK) ON idx.object_id = tbl.object_id and idx.index_id < 2
INNER JOIN sys.partitions AS p  WITH (NOLOCK) ON p.object_id=CAST(tbl.object_id AS int) AND p.index_id=idx.index_id
LEFT OUTER JOIN sys.destination_data_spaces AS dds  WITH (NOLOCK) ON dds.partition_scheme_id = idx.data_space_id and dds.destination_id = p.partition_number
LEFT OUTER JOIN sys.partition_schemes AS ps  WITH (NOLOCK) ON ps.data_space_id = idx.data_space_id
LEFT OUTER JOIN sys.partition_range_values AS prv  WITH (NOLOCK) ON prv.boundary_id = p.partition_number and prv.function_id = ps.function_id
LEFT OUTER JOIN sys.filegroups AS fg  WITH (NOLOCK) ON fg.data_space_id = dds.data_space_id or fg.data_space_id = idx.data_space_id
LEFT OUTER JOIN sys.partition_functions AS pf  WITH (NOLOCK) ON  pf.function_id = prv.function_id
WHERE SCHEMA_NAME(tbl.schema_id) 
IN 
('HUMANA_H0028'
,'HUMANA_H0108'
,'HUMANA_H0336'
,'HUMANA_H1036'
,'HUMANA_H1291'
,'HUMANA_H1406'
,'HUMANA_H1418'
,'HUMANA_H1468'
,'HUMANA_H1510'
,'HUMANA_H1716'
,'HUMANA_H1906'
,'HUMANA_H1951'
,'HUMANA_H2012'
,'HUMANA_H2029'
,'HUMANA_H2486'
,'HUMANA_H2649'
,'HUMANA_H2944'
,'HUMANA_H2949'
,'HUMANA_H3480'
,'HUMANA_H3533'
,'HUMANA_H4007'
,'HUMANA_H4141'
,'HUMANA_H4145'
,'HUMANA_H4461'
,'HUMANA_H4510'
,'HUMANA_H5216'
,'HUMANA_H5415'
,'HUMANA_H5525'
,'HUMANA_H5619'
,'HUMANA_H5970'
,'HUMANA_H6609'
,'HUMANA_H6622'
,'HUMANA_H6859'
,'HUMANA_H8145'
,'HUMANA_H8908'
,'HUMANA_H8953'
,'HUMANA_R5826')
AND p.data_compression <> 2
order by SCHEMA_NAME(tbl.schema_id)
