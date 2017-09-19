use ProdSupport
go

DECLARE @destination_table VARCHAR(4000) ;
SET @destination_table = 'WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;
DECLARE @schema VARCHAR(4000) ;
EXEC dba.dba.sp_WhoIsActive
@get_transaction_info = 1,
@get_plans = 1,
@return_schema = 1,
@schema = @schema OUTPUT ;
SET @schema = REPLACE(@schema, '<table_name>', @destination_table) ;
PRINT @schema
EXEC(@schema) ;
GO

DECLARE
    @destination_table VARCHAR(4000) ,
    @msg NVARCHAR(1000) ;
SET @destination_table = 'ProdSupport.dbo.WhoIsActive_' + CONVERT(VARCHAR, GETDATE(), 112) ;
DECLARE @numberOfRuns INT ;
SET @numberOfRuns = 1440 ;
WHILE @numberOfRuns > 0
    BEGIN;
        EXEC dba.dba.sp_WhoIsActive @get_transaction_info = 1, @get_plans = 1,
            @destination_table = @destination_table,
            @filter_type = 'Database'
			, @filter = 'Aetna';
        SET @numberOfRuns = @numberOfRuns - 1 ;
        IF @numberOfRuns > 0
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' +
                 'Logged info. Waiting...'
                RAISERROR(@msg,0,0) WITH nowait ;
                WAITFOR DELAY '00:01:00'
            END
        ELSE
            BEGIN
                SET @msg = CONVERT(CHAR(19), GETDATE(), 121) + ': ' + 'Done.'
                RAISERROR(@msg,0,0) WITH nowait ;
            END
    END ;
GO