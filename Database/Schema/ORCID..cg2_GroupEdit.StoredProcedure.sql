SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORCID.].[cg2_GroupEdit]

    @SecurityGroupID  BIGINT 
    , @Label  VARCHAR(255) 
    , @HasSpecialViewAccess  BIT =NULL
    , @HasSpecialEditAccess  BIT =NULL
    , @Description  VARCHAR(MAX) =NULL
    , @DefaultORCIDDecisionID  INT =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3657
 
  
        UPDATE [ORCID.].[DefaultORCIDDecisionIDMapping]
        SET
            [DefaultORCIDDecisionID] = @DefaultORCIDDecisionID
        WHERE
        [SecurityGroupID] = @SecurityGroupID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the Group record.', 11, 11); 
            RETURN @intReturnVal 
        END


GO
