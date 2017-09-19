SET NOCOUNT ON;
SET ARITHABORT ON;

DECLARE 
       @ErrorMessage NVARCHAR(4000),
    @ErrorSeverity INT,
    @ErrorState INT;

BEGIN TRY

       /* INSERT NECESSARY CODE OR QUERIES */

       BEGIN TRANSACTION TRANSACTION_MUST_BE_DISTINCTLY_NAMED;

              /*UPDATE, DELETE, INSERT OR OTHER NECESSARY CODE AND QUERIES*/

       COMMIT TRANSACTION TRANSACTION_MUST_BE_DISTINCTLY_NAMED;

END TRY
BEGIN CATCH
       
       SELECT   
        @ErrorMessage = ERROR_MESSAGE(),  
        @ErrorSeverity = ERROR_SEVERITY(),  
        @ErrorState = ERROR_STATE();

       IF @@TRANCOUNT > 0
       BEGIN
              
              ROLLBACK TRANSACTION TRANSACTION_MUST_BE_DISTINCTLY_NAMED;
              
       END
       
       RAISERROR (@ErrorMessage, -- Message text.  
               @ErrorSeverity, -- Severity.  
               @ErrorState -- State.  
               );  

END CATCH
