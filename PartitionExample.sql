USE [DBForPartitioning]
GO

CREATE PARTITION FUNCTION pfPartitionKey(int) AS RANGE LEFT FOR VALUES (1, 2, 3, 4, 5)
GO

/****** Object:  PartitionScheme [myPartitionScheme]    Script Date: 2/27/2017 8:29:05 AM ******/
CREATE PARTITION SCHEME psPartitionKey AS PARTITION pfPartitionKey TO ([PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY])
GO

CREATE TABLE SimplePartition
(ID INT IDENTITY (1,1) NOT NULL 
, MyData VARCHAR(100) NULL
, PartitionKey INT NOT NULL)

CREATE TABLE SimplePartitionSwitchOut
(ID INT IDENTITY (1,1) NOT NULL 
, MyData VARCHAR(100) NULL
, PartitionKey INT NOT NULL)
ON psPartitionKey(PartitionKey)

CREATE CLUSTERED INDEX CI_SimplePartitionSwitchOut
ON SimplePartitionSwitchOut(ID, PartitionKey) ON psPartitionKey(PartitionKey)


CREATE CLUSTERED INDEX CI_SimplePartition
ON SimplePartition(ID, PartitionKey) 



SELECT ps.name,pf.name,boundary_id,value
FROM sys.partition_schemes ps
INNER JOIN sys.partition_functions pf ON pf.function_id=ps.function_id
INNER JOIN sys.partition_range_values prf ON pf.function_id=prf.function_id

INSERT INTO SimplePartition
(MyData, PartitionKey)
VALUES ('I should be in partition number 5', 5)

INSERT INTO SimplePartition
(MyData, PartitionKey)
VALUES ('I should be in partition number 4', 4)

INSERT INTO SimplePartition
(MyData, PartitionKey)
VALUES ('I should be in partition number 3', 3)


INSERT INTO SimplePartition
(MyData, PartitionKey)
VALUES ('I should be in partition number 6', 100)

SELECT o.name objectname,i.name indexname, partition_id, partition_number, [rows]
FROM sys.partitions p
INNER JOIN sys.objects o ON o.object_id=p.object_id
INNER JOIN sys.indexes i ON i.object_id=p.object_id and p.index_id=i.index_id
WHERE o.name in ('SimplePartition', 'SimplePartitionSwitchOut')

SELECT * FROM SimplePartition

select * into NonPartitioned  from SimplePartition where 1 = 2

select * from NonPartitioned


CREATE CLUSTERED INDEX CI_NonPartitioned
ON NonPartitioned(ID, PartitionKey) 

SELECT * FROM SimplePartition
WHERE $PARTITION.pfPartitionKey(PartitionKey) = 4

select * from SimplePartitionSwitchOut
select * from NonPartitioned
select * from SimplePartition
ALTER TABLE SimplePartition SWITCH PARTITION 3 TO NonPartitioned


ALTER TABLE SimplePartition SWITCH PARTITION 5 TO SimplePartitionSwitchOut PARTITION 5