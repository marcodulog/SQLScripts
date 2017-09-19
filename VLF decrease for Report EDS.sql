-- view files if necessary
-- select * from sys.master_files where name like '%aetna%report%log%'

-- Users must be stopped from connecting in one way or another so that the logfile doesn't grow in the process
-- initial log file size in dev is 327,553MB

USE  Aetna_Report_EDS
GO


-- Check existing information if desired (record the quantity of records returned)
DBCC loginfo
GO

-- Clear the transaction writes (this must succeed prior to executing the rest)
CHECKPOINT


-- Shrink the logfile (REQUIRED)
DBCC shrinkfile (Aetna_Report_EDS_log)
GO


USE  master
GO
-- The last entry should not exceed the maximum size prior to the log file shrink
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 32768MB); -- 32 GB
GO

ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 65536MB); -- 64 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 98304MB); -- 96 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 131072MB); -- 128 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 163840MB); -- 160 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 196608MB); -- 192 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 229376MB); -- 224 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 262144MB); -- 256 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 294912MB); -- 288 GB
GO
ALTER DATABASE Aetna_Report_EDS MODIFY FILE (name = Aetna_Report_EDS_log, size = 327680MB); -- 320 GB
GO


-- time to grow 17 minutes

-- Validate the log file shrinking (record the quantity of records returned)
-- There should be much less records returned than when this was executed above.
USE  Aetna_Report_EDS
GO
DBCC loginfo
GO


-- Change the automatic growth size to 1GB (1024MB) (this is already done on the database)
--USE master;
--GO

--ALTER DATABASE Aetna_Report_EDS
--MODIFY FILE
--(NAME = Aetna_Report_EDS_log,
--SIZE = 1024MB);
--GO



