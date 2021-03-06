SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonEdit]

    @PersonID  INT =NULL OUTPUT 
    , @InternalUsername  NVARCHAR(100) 
    , @PersonStatusTypeID  INT 
    , @CreateUnlessOptOut  BIT 
    , @ORCID  VARCHAR(50) =NULL
    , @ORCIDRecorded  SMALLDATETIME =NULL
    , @FirstName  NVARCHAR(150) =NULL
    , @LastName  NVARCHAR(150) =NULL
    , @PublishedName  NVARCHAR(500) =NULL
    , @EmailDecisionID  INT =NULL
    , @EmailAddress  VARCHAR(300) =NULL
    , @AlternateEmailDecisionID  INT =NULL
    , @AgreementAcknowledged  BIT =NULL
    , @Biography  VARCHAR(5000) =NULL
    , @BiographyDecisionID  INT =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3566
 
  
        UPDATE [ORCID.].[Person]
        SET
            [InternalUsername] = @InternalUsername
            , [PersonStatusTypeID] = @PersonStatusTypeID
            , [CreateUnlessOptOut] = @CreateUnlessOptOut
            , [ORCID] = @ORCID
            , [ORCIDRecorded] = @ORCIDRecorded
            , [FirstName] = @FirstName
            , [LastName] = @LastName
            , [PublishedName] = @PublishedName
            , [EmailDecisionID] = @EmailDecisionID
            , [EmailAddress] = @EmailAddress
            , [AlternateEmailDecisionID] = @AlternateEmailDecisionID
            , [AgreementAcknowledged] = @AgreementAcknowledged
            , [Biography] = @Biography
            , [BiographyDecisionID] = @BiographyDecisionID
        FROM
            [ORCID.].[Person]
        WHERE
        [ORCID.].[Person].[PersonID] = @PersonID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the Person record.', 11, 11); 
            RETURN @intReturnVal 
        END



GO
