SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTypeAdd]

    @RecordLevelAuditTypeID  INT =NULL OUTPUT 
    , @AuditType  VARCHAR(50) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3629
 
  
        INSERT INTO [ORCID.].[RecordLevelAuditType]
        (
            [AuditType]
        )
        (
            SELECT
            @AuditType
        )
   
        SET @intReturnVal = @@error
        SET @RecordLevelAuditTypeID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the RecordLevelAuditType record.', 11, 11); 
            RETURN @intReturnVal 
        END



GO
