/*
Deployment script for Profiles_2_0_0

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

/*
Deployment script for Profiles_2_0_0

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


PRINT N'Dropping [ORNG.].[DF_orng_apps_enabled]...';


GO
ALTER TABLE [ORNG.].[Apps] DROP CONSTRAINT [DF_orng_apps_enabled];


GO
PRINT N'Dropping [ORNG.].[FK_orng_app_views_apps]...';


GO
ALTER TABLE [ORNG.].[AppViews] DROP CONSTRAINT [FK_orng_app_views_apps];


GO
PRINT N'Dropping [ORNG.].[FK_AppRegistry_Visibility]...';


GO
ALTER TABLE [ORNG.].[AppRegistry] DROP CONSTRAINT [FK_AppRegistry_Visibility];


GO
PRINT N'Dropping [ORNG.].[Visibility]...';


GO
DROP TABLE [ORNG.].[Visibility];


GO
PRINT N'Dropping [ORNG.].[ReadRegistry]...';


GO
DROP PROCEDURE [ORNG.].[ReadRegistry];


GO
PRINT N'Dropping [ORNG.].[RegisterAppPerson]...';


GO
DROP PROCEDURE [ORNG.].[RegisterAppPerson];





GO
PRINT N'Starting rebuilding table [ORNG.].[Apps]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [ORNG.].[tmp_ms_xx_Apps] (
    [AppID]                INT            NOT NULL,
    [Name]                 NVARCHAR (255) NOT NULL,
    [Url]                  NVARCHAR (255) NULL,
    [PersonFilterID]       INT            NULL,
    [RequiresRegistration] BIT            DEFAULT ((0)) NOT NULL,
    [UnavailableMessage]   TEXT           NULL,
    [OAuthSecret]          NVARCHAR (255) NULL,
    [Enabled]              BIT            CONSTRAINT [DF_orng_apps_enabled] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK__app] PRIMARY KEY CLUSTERED ([AppID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [ORNG.].[Apps])
    BEGIN
        INSERT INTO [ORNG.].[tmp_ms_xx_Apps] ([AppID], [name], [url], [PersonFilterID], [enabled])
        SELECT   [AppID],
                 [name],
                 [url],
                 [PersonFilterID],
                 [enabled]
        FROM     [ORNG.].[Apps]
        ORDER BY [AppID] ASC;
    END

DROP TABLE [ORNG.].[Apps];

EXECUTE sp_rename N'[ORNG.].[tmp_ms_xx_Apps]', N'Apps';

EXECUTE sp_rename N'[ORNG.].[tmp_ms_xx_constraint_PK__app]', N'PK__app', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [ORNG.].[FK_orng_app_views_apps]...';


GO
ALTER TABLE [ORNG.].[AppViews] WITH NOCHECK
    ADD CONSTRAINT [FK_orng_app_views_apps] FOREIGN KEY ([AppID]) REFERENCES [ORNG.].[Apps] ([AppID]);


GO
PRINT N'Creating [ORNG.].[vwAppPersonData]...';


GO

CREATE VIEW [ORNG.].[vwAppPersonData] as
	SELECT m.InternalID + '-' + CAST(a.AppID as varchar) + '-' + d.Keyname PrimaryId, 
	 m.InternalID + '-' + CAST(a.AppID as varchar)PersonIdAppId,
	 m.InternalID PersonId, a.AppID,
	 a.Name AppName, d.Keyname, d.Value FROM [ORNG.].[Apps] a 
	 join [ORNG.].AppData d on a.AppID = d.AppID 
	 join [RDF.Stage].InternalNodeMap m on d.NodeID = m.NodeID
GO
PRINT N'Creating [ORNG.].[vwPerson]...';


GO
create view [ORNG.].[vwPerson]
as
SELECT n.nodeId
      ,par.[Value] + '/display/' +  cast (n.nodeId as nvarchar(50))  as profileURL, p.IsActive
  FROM [Framework.].Parameter par JOIN
  [Profile.Data].[Person] p ON  par.[ParameterID] = 'basePath'
	LEFT JOIN [RDF.Stage].internalnodemap n on n.internalid = p.personId
	and n.[class] = 'http://xmlns.com/foaf/0.1/Person'
GO
PRINT N'Creating [ORNG.].[AddAppToOntology]...';


GO

CREATE PROCEDURE [ORNG.].[AddAppToOntology](@AppID INT, 
										   @EditView nvarchar(100) = 'home',
										   @EditOptParams nvarchar(255) = '{''hide_titlebar'':1}', --'{''gadget_class'':''ORNGToggleGadget'', ''start_closed'':0, ''hideShow'':1, ''closed_width'':700}',
										   @ProfileView nvarchar(100) = 'profile',
										   @ProfileOptParams nvarchar(255) = '{''hide_titlebar'':1}',
										   @SessionID UNIQUEIDENTIFIER=NULL, 
										   @Error BIT=NULL OUTPUT, 
										   @NodeID BIGINT=NULL OUTPUT)
As
BEGIN
	SET NOCOUNT ON
		-- Cat2
		DECLARE @InternalType nvarchar(100) = null -- lookup from import.twitter
		DECLARE @Name nvarchar(255)
		DECLARE @URL nvarchar(255)
		DECLARE @LabelNodeID BIGINT
		DECLARE @ApplicationIdNodeID BIGINT
		DECLARE @ApplicationURLNodeID BIGINT
		DECLARE @DataMapID int
		DECLARE @TableName nvarchar(255)
		DECLARE @ClassPropertyName nvarchar(255)
		DECLARE @ClassPropertyLabel nvarchar(255)
		DECLARE @CustomDisplayModule XML
		DECLARE @CustomEditModule XML
		
		SELECT @InternalType = n.value FROM [rdf.].[Triple] t JOIN [rdf.].Node n ON t.[Object] = n.NodeID 
			WHERE t.[Subject] = [RDF.].fnURI2NodeID('http://orng.info/ontology/orng#Application')
			and t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SELECT @URL = url FROM [ORNG.].[Apps] WHERE AppID = @AppID
			
		-- Add the Nodes for the application, its Id and URL
		EXEC [RDF.].GetStoreNode	@Class = 'http://orng.info/ontology/orng#Application',
									@InternalType = @InternalType,
									@InternalID = @Name,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @NodeID OUTPUT		
		EXEC [RDF.].GetStoreNode @Value = @Name, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @LabelNodeID OUTPUT	
		EXEC [RDF.].GetStoreNode @Value = @AppID, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @ApplicationIdNodeID OUTPUT	
		EXEC [RDF.].GetStoreNode @Value = @URL, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @ApplicationURLNodeID OUTPUT	
		-- Add the Type
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://orng.info/ontology/orng#Application',
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the Label
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
									@ObjectID = @LabelNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the triples for the application, we assume label and class are already wired
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationId',
									@ObjectID = @ApplicationIdNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationURL',
									@ObjectID = @ApplicationURLNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT																																
		
		-- create a custom property to associate an instance of this application to a person
		SET @ClassPropertyName = 'http://orng.info/ontology/orng#has' + @Name
		SELECT @ClassPropertyLabel = Name
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SET @CustomEditModule = cast(N'<Module ID="EditPersonalGadget">
					<ParamList>
					  <Param Name="AppId">' + cast(@AppID as varchar) + '</Param>
					  <Param Name="Label">' + @ClassPropertyLabel + '</Param>
					  <Param Name="View">' + @EditView + '</Param>
					  <Param Name="OptParams">' + @EditOptParams + '</Param>
					</ParamList>
				  </Module>' as XML)
		SET @CustomDisplayModule = cast(N'<Module ID="ViewPersonalGadget">
					<ParamList>
					  <Param Name="AppId">' + cast(@AppID as varchar) + '</Param>
					  <Param Name="Label">' + @ClassPropertyLabel + '</Param>
					  <Param Name="View">' + @ProfileView + '</Param>
					  <Param Name="OptParams">' + @ProfileOptParams + '</Param>
					</ParamList>
				  </Module>' as XML)				
		EXEC [Ontology.].[AddProperty]	@OWL = 'ORNG_1.0', 
										@PropertyURI = @ClassPropertyName,
										@PropertyName = @ClassPropertyLabel,
										@ObjectType = 0,
										@PropertyGroupURI = 'http://orng.info/ontology/orng#PropertyGroupORNGApplications', 
										@ClassURI = 'http://xmlns.com/foaf/0.1/Person',
										@IsDetail = 0,
										@IncludeDescription = 0								
		UPDATE [Ontology.].[ClassProperty] set EditExistingSecurityGroup = -20, IsDetail = 0, IncludeDescription = 0,
				CustomEdit = 1, CustomEditModule = @CustomEditModule,
				CustomDisplay = 1, CustomDisplayModule = @CustomDisplayModule,
				EditSecurityGroup = -20, EditPermissionsSecurityGroup = -20, -- was -20's
				EditAddNewSecurityGroup = -20, EditAddExistingSecurityGroup = -20, EditDeleteSecurityGroup = -20 
			WHERE property = @ClassPropertyName;
END

/****** Object:  StoredProcedure [ORNG.].[RemoveAppFromOntology]    Script Date: 10/11/2013 09:44:25 ******/
SET ANSI_NULLS ON
GO
PRINT N'Creating [ORNG.].[AddAppToPerson]...';


GO

CREATE PROCEDURE [ORNG.].[AddAppToPerson]
@SubjectID BIGINT=NULL, @SubjectURI nvarchar(255)=NULL, @AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Cat2
	DECLARE @InternalType nvarchar(100) = null -- lookup from import.twitter
	DECLARE @InternalID nvarchar(100) = null -- lookpup personid and add appID
	DECLARE @PersonID INT
	DECLARE @PersonName nvarchar(255)
	DECLARE @Label nvarchar(255) = null
	DECLARE @LabelID BIGINT
	DECLARE @AppName NVARCHAR(100)
	DECLARE @ApplicationNodeID BIGINT
	DECLARE @PredicateURI nvarchar(255) -- this could be passed in for some situations
	DECLARE @PERSON_FILTER_ID INT
	
	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	SELECT @InternalType = [Object] FROM [Ontology.Import].[Triple] 
		WHERE [Subject] = 'http://orng.info/ontology/orng#ApplicationInstance' AND [Predicate] = 'http://www.w3.org/2000/01/rdf-schema#label'
		
	SELECT @PersonID = cast(InternalID as INT), @InternalID = InternalID + '-' + CAST(@AppID as varchar) FROM [RDF.Stage].[InternalNodeMap]
		WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'
		
	SELECT @PersonName = DisplayName from [Profile.Data].Person WHERE PersonID = @PersonID
	--- this odd label format is required for the DataMap items to work properly!
	SELECT @Label = 'http://orng.info/ontology/orng#ApplicationInstance^^' +
					@InternalType + '^^' + @InternalID
					
					
	-- Convert the AppID to an AppName based on its URL
	SELECT @AppName = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
		FROM [ORNG.].[Apps] 
		WHERE AppID = @AppID

	-- STOP, should we test that the PredicateURI is consistent with the AppID?
	SELECT @PredicateURI = 'http://orng.info/ontology/orng#has'+@AppName
				
	SELECT @ApplicationNodeID  = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#Application' AND InternalType = 'ORNG Application'
			AND InternalID = @AppName

		
	----------------------------------------------------------------
	-- Determine if this app has already been added to this person
	----------------------------------------------------------------
	DECLARE @AppInstanceID BIGINT
	SELECT @AppInstanceID = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNG Application Instance'
			AND InternalID = @InternalID
	IF @AppInstanceID IS NOT NULL
	BEGIN
		-- Determine the ViewSecurityGroup
		DECLARE @ViewSecurityGroup BIGINT
		SELECT @ViewSecurityGroup = IsNull(p.ViewSecurityGroup,c.ViewSecurityGroup)
			FROM [Ontology.].ClassProperty c
				LEFT OUTER JOIN [RDF.Security].NodeProperty p
					ON p.Property = c._PropertyNode AND p.NodeID = @SubjectID
			WHERE c.Class = 'http://xmlns.com/foaf/0.1/Person'
				AND c.Property = @PredicateURI
				AND c.NetworkProperty IS NULL

		-- Change the security group of the triple
		UPDATE [RDF.].[Triple]
			SET ViewSecurityGroup = @ViewSecurityGroup
			WHERE Subject = @SubjectID AND Object = @AppInstanceID

		-- Exit the proc
		RETURN;
	END


	----------------------------------------------------------------
	-- Add the app to the person for the first time
	----------------------------------------------------------------
	SELECT @Error = 0
	BEGIN TRAN
		-- We want Type 2.  Lookup internal type from import.triple, pass in AppID
		EXEC [RDF.].GetStoreNode	@Class = 'http://orng.info/ontology/orng#ApplicationInstance',
									@InternalType = @InternalType,
									@InternalID = @InternalID,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @NodeID OUTPUT
		-- for some reason, this Status in [RDF.Stage].InternalNodeMap is set to 0, not 3.  This causes issues so
		-- we fix
		UPDATE [RDF.Stage].[InternalNodeMap] SET [Status] = 3 WHERE NodeID = @NodeID						
			
		EXEC [RDF.].GetStoreNode @Value = @Label, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @LabelID OUTPUT	

		-- Add the Type
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://orng.info/ontology/orng#ApplicationInstance',
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the Label
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
									@ObjectID = @LabelID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Link the ApplicationInstance to the Application
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationInstanceOfApplication',
									@ObjectID = @ApplicationNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT		
		-- Link the ApplicationInstance to the person
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationInstanceForPerson',
									@ObjectID = @SubjectID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT								
		-- Link the person to the ApplicationInstance
		EXEC [RDF.].GetStoreTriple	@SubjectID = @SubjectID,
									@PredicateURI = @PredicateURI,
									@ObjectID = @NodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		
		-- wire in the filter to both the import and live tables
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE AppID = @AppID AND PersonFilterID NOT IN (
				SELECT personFilterId FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID))
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				INSERT [Profile.Import].[PersonFilterFlag]
					SELECT InternalUserName, PersonFilter FROM [Profile.Data].[Person], [Profile.Data].[Person.Filter]
						WHERE PersonID = @PersonID AND PersonFilterID = @PERSON_FILTER_ID
				INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) values (@PersonID, @PERSON_FILTER_ID)
			END
	COMMIT	
END
GO
PRINT N'Creating [ORNG.].[IsRegistered]...';


GO

CREATE PROCEDURE  [ORNG.].[IsRegistered](@Subject BIGINT = NULL, @Uri nvarchar(255) = NULL, @AppID INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nodeid bigint
	
	IF (@Subject IS NOT NULL) 
		SET @nodeId = @Subject
	ELSE		
		SELECT @nodeid = [RDF.].[fnURI2NodeID](@Uri);

	SELECT * from [ORNG.].AppRegistry where AppID=@AppID AND NodeID = @NodeID 
END
GO
PRINT N'Creating [ORNG.].[ReadPerson]...';


GO


CREATE PROCEDURE  [ORNG.].[ReadPerson](@uri nvarchar(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nodeid bigint
	
	SELECT @nodeid = [RDF.].[fnURI2NodeID](@uri);

	SELECT * from [ORNG.].[vwPerson] WHERE nodeId = @nodeid
END
GO
PRINT N'Creating [ORNG.].[RemoveAppFromOntology]...';


GO

CREATE PROCEDURE [ORNG.].[RemoveAppFromOntology](@AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT)
As
BEGIN
	SET NOCOUNT ON
		DECLARE @Name nvarchar(255)
		DECLARE @PropertyURI nvarchar(255)
		
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SET @PropertyURI = 'http://orng.info/ontology/orng#has' + @Name				
			
		IF (@PropertyURI IS NOT NULL)
		BEGIN	
			DELETE FROM [Ontology.].[ClassProperty]	WHERE Property = @PropertyURI
			DELETE FROM [Ontology.].[PropertyGroupProperty] WHERE PropertyURI = @PropertyURI
		END

		DECLARE @PropertyNode BIGINT
		SELECT @PropertyNode = _PropertyNode FROM [Ontology.].[ClassProperty] WHERE
			Class = 'http://orng.info/ontology/orng#Application' and 
			Property = 'http://orng.info/ontology/orng#applicationId' --_PropertyNode
		SELECT @NodeID = t.[Subject] FROM [RDF.].Triple t JOIN
			[RDF.].Node n ON t.[Object] = n.nodeid 
			WHERE t.Predicate = @PropertyNode AND n.[Value] = CAST(@AppID as varchar)
		
		IF (@NodeID IS NOT NULL)
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @NodeID, @DeleteType = 0								   
		END	
END

/****** Object:  StoredProcedure [ORNG.].[AddAppToPerson]    Script Date: 10/11/2013 09:47:38 ******/
SET ANSI_NULLS ON
GO
PRINT N'Creating [ORNG.].[RemoveAppFromPerson]...';


GO

CREATE PROCEDURE [ORNG.].[RemoveAppFromPerson]
@SubjectID BIGINT=NULL, @SubjectURI nvarchar(255)=NULL, @AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @AppInstanceID BIGINT
	DECLARE @TripleID BIGINT
	DECLARE @PersonID INT	
	DECLARE @PERSON_FILTER_ID INT
	DECLARE @InternalUserName nvarchar(50)
	DECLARE @PersonFilter nvarchar(50)

	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	-- Lookup the PersonID
	SELECT @PersonID = cast(InternalID as INT)
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://xmlns.com/foaf/0.1/Person' AND InternalType = 'Person' AND NodeID = @SubjectID

	-- Lookup the App Instance's NodeID
	SELECT @AppInstanceID = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNG Application Instance'
			AND InternalID = CAST(@PersonID AS VARCHAR(50)) + '-' + CAST(@AppID AS VARCHAR(50))
	
		
	-- now delete it
	BEGIN TRAN

		-- Delete the triple using DeleteType = 1 (changing the security group to 0)
		EXEC [RDF.].DeleteTriple	@SubjectID = @SubjectID,
									@ObjectID = @AppInstanceID,
									@DeleteType = 1,
									@SessionID = @SessionID, 
									@Error = @Error

		-- remove any filters
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE AppID = @AppID)
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				SELECT @PersonID = cast(InternalID as INT) FROM [RDF.Stage].[InternalNodeMap]
					WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'

				SELECT @InternalUserName = InternalUserName FROM [Profile.Data].[Person] WHERE PersonID = @PersonID
				SELECT @PersonFilter = PersonFilter FROM [Profile.Data].[Person.Filter] WHERE PersonFilterID = @PERSON_FILTER_ID

				DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE InternalUserName = @InternalUserName AND personfilter = @PersonFilter
				DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID AND personFilterId = @PERSON_FILTER_ID
			END
	COMMIT
END
GO
PRINT N'Checking existing data against newly created constraints';



GO
ALTER TABLE [ORNG.].[AppViews] WITH CHECK CHECK CONSTRAINT [FK_orng_app_views_apps];

create table #tmpAppData
(
	[NodeID] [bigint] NOT NULL,
	[AppID] [int] NOT NULL,
	[Keyname] [nvarchar](255) NOT NULL,
	[Value] [nvarchar](4000) NULL,
	[CreatedDT] [datetime] NULL,
	[UpdatedDT] [datetime] NULL
)


declare @nodeID bigint
declare @appID int
declare @keyName nvarchar(255)
declare @Value nvarchar(4000)
declare @CreatedDT datetime
declare @UpdatedDT datetime
declare @linksCount int
DECLARE db_cursor CURSOR FOR  
SELECT nodeID, appId, keyName, value, CreatedDT, UpdatedDT
FROM [ORNG.].AppData


OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @nodeId, @appID, @keyName, @value, @CreatedDT, @UpdatedDT

WHILE @@FETCH_STATUS = 0   
BEGIN   
	if(@appID = 103)
	Begin
	    DECLARE @start INT, @end INT 
		SELECT @start = CHARINDEX('{', @value)
		select @end = CHARINDEX('},{', @value)
		select @linksCount = 0
		WHILE @start < LEN(@value) + 1 BEGIN 
		    IF @end = 0  
			    SET @end = LEN(@value) - 1
       
			INSERT INTO #tmpAppData (NodeID, AppID, Keyname, Value, CreatedDT, UpdatedDT)
			VALUES(@NodeId, @appID, 'link_' + cast(@linksCount as nvarchar(10)), SUBSTRING(@value, @start, @end + 1 - @start), @createdDT, @updatedDT) 
			SET @start = @end + 2 
			SET @end = CHARINDEX('},{', @value, @start)
			SET @linksCount = @linksCount + 1
		END
		if @linksCount<>0
		begin
			INSERT INTO #tmpAppData (NodeID, AppID, Keyname, Value, CreatedDT, UpdatedDT)
			values( @nodeID, @appID, 'links_count', @linksCount, @CreatedDT, @UpdatedDT)
		End
        
	End
	else
	Begin
		INSERT INTO #tmpAppData (NodeID, AppID, Keyname, Value, CreatedDT, UpdatedDT)
		values( @nodeID, @appID, @keyName, @value, @CreatedDT, @UpdatedDT)
	End
    
	FETCH NEXT FROM db_cursor INTO @nodeId, @appID, @keyName, @value, @CreatedDT, @UpdatedDT     
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

delete from [ORNG.].AppData where keyname like 'links'
insert into [ORNG.].AppData select * From #tmpAppData where keyname like 'link%'
update [ORNG.].AppData set value = replace(replace(value, '"link_name"', '"name"'), '"link_url"', '"url"') where appid = 103
drop table #tmpAppData


GO
PRINT N'Altering [ORNG.].[AppViews]...';

GO
ALTER TABLE [ORNG.].[AppViews]
    ADD [DisplayOrder] INT            NULL,
        [OptParams]    NVARCHAR (255) NULL;
GO

update [ORNG.].[AppViews] set DisplayOrder = display_order, OptParams = opt_params

GO
ALTER TABLE [ORNG.].[AppViews] DROP COLUMN [display_order], COLUMN [opt_params];