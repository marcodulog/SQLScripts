/*
CREATE TABLE IntTable
(ID INT IDENTITY(-2147483648, 1) NOT NULL
, VAL VARCHAR(255) NULL)
*/

drop table #temp10000
CREATE TABLE #temp10000
(ID INT IDENTITY(1,1) NOT NULL
, VAL VARCHAR(100) NULL
)

DECLARE @row int = 0
WHILE 1 = 1
BEGIN
	INSERT INTO #temp10000 values('test')
	SELECT @row = COUNT(*) FROM #temp10000
	IF @ROW >= 10000
		BREAK
END



SET NOCOUNT ON
DECLARE @bigint bigint = 4000000
DECLARE @row bigint = 0
WHILE 1 = 1
BEGIN
	INSERT INTO IntTable (val)
	SELECT v.val
	FROM (SELECT 'test' as val) v
	CROSS JOIN #temp10000

	SELECT @row = COUNT_BIG(*) FROM IntTable
	IF @ROW >= @bigint
		BREAK
END

select MAX(id) from IntTable

/* step 1 alter the table to have a bigint column null value */
ALTER TABLE IntTable
ADD BigIntID BIGINT NULL


/* step 2 update the column with the adjusted bigint value to keep the size */
SET ROWCOUNT 100000
DECLARE @rowcount bigint = 0
WHILE 1 = 1
BEGIN
	UPDATE IntTable
	SET BigIntID = ID + 2147483648 - 9223372036854775808
	WHERE BigIntID IS NULL
	SET @rowcount = @@ROWCOUNT

	IF @rowcount = 0
	BEGIN
		RAISERROR ('Completed', 0, 1) WITH NOWAIT
		BREAK
	END
	ELSE
	BEGIN
		RAISERROR ('100000 rows updated', 0, 1) WITH NOWAIT
	END
END

/* alter the column from null to not null */
ALTER TABLE IntTable
ALTER COLUMN BigIntID bigint NOT NULL

/* CREATE Shadow table, removing the identity from the id column and puttting it on the bigint column */
USE [Working]
GO

/****** Object:  Table [dbo].[IntTable]    Script Date: 3/29/2017 3:28:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[BigIntTable](
	[ID] [int] NOT NULL,
	[VAL] [varchar](255) NULL,
	[BigIntID] [bigint] IDENTITY(-9223372036854775808, 1) NOT NULL
) ON [PRIMARY]

GO

/* partition switch the inttable data to biginttable data */
ALTER TABLE IntTable SWITCH TO BigIntTable

/* remove the int column from the bigint table */
ALTER TABLE BigIntTable
DROP COLUMN id

sp_rename IntTable, IntTableBak
sp_rename BigIntTable IntTable
