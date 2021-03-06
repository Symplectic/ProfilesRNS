SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORCID.].[cg2_FieldLevelAuditTrailDelete]
 
    @FieldLevelAuditTrailID  BIGINT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[FieldLevelAuditTrail] WHERE         [ORCID.].[FieldLevelAuditTrail].[FieldLevelAuditTrailID] = @FieldLevelAuditTrailID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the FieldLevelAuditTrail record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal



GO
