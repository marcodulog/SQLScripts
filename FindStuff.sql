/* find a database */
select * from sys.databases db
where name like ''

/* find objects that we need */
DECLARE @command VARCHAR(1000)
DECLARE @StringSearch VARCHAR(1000) = '%report%';

SELECT @command = 'USE ? 
SELECT ''Objects'' as SearchType
, DB_NAME() as DBname
, name 
, type 
, Modify_Date
FROM sys.objects WHERE name like ' + '''' + @StringSearch + ''' '

SELECT @command = @command + ' ORDER BY name'

EXEC sp_MSforeachdb @command

/* look in the stored procedures */
DECLARE @command VARCHAR(1000)
DECLARE @StringSearch VARCHAR(1000) = '%report%';

SELECT @command = 'USE ?
select distinct so.type, so.name, CAST(sm.definition as VARCHAR(255)) as SampleText
from sys.objects so 
join sys.sql_modules sm
on so.object_id = sm.object_id
where sm.definition like ' + '''' + @StringSearch + ''' '

SELECT @command = @command + ' ORDER BY name'

EXEC sp_MSforeachdb @command

/* find the job name */
USE msdb
GO

SELECT *
FROM sysjobs sj
WHERE sj.NAME LIKE 'EDS_ProcessStaged%'
ORDER BY NAME

/* find running job */
SELECT job.NAME
	,job.job_ID
	,job.enabled
	,job.Originating_Server
	,activity.run_requested_Date
	,datediff(minute, activity.run_requested_Date, getdate()) AS Elapsed
FROM msdb.dbo.sysjobs_view job
INNER JOIN msdb.dbo.sysjobactivity activity
	ON (job.job_id = activity.job_id)
WHERE run_Requested_date IS NOT NULL
	AND stop_execution_date IS NULL
	AND job.NAME LIKE 'EDS_ProcessStaged%'

/* try and find the jobs with a particular step */
use msdb
go

if DB_NAME() <> 'msdb'
	BEGIN
	SELECT DB_NAME() as dbname, 'Wrong database name' as mess
	SET NOEXEC ON
	END
ELSE
	BEGIN
	SET NOEXEC OFF
	END

select @@SERVERNAME as server_name
, sj.name as job_name
, sjs.step_id
, sjs.step_name
, sjs.subsystem
, sjs.command
from sysjobs sj
join sysjobsteps sjs
on sj.job_id = sjs.job_id
where sjs.subsystem = 'SSIS'
and sjs.command like '%Control_EncounterSTGtoDBO%'
go


	
