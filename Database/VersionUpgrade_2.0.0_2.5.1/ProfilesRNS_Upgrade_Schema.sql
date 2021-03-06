/*
Run this script on:

        Profiles 2.0.0    -  This database will be modified

to synchronize it with:

        Profiles 2.5.1

You are recommended to back up your database before running this script

Lines 20 to 533 create the v2.0.0 ORNG objects if they were not installed. In v2.5.1, the ORNG schema objects are always created. ORNG will be disabled during the upgrade is the ORNG schema does not exist.
Lines 534 to 11275 update schema objects to the v2.5.1 versions.
Details of which objects have changed can be found in the release notes.
If you have made changes to existing tables or stored procedures in profiles, you may need to merge changes individually. 

*/


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'ORNG.')
EXEC sys.sp_executesql N'CREATE SCHEMA [ORNG.]'

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[DeleteActivity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [ORNG.].[DeleteActivity](@uri nvarchar(255),@appId INT, @activityId int)
As
BEGIN
	SET NOCOUNT ON
	DECLARE @nodeid bigint
	
	select @nodeid = [RDF.].[fnURI2NodeID](@uri);	
	DELETE [ORNG.].[Activity] WHERE nodeId = @nodeId AND appId = @appId and activityId = @activityId
END		
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[DeleteAppData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [ORNG.].[DeleteAppData](@uri nvarchar(255),@appId INT, @keyname nvarchar(255))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @nodeid bigint
	
	SELECT @nodeid = [RDF.].[fnURI2NodeID](@uri);
	DELETE [ORNG.].[AppData] WHERE nodeId = @nodeId AND appId = @appId and keyname = @keyName
END		

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[InsertActivity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [ORNG.].[InsertActivity](@uri nvarchar(255),@appId INT, @activityId int, @activity XML)
As
BEGIN
	SET NOCOUNT ON
	DECLARE @nodeid bigint
	
	select @nodeid = [RDF.].[fnURI2NodeID](@uri);	
	IF (@activityId IS NULL OR @activityId < 0)
		INSERT [ORNG.].[Activity] (nodeId, appId, activity) values (@nodeid, @appId, @activity)
	ELSE 		
		INSERT [ORNG.].[Activity] (activityId, nodeId, appId, activity) values (@activityId, @nodeid, @appId, @activity)
END		
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[InsertMessage]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [ORNG.].[InsertMessage](@msgId nvarchar(255),@coll nvarchar(255), @title nvarchar(255), @body nvarchar(255),
										@senderUri nvarchar(255), @recipientUri nvarchar(255))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @senderNodeId bigint
	DECLARE @recipientNodeId bigint
	
	select @senderNodeId = [RDF.].[fnURI2NodeID](@senderUri)
	select @recipientNodeId = [RDF.].[fnURI2NodeID](@recipientUri)
	
	INSERT [ORNG.].[Messages]  (msgId, coll, title, body, senderNodeId, recipientNodeId) 
			VALUES (@msgId, @coll, @title, @body, @senderNodeId, @recipientNodeId)
END		
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[ReadActivity]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE  [ORNG.].[ReadActivity](@uri nvarchar(255),@appId INT, @activityId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nodeid bigint
	
	select @nodeid = [RDF.].[fnURI2NodeID](@uri);

	select activity from [ORNG.].Activity where nodeId = @nodeid AND appId=@appId AND activityId =@activityId
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[ReadAllActivities]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE  [ORNG.].[ReadAllActivities](@uri nvarchar(255),@appId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nodeid bigint
	
	select @nodeid = [RDF.].[fnURI2NodeID](@uri);

	IF (@appId IS NULL)
		select activity from [ORNG.].Activity where nodeId = @nodeid
	ELSE		
		select activity from [ORNG.].Activity where nodeId = @nodeid AND appId=@appId 
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[ReadAppData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE  [ORNG.].[ReadAppData](@uri nvarchar(255),@appId INT, @keyname nvarchar(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nodeid bigint
	
	SELECT @nodeid = [RDF.].[fnURI2NodeID](@uri);

	SELECT value from [ORNG.].AppData where appId=@appId AND nodeId = @nodeid AND keyName = @keyname
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[ReadMessageCollections]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE  [ORNG.].[ReadMessageCollections](@recipientUri nvarchar(255))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @recipientNodeId bigint
	
	select @recipientNodeId = [RDF.].[fnURI2NodeID](@recipientUri)

	SELECT DISTINCT coll	FROM [ORNG.].[Messages] WHERE recipientNodeId =  @recipientNodeId
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[ReadMessages]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE  [ORNG.].[ReadMessages](@recipientUri nvarchar(255),@coll nvarchar(255), @msgIds nvarchar(max))
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @recipientNodeId bigint
	DECLARE @baseURI nvarchar(255)
	DECLARE @sql nvarchar(255)
	
	select @recipientNodeId = [RDF.].[fnURI2NodeID](@recipientUri)
	select @baseURI = [Value] FROM [Framework.].[Parameter] WHERE ParameterID = ''baseURI'';
	
	SET @sql = ''SELECT msgId, coll, body, title, '''''' + @baseURI  + ''''''+ senderNodeId , '''''' + @baseURI + ''''''+ recipientNodeId '' +
		''FROM [ORNG.].[Messages] WHERE recipientNodeId = '' + @recipientNodeId
	IF (@coll IS NOT NULL)
		SET @sql = @sql + '' AND coll = '''''' + @coll + '''''''';
	IF (@msgIds IS NOT NULL)
		SET @sql = @sql + '' AND msgId IN '' + @msgIds
		
	EXEC @sql;
END
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[ReadRegistry]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE  [ORNG.].[ReadRegistry](@uri nvarchar(255),@appId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @nodeid bigint
	
	SELECT @nodeid = [RDF.].[fnURI2NodeID](@uri);

	SELECT visibility from [ORNG.].AppRegistry where appId=@appId AND nodeId = @nodeid 
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[RegisterAppPerson]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [ORNG.].[RegisterAppPerson](@uri nvarchar(255),@appId INT, @visibility nvarchar(50))
As
BEGIN
	SET NOCOUNT ON
		BEGIN TRAN		
			DECLARE @NodeID bigint
			DECLARE @PERSON_FILTER_ID INT
			DECLARE @PERSON_ID INT
				
			SELECT @NodeID = [RDF.].[fnURI2NodeID](@uri)
			SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE appId = @appId)
			SELECT @PERSON_ID = cast(InternalID as INT) from [RDF.Stage].InternalNodeMap where
				NodeID = @NodeID

			IF ((SELECT COUNT(*) FROM AppRegistry WHERE nodeId= @nodeId AND appId = @appId) = 0)
				INSERT [ORNG.].[AppRegistry](nodeId, appid, [visibility]) values (@NodeID, @appId, @visibility)
			ELSE 
				UPDATE [ORNG.].[AppRegistry] set [visibility] = @visibility where nodeId = @NodeID and appId = @appId 
								
			IF (@PERSON_FILTER_ID IS NOT NULL) 
				BEGIN
					IF (@visibility = ''Public'') 
						INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) values (@PERSON_ID, @PERSON_FILTER_ID)
					ELSE						
						DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PERSON_ID AND personFilterId = @PERSON_FILTER_ID
				END
		COMMIT
END

' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[UpsertAppData]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [ORNG.].[UpsertAppData](@uri nvarchar(255),@appId INT, @keyname nvarchar(255),@value nvarchar(4000))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @nodeid bigint
	
	SELECT @nodeid = [RDF.].[fnURI2NodeID](@uri);
	IF (SELECT COUNT(*) FROM AppData WHERE nodeId = @nodeId AND appId = @appId and keyname = @keyName) > 0
		UPDATE [ORNG.].[AppData] set [value] = @value, updatedDT = GETDATE() WHERE nodeId = @nodeId AND appId = @appId and keyname = @keyName
	ELSE
		INSERT [ORNG.].[AppData] (nodeId, appId, keyname, [value]) values (@nodeId, @appId, @keyname, @value)
END		
' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[Activity]') AND type in (N'U'))
BEGIN
CREATE TABLE [ORNG.].[Activity](
	[activityId] [int] IDENTITY(1,1) NOT NULL,
	[nodeid] [bigint] NULL,
	[appId] [int] NULL,
	[createdDT] [datetime] NULL,
	[activity] [xml] NULL,
 CONSTRAINT [PK__activity] PRIMARY KEY CLUSTERED 
(
	[activityId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[AppData]') AND type in (N'U'))
BEGIN
CREATE TABLE [ORNG.].[AppData](
	[nodeId] [bigint] NOT NULL,
	[appId] [int] NOT NULL,
	[keyname] [nvarchar](255) NOT NULL,
	[value] [nvarchar](4000) NULL,
	[createdDT] [datetime] NULL,
	[updatedDT] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[AppRegistry]') AND type in (N'U'))
BEGIN
CREATE TABLE [ORNG.].[AppRegistry](
	[nodeid] [bigint] NOT NULL,
	[appId] [int] NOT NULL,
	[visibility] [nvarchar](50) NULL,
	[createdDT] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[Apps]') AND type in (N'U'))
BEGIN
CREATE TABLE [ORNG.].[Apps](
	[appId] [int] NOT NULL,
	[name] [nvarchar](255) NOT NULL,
	[url] [nvarchar](255) NULL,
	[PersonFilterID] [int] NULL,
	[enabled] [bit] NOT NULL,
 CONSTRAINT [PK__app] PRIMARY KEY CLUSTERED 
(
	[appId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[AppViews]') AND type in (N'U'))
BEGIN
CREATE TABLE [ORNG.].[AppViews](
	[appId] [int] NOT NULL,
	[page] [nvarchar](50) NULL,
	[view] [nvarchar](50) NULL,
	[chromeId] [nvarchar](50) NULL,
	[visibility] [nvarchar](50) NULL,
	[display_order] [int] NULL,
	[opt_params] [nvarchar](255) NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[Messages]') AND type in (N'U'))
BEGIN
CREATE TABLE [ORNG.].[Messages](
	[msgId] [nvarchar](255) NOT NULL,
	[senderNodeId] [bigint] NULL,
	[recipientNodeId] [bigint] NULL,
	[coll] [nvarchar](255) NULL,
	[title] [nvarchar](255) NULL,
	[body] [nvarchar](4000) NULL,
	[createdDT] [datetime] NULL
) ON [PRIMARY]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ORNG.].[Visibility]') AND type in (N'U'))
BEGIN
CREATE TABLE [ORNG.].[Visibility](
	[visibility] [nvarchar](50) NOT NULL,
	[description] [nvarchar](255) NULL,
 CONSTRAINT [PK_ORNG.Visibility] PRIMARY KEY CLUSTERED 
(
	[visibility] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[ORNG.].[AppRegistry]') AND name = N'IX_AppRegistry_nodeid')
CREATE CLUSTERED INDEX [IX_AppRegistry_nodeid] ON [ORNG.].[AppRegistry]
(
	[nodeid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[ORNG.].[AppData]') AND name = N'IDX_PersonApp')
CREATE NONCLUSTERED INDEX [IDX_PersonApp] ON [ORNG.].[AppData]
(
	[nodeId] ASC,
	[appId] ASC
)
INCLUDE ( 	[keyname],
	[value]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ORNG.].[DF_orng_activity_createdDT]') AND type = 'D')
BEGIN
ALTER TABLE [ORNG.].[Activity] ADD  CONSTRAINT [DF_orng_activity_createdDT]  DEFAULT (getdate()) FOR [createdDT]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ORNG.].[DF_orng_appdata_createdDT]') AND type = 'D')
BEGIN
ALTER TABLE [ORNG.].[AppData] ADD  CONSTRAINT [DF_orng_appdata_createdDT]  DEFAULT (getdate()) FOR [createdDT]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ORNG.].[DF_orng_appdata_updatedDT]') AND type = 'D')
BEGIN
ALTER TABLE [ORNG.].[AppData] ADD  CONSTRAINT [DF_orng_appdata_updatedDT]  DEFAULT (getdate()) FOR [updatedDT]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ORNG.].[DF_orng_app_registry_createdDT]') AND type = 'D')
BEGIN
ALTER TABLE [ORNG.].[AppRegistry] ADD  CONSTRAINT [DF_orng_app_registry_createdDT]  DEFAULT (getdate()) FOR [createdDT]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ORNG.].[DF_orng_apps_enabled]') AND type = 'D')
BEGIN
ALTER TABLE [ORNG.].[Apps] ADD  CONSTRAINT [DF_orng_apps_enabled]  DEFAULT ((1)) FOR [enabled]
END

GO
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[ORNG.].[DF_orng_messages_createdDT]') AND type = 'D')
BEGIN
ALTER TABLE [ORNG.].[Messages] ADD  CONSTRAINT [DF_orng_messages_createdDT]  DEFAULT (getdate()) FOR [createdDT]
END

GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ORNG.].[FK_AppRegistry_Visibility]') AND parent_object_id = OBJECT_ID(N'[ORNG.].[AppRegistry]'))
ALTER TABLE [ORNG.].[AppRegistry]  WITH CHECK ADD  CONSTRAINT [FK_AppRegistry_Visibility] FOREIGN KEY([visibility])
REFERENCES [ORNG.].[Visibility] ([visibility])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ORNG.].[FK_AppRegistry_Visibility]') AND parent_object_id = OBJECT_ID(N'[ORNG.].[AppRegistry]'))
ALTER TABLE [ORNG.].[AppRegistry] CHECK CONSTRAINT [FK_AppRegistry_Visibility]
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ORNG.].[FK_orng_app_views_apps]') AND parent_object_id = OBJECT_ID(N'[ORNG.].[AppViews]'))
ALTER TABLE [ORNG.].[AppViews]  WITH CHECK ADD  CONSTRAINT [FK_orng_app_views_apps] FOREIGN KEY([appId])
REFERENCES [ORNG.].[Apps] ([appId])
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[ORNG.].[FK_orng_app_views_apps]') AND parent_object_id = OBJECT_ID(N'[ORNG.].[AppViews]'))
ALTER TABLE [ORNG.].[AppViews] CHECK CONSTRAINT [FK_orng_app_views_apps]
GO

IF NOT EXISTS (SELECT * FROM [ORNG.].[Apps])
BEGIN
	INSERT [ORNG.].[Apps] VALUES(10,'RDF Test','http://stage-profiles.ucsf.edu/apps_200/RDFTest.xml',NULL,0);
	INSERT [ORNG.].[Apps] VALUES(101,'Featured Presentations','http://stage-profiles.ucsf.edu/apps_200/SlideShare.xml',NULL,0);
	INSERT [ORNG.].[Apps] VALUES(102,'Faculty Mentoring','http://stage-profiles.ucsf.edu/apps_200/Mentor.xml',NULL,0);
	INSERT [ORNG.].[Apps] VALUES(103,'Websites','http://stage-profiles.ucsf.edu/apps_200/Links.xml',NULL,0);
	INSERT [ORNG.].[Apps] VALUES(112,'Twitter','http://stage-profiles.ucsf.edu/apps_200/Twitter.xml',NULL,0);
	INSERT [ORNG.].[Apps] VALUES(114,'Featured Videos','http://stage-profiles.ucsf.edu/apps_200/YouTube.xml',NULL,0);
END


GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;

-- End of ORNG Section.


GO

PRINT N'Dropping [RDF.SemWeb].[vwHash2Base64].[idx_NodeID]...';


GO
DROP INDEX [idx_NodeID]
    ON [RDF.SemWeb].[vwHash2Base64];


GO
PRINT N'Dropping [Search.Cache].[Private.NodeMap].[idx_ms]...';


GO
DROP INDEX [idx_ms]
    ON [Search.Cache].[Private.NodeMap];


GO
PRINT N'Dropping [Search.Cache].[Public.NodeMap].[idx_ms]...';


GO
DROP INDEX [idx_ms]
    ON [Search.Cache].[Public.NodeMap];


GO
PRINT N'Dropping [RDF.SemWeb].[vwHash2Base64].[idx_SemWebHash]...';


GO
DROP INDEX [idx_SemWebHash]
    ON [RDF.SemWeb].[vwHash2Base64];


GO
PRINT N'Creating [ORCID.]...';


GO
CREATE SCHEMA [ORCID.]
    AUTHORIZATION [dbo];


GO
PRINT N'Altering [Profile.Data].[Publication.PubMed.Author]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Author] ALTER COLUMN [Affiliation] VARCHAR (4000) NULL;


GO
PRINT N'Starting rebuilding table [Search.Cache].[Private.NodeMap]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [Search.Cache].[tmp_ms_xx_Private.NodeMap] (
    [NodeID]          BIGINT     NOT NULL,
    [MatchedByNodeID] BIGINT     NOT NULL,
    [Distance]        INT        NULL,
    [Paths]           INT        NULL,
    [Weight]          FLOAT (53) NULL,
    PRIMARY KEY CLUSTERED ([MatchedByNodeID] ASC, [NodeID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [Search.Cache].[Private.NodeMap])
    BEGIN
        INSERT INTO [Search.Cache].[tmp_ms_xx_Private.NodeMap] ([MatchedByNodeID], [NodeID], [Distance], [Paths], [Weight])
        SELECT   [MatchedByNodeID],
                 [NodeID],
                 [Distance],
                 [Paths],
                 [Weight]
        FROM     [Search.Cache].[Private.NodeMap]
        ORDER BY [MatchedByNodeID] ASC, [NodeID] ASC;
    END

DROP TABLE [Search.Cache].[Private.NodeMap];

EXECUTE sp_rename N'[Search.Cache].[tmp_ms_xx_Private.NodeMap]', N'Private.NodeMap';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [Search.Cache].[Private.NodeMap].[idx_sm]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_sm]
    ON [Search.Cache].[Private.NodeMap]([NodeID] ASC, [MatchedByNodeID] ASC);


GO
PRINT N'Starting rebuilding table [Search.Cache].[Public.NodeMap]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [Search.Cache].[tmp_ms_xx_Public.NodeMap] (
    [NodeID]          BIGINT     NOT NULL,
    [MatchedByNodeID] BIGINT     NOT NULL,
    [Distance]        INT        NULL,
    [Paths]           INT        NULL,
    [Weight]          FLOAT (53) NULL,
    PRIMARY KEY CLUSTERED ([MatchedByNodeID] ASC, [NodeID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [Search.Cache].[Public.NodeMap])
    BEGIN
        INSERT INTO [Search.Cache].[tmp_ms_xx_Public.NodeMap] ([MatchedByNodeID], [NodeID], [Distance], [Paths], [Weight])
        SELECT   [MatchedByNodeID],
                 [NodeID],
                 [Distance],
                 [Paths],
                 [Weight]
        FROM     [Search.Cache].[Public.NodeMap]
        ORDER BY [MatchedByNodeID] ASC, [NodeID] ASC;
    END

DROP TABLE [Search.Cache].[Public.NodeMap];

EXECUTE sp_rename N'[Search.Cache].[tmp_ms_xx_Public.NodeMap]', N'Public.NodeMap';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [Search.Cache].[Public.NodeMap].[idx_sm]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_sm]
    ON [Search.Cache].[Public.NodeMap]([NodeID] ASC, [MatchedByNodeID] ASC);


GO
PRINT N'Creating [ORCID.].[REF_AffiliationType]...';


GO
CREATE TABLE [ORCID.].[REF_AffiliationType] (
    [AffiliationTypeID] TINYINT      NOT NULL,
    [AffiliationType]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_REF_AffiliationType] PRIMARY KEY CLUSTERED ([AffiliationTypeID] ASC)
);


GO
PRINT N'Creating [ORCID.].[REF_Decision]...';


GO
CREATE TABLE [ORCID.].[REF_Decision] (
    [DecisionID]              TINYINT       IDENTITY (1, 1) NOT NULL,
    [DecisionDescription]     VARCHAR (150) NOT NULL,
    [DecisionDescriptionLong] VARCHAR (500) NOT NULL,
    CONSTRAINT [PK_REF_Decision] PRIMARY KEY CLUSTERED ([DecisionID] ASC)
);


GO
PRINT N'Creating [ORCID.].[REF_Permission]...';


GO
CREATE TABLE [ORCID.].[REF_Permission] (
    [PermissionID]          TINYINT        IDENTITY (1, 1) NOT NULL,
    [PermissionScope]       VARCHAR (100)  NOT NULL,
    [PermissionDescription] VARCHAR (500)  NOT NULL,
    [MethodAndRequest]      VARCHAR (100)  NULL,
    [SuccessMessage]        VARCHAR (1000) NULL,
    [FailedMessage]         VARCHAR (1000) NULL,
    CONSTRAINT [PK_REF_Permission] PRIMARY KEY CLUSTERED ([PermissionID] ASC)
);


GO
PRINT N'Creating [ORCID.].[REF_PersonStatusType]...';


GO
CREATE TABLE [ORCID.].[REF_PersonStatusType] (
    [PersonStatusTypeID] TINYINT      IDENTITY (1, 1) NOT NULL,
    [StatusDescription]  VARCHAR (75) NOT NULL,
    CONSTRAINT [PK_REF_PersonStatusType] PRIMARY KEY CLUSTERED ([PersonStatusTypeID] ASC)
);


GO
PRINT N'Creating [ORCID.].[REF_RecordStatus]...';


GO
CREATE TABLE [ORCID.].[REF_RecordStatus] (
    [RecordStatusID]    TINYINT       NOT NULL,
    [StatusDescription] VARCHAR (150) NOT NULL,
    CONSTRAINT [PK_REF_RecordStatus] PRIMARY KEY CLUSTERED ([RecordStatusID] ASC)
);


GO
PRINT N'Creating [ORCID.].[REF_WorkExternalType]...';


GO
CREATE TABLE [ORCID.].[REF_WorkExternalType] (
    [WorkExternalTypeID]      TINYINT       IDENTITY (1, 1) NOT NULL,
    [WorkExternalType]        VARCHAR (50)  NOT NULL,
    [WorkExternalDescription] VARCHAR (100) NOT NULL,
    CONSTRAINT [PK_REF_WorkExternalType] PRIMARY KEY CLUSTERED ([WorkExternalTypeID] ASC)
);


GO
PRINT N'Creating [ORCID.].[RecordLevelAuditType]...';


GO
CREATE TABLE [ORCID.].[RecordLevelAuditType] (
    [RecordLevelAuditTypeID] TINYINT      IDENTITY (1, 1) NOT NULL,
    [AuditType]              VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_RecordLevelAuditType] PRIMARY KEY CLUSTERED ([RecordLevelAuditTypeID] ASC)
);


GO
PRINT N'Creating [ORCID.].[RecordLevelAuditTrail]...';


GO
CREATE TABLE [ORCID.].[RecordLevelAuditTrail] (
    [RecordLevelAuditTrailID] BIGINT        IDENTITY (1, 1) NOT NULL,
    [MetaTableID]             INT           NOT NULL,
    [RowIdentifier]           BIGINT        NOT NULL,
    [RecordLevelAuditTypeID]  TINYINT       NOT NULL,
    [CreatedDate]             SMALLDATETIME NOT NULL,
    [CreatedBy]               VARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_RecordLevelAuditTrail] PRIMARY KEY CLUSTERED ([RecordLevelAuditTrailID] ASC)
);


GO
PRINT N'Creating [ORCID.].[Person]...';


GO
CREATE TABLE [ORCID.].[Person] (
    [PersonID]                 INT            IDENTITY (1, 1) NOT NULL,
    [InternalUsername]         NVARCHAR (100) NOT NULL,
    [PersonStatusTypeID]       TINYINT        NOT NULL,
    [CreateUnlessOptOut]       BIT            NOT NULL,
    [ORCID]                    VARCHAR (50)   NULL,
    [ORCIDRecorded]            SMALLDATETIME  NULL,
    [FirstName]                NVARCHAR (150) NULL,
    [LastName]                 NVARCHAR (150) NULL,
    [PublishedName]            NVARCHAR (500) NULL,
    [EmailDecisionID]          TINYINT        NULL,
    [EmailAddress]             VARCHAR (300)  NULL,
    [AlternateEmailDecisionID] TINYINT        NULL,
    [AgreementAcknowledged]    BIT            NULL,
    [Biography]                VARCHAR (5000) NULL,
    [BiographyDecisionID]      TINYINT        NULL,
    CONSTRAINT [PK_Person] PRIMARY KEY CLUSTERED ([PersonID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonMessage]...';


GO
CREATE TABLE [ORCID.].[PersonMessage] (
    [PersonMessageID]    INT            IDENTITY (1, 1) NOT NULL,
    [PersonID]           INT            NOT NULL,
    [XML_Sent]           VARCHAR (MAX)  NULL,
    [XML_Response]       VARCHAR (MAX)  NULL,
    [ErrorMessage]       VARCHAR (1000) NULL,
    [HttpResponseCode]   VARCHAR (50)   NULL,
    [MessagePostSuccess] BIT            NULL,
    [RecordStatusID]     TINYINT        NULL,
    [PermissionID]       TINYINT        NULL,
    [RequestURL]         VARCHAR (1000) NULL,
    [HeaderPost]         VARCHAR (1000) NULL,
    [UserMessage]        VARCHAR (2000) NULL,
    [PostDate]           SMALLDATETIME  NULL,
    CONSTRAINT [PK_PersonMessage] PRIMARY KEY CLUSTERED ([PersonMessageID] ASC)
);


GO
PRINT N'Creating [ORCID.].[DefaultORCIDDecisionIDMapping]...';


GO
CREATE TABLE [ORCID.].[DefaultORCIDDecisionIDMapping] (
    [SecurityGroupID]        BIGINT  NOT NULL,
    [DefaultORCIDDecisionID] TINYINT NULL,
    PRIMARY KEY CLUSTERED ([SecurityGroupID] ASC)
);


GO
PRINT N'Creating [ORCID.].[ErrorLog]...';


GO
CREATE TABLE [ORCID.].[ErrorLog] (
    [ErrorLogID]       INT           IDENTITY (1, 1) NOT NULL,
    [InternalUsername] NVARCHAR (11) NULL,
    [Exception]        TEXT          NOT NULL,
    [OccurredOn]       SMALLDATETIME NOT NULL,
    [Processed]        BIT           NOT NULL,
    CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrorLogID] ASC)
);


GO
PRINT N'Creating [ORCID.].[FieldLevelAuditTrail]...';


GO
CREATE TABLE [ORCID.].[FieldLevelAuditTrail] (
    [FieldLevelAuditTrailID]  BIGINT       IDENTITY (1, 1) NOT NULL,
    [RecordLevelAuditTrailID] BIGINT       NOT NULL,
    [MetaFieldID]             INT          NOT NULL,
    [ValueBefore]             VARCHAR (50) NULL,
    [ValueAfter]              VARCHAR (50) NULL,
    CONSTRAINT [PK_FieldLevelAuditTrail] PRIMARY KEY CLUSTERED ([FieldLevelAuditTrailID] ASC)
);


GO
PRINT N'Creating [ORCID.].[Organization.Institution.Disambiguation]...';


GO
CREATE TABLE [ORCID.].[Organization.Institution.Disambiguation] (
    [InstitutionID]        INT           NOT NULL,
    [DisambiguationID]     VARCHAR (100) NULL,
    [DisambiguationSource] VARCHAR (100) NULL,
    CONSTRAINT [PK__institution] PRIMARY KEY CLUSTERED ([InstitutionID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonAffiliation]...';


GO
CREATE TABLE [ORCID.].[PersonAffiliation] (
    [PersonAffiliationID]  INT            IDENTITY (1, 1) NOT NULL,
    [ProfilesID]           INT            NOT NULL,
    [AffiliationTypeID]    TINYINT        NOT NULL,
    [PersonID]             INT            NOT NULL,
    [PersonMessageID]      INT            NULL,
    [DecisionID]           TINYINT        NOT NULL,
    [DepartmentName]       VARCHAR (4000) NULL,
    [RoleTitle]            VARCHAR (200)  NULL,
    [StartDate]            SMALLDATETIME  NULL,
    [EndDate]              SMALLDATETIME  NULL,
    [OrganizationName]     VARCHAR (4000) NOT NULL,
    [OrganizationCity]     VARCHAR (4000) NULL,
    [OrganizationRegion]   VARCHAR (2)    NULL,
    [OrganizationCountry]  VARCHAR (2)    NULL,
    [DisambiguationID]     VARCHAR (500)  NULL,
    [DisambiguationSource] VARCHAR (500)  NULL,
    CONSTRAINT [PK_PersonAffiliation] PRIMARY KEY CLUSTERED ([PersonAffiliationID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonAlternateEmail]...';


GO
CREATE TABLE [ORCID.].[PersonAlternateEmail] (
    [PersonAlternateEmailID] INT           IDENTITY (1, 1) NOT NULL,
    [PersonID]               INT           NOT NULL,
    [EmailAddress]           VARCHAR (200) NOT NULL,
    [PersonMessageID]        INT           NULL,
    CONSTRAINT [PK_PersonAlternateEmail] PRIMARY KEY CLUSTERED ([PersonAlternateEmailID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonOthername]...';


GO
CREATE TABLE [ORCID.].[PersonOthername] (
    [PersonOthernameID] INT            IDENTITY (1, 1) NOT NULL,
    [PersonID]          INT            NOT NULL,
    [OtherName]         NVARCHAR (500) NULL,
    [PersonMessageID]   INT            NULL,
    CONSTRAINT [PK_PersonOthername] PRIMARY KEY CLUSTERED ([PersonOthernameID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonToken]...';


GO
CREATE TABLE [ORCID.].[PersonToken] (
    [PersonTokenID]   INT           IDENTITY (1, 1) NOT NULL,
    [PersonID]        INT           NOT NULL,
    [PermissionID]    TINYINT       NOT NULL,
    [AccessToken]     VARCHAR (50)  NOT NULL,
    [TokenExpiration] SMALLDATETIME NOT NULL,
    [RefreshToken]    VARCHAR (50)  NULL,
    CONSTRAINT [PK_PersonToken] PRIMARY KEY CLUSTERED ([PersonTokenID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonURL]...';


GO
CREATE TABLE [ORCID.].[PersonURL] (
    [PersonURLID]     INT            IDENTITY (1, 1) NOT NULL,
    [PersonID]        INT            NOT NULL,
    [PersonMessageID] INT            NULL,
    [URLName]         VARCHAR (500)  NULL,
    [URL]             VARCHAR (2000) NOT NULL,
    [DecisionID]      TINYINT        NOT NULL,
    CONSTRAINT [PK_PersonURL] PRIMARY KEY CLUSTERED ([PersonURLID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonWork]...';


GO
CREATE TABLE [ORCID.].[PersonWork] (
    [PersonWorkID]         INT            IDENTITY (1, 1) NOT NULL,
    [PersonID]             INT            NOT NULL,
    [PersonMessageID]      INT            NULL,
    [DecisionID]           TINYINT        NOT NULL,
    [WorkTitle]            VARCHAR (MAX)  NOT NULL,
    [ShortDescription]     VARCHAR (MAX)  NULL,
    [WorkCitation]         VARCHAR (MAX)  NULL,
    [WorkType]             VARCHAR (500)  NULL,
    [URL]                  VARCHAR (1000) NULL,
    [SubTitle]             VARCHAR (MAX)  NULL,
    [WorkCitationType]     VARCHAR (500)  NULL,
    [PubDate]              SMALLDATETIME  NULL,
    [PublicationMediaType] VARCHAR (500)  NULL,
    [PubID]                NVARCHAR (50)  NOT NULL,
    CONSTRAINT [PK_PersonWork] PRIMARY KEY CLUSTERED ([PersonWorkID] ASC)
);


GO
PRINT N'Creating [ORCID.].[PersonWorkIdentifier]...';


GO
CREATE TABLE [ORCID.].[PersonWorkIdentifier] (
    [PersonWorkIdentifierID] INT           IDENTITY (1, 1) NOT NULL,
    [PersonWorkID]           INT           NOT NULL,
    [WorkExternalTypeID]     TINYINT       NOT NULL,
    [Identifier]             VARCHAR (250) NOT NULL,
    CONSTRAINT [PK_PersonWorkIdentifier] PRIMARY KEY CLUSTERED ([PersonWorkIdentifierID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[EagleI.HTML]...';


GO
CREATE TABLE [Profile.Data].[EagleI.HTML] (
    [EagleIID]  INT            IDENTITY (1, 1) NOT NULL,
    [NodeID]    BIGINT         NOT NULL,
    [PersonID]  BIGINT         NOT NULL,
    [EagleIURI] VARCHAR (500)  NULL,
    [HTML]      NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([EagleIID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[EagleI.ImportXML]...';


GO
CREATE TABLE [Profile.Data].[EagleI.ImportXML] (
    [ImportID] INT IDENTITY (1, 1) NOT NULL,
    [x]        XML NULL,
    PRIMARY KEY CLUSTERED ([ImportID] ASC)
);


GO
PRINT N'Creating [RDF.SemWeb].[Hash2Base64]...';


GO
CREATE TABLE [RDF.SemWeb].[Hash2Base64] (
    [NodeID]     BIGINT     NOT NULL,
    [SemWebHash] NCHAR (28) NULL
);


GO
PRINT N'Creating [RDF.SemWeb].[Hash2Base64].[idx_SemWebHash]...';


GO
CREATE UNIQUE CLUSTERED INDEX [idx_SemWebHash]
    ON [RDF.SemWeb].[Hash2Base64]([SemWebHash] ASC);


GO
PRINT N'Creating [RDF.SemWeb].[Hash2Base64].[idx_NodeID]...';


GO
CREATE UNIQUE NONCLUSTERED INDEX [idx_NodeID]
    ON [RDF.SemWeb].[Hash2Base64]([NodeID] ASC);


GO
PRINT N'Creating [Direct.].[LogOutgoing].[NCI_FSID]...';


GO
CREATE NONCLUSTERED INDEX [NCI_FSID]
    ON [Direct.].[LogOutgoing]([FSID] ASC);


GO
PRINT N'Creating [ORCID.].[DF_RecordLevelAuditTrail_CreatedDate]...';


GO
ALTER TABLE [ORCID.].[RecordLevelAuditTrail]
    ADD CONSTRAINT [DF_RecordLevelAuditTrail_CreatedDate] DEFAULT (getdate()) FOR [CreatedDate];


GO
PRINT N'Creating on [ORCID.].[ErrorLog].[Processed]...';


GO
ALTER TABLE [ORCID.].[ErrorLog]
    ADD DEFAULT ((0)) FOR [Processed];


GO
PRINT N'Creating [ORCID.].[FK_RecordLevelAuditTrail_RecordLevelAuditType]...';


GO
ALTER TABLE [ORCID.].[RecordLevelAuditTrail] WITH NOCHECK
    ADD CONSTRAINT [FK_RecordLevelAuditTrail_RecordLevelAuditType] FOREIGN KEY ([RecordLevelAuditTypeID]) REFERENCES [ORCID.].[RecordLevelAuditType] ([RecordLevelAuditTypeID]) ON UPDATE CASCADE;


GO
PRINT N'Creating [ORCID.].[fk_Person_AlternateEmailDecisionID]...';


GO
ALTER TABLE [ORCID.].[Person] WITH NOCHECK
    ADD CONSTRAINT [fk_Person_AlternateEmailDecisionID] FOREIGN KEY ([AlternateEmailDecisionID]) REFERENCES [ORCID.].[REF_Decision] ([DecisionID]);


GO
PRINT N'Creating [ORCID.].[fk_Person_BiographyDecisionID]...';


GO
ALTER TABLE [ORCID.].[Person] WITH NOCHECK
    ADD CONSTRAINT [fk_Person_BiographyDecisionID] FOREIGN KEY ([BiographyDecisionID]) REFERENCES [ORCID.].[REF_Decision] ([DecisionID]);


GO
PRINT N'Creating [ORCID.].[fk_Person_EmailDecisionID]...';


GO
ALTER TABLE [ORCID.].[Person] WITH NOCHECK
    ADD CONSTRAINT [fk_Person_EmailDecisionID] FOREIGN KEY ([EmailDecisionID]) REFERENCES [ORCID.].[REF_Decision] ([DecisionID]);


GO
PRINT N'Creating [ORCID.].[fk_Person_personstatustypeid]...';


GO
ALTER TABLE [ORCID.].[Person] WITH NOCHECK
    ADD CONSTRAINT [fk_Person_personstatustypeid] FOREIGN KEY ([PersonStatusTypeID]) REFERENCES [ORCID.].[REF_PersonStatusType] ([PersonStatusTypeID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonMessage_Person]...';


GO
ALTER TABLE [ORCID.].[PersonMessage] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonMessage_Person] FOREIGN KEY ([PersonID]) REFERENCES [ORCID.].[Person] ([PersonID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonMessage_RecordStatusID]...';


GO
ALTER TABLE [ORCID.].[PersonMessage] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonMessage_RecordStatusID] FOREIGN KEY ([RecordStatusID]) REFERENCES [ORCID.].[REF_RecordStatus] ([RecordStatusID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonMessage_REF_Permission]...';


GO
ALTER TABLE [ORCID.].[PersonMessage] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonMessage_REF_Permission] FOREIGN KEY ([PermissionID]) REFERENCES [ORCID.].[REF_Permission] ([PermissionID]);


GO
PRINT N'Creating [ORCID.].[FK_FieldLevelAuditTrail_RecordLevelAuditTrail]...';


GO
ALTER TABLE [ORCID.].[FieldLevelAuditTrail] WITH NOCHECK
    ADD CONSTRAINT [FK_FieldLevelAuditTrail_RecordLevelAuditTrail] FOREIGN KEY ([RecordLevelAuditTrailID]) REFERENCES [ORCID.].[RecordLevelAuditTrail] ([RecordLevelAuditTrailID]) ON DELETE CASCADE ON UPDATE CASCADE;


GO
PRINT N'Creating [ORCID.].[FK_PersonAffiliation_Person]...';


GO
ALTER TABLE [ORCID.].[PersonAffiliation] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonAffiliation_Person] FOREIGN KEY ([PersonID]) REFERENCES [ORCID.].[Person] ([PersonID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonAffiliation_PersonMessage]...';


GO
ALTER TABLE [ORCID.].[PersonAffiliation] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonAffiliation_PersonMessage] FOREIGN KEY ([PersonMessageID]) REFERENCES [ORCID.].[PersonMessage] ([PersonMessageID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonAffiliation_REF_Decision]...';


GO
ALTER TABLE [ORCID.].[PersonAffiliation] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonAffiliation_REF_Decision] FOREIGN KEY ([DecisionID]) REFERENCES [ORCID.].[REF_Decision] ([DecisionID]);


GO
PRINT N'Creating [ORCID.].[fk_PersonAlternateEmail_Personid]...';


GO
ALTER TABLE [ORCID.].[PersonAlternateEmail] WITH NOCHECK
    ADD CONSTRAINT [fk_PersonAlternateEmail_Personid] FOREIGN KEY ([PersonID]) REFERENCES [ORCID.].[Person] ([PersonID]);


GO
PRINT N'Creating [ORCID.].[fk_PersonAlternateEmail_PersonMessageid]...';


GO
ALTER TABLE [ORCID.].[PersonAlternateEmail] WITH NOCHECK
    ADD CONSTRAINT [fk_PersonAlternateEmail_PersonMessageid] FOREIGN KEY ([PersonMessageID]) REFERENCES [ORCID.].[PersonMessage] ([PersonMessageID]);


GO
PRINT N'Creating [ORCID.].[fk_PersonOthername_Personid]...';


GO
ALTER TABLE [ORCID.].[PersonOthername] WITH NOCHECK
    ADD CONSTRAINT [fk_PersonOthername_Personid] FOREIGN KEY ([PersonID]) REFERENCES [ORCID.].[Person] ([PersonID]);


GO
PRINT N'Creating [ORCID.].[fk_PersonOthername_PersonMessageid]...';


GO
ALTER TABLE [ORCID.].[PersonOthername] WITH NOCHECK
    ADD CONSTRAINT [fk_PersonOthername_PersonMessageid] FOREIGN KEY ([PersonMessageID]) REFERENCES [ORCID.].[PersonMessage] ([PersonMessageID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonToken_Permissions]...';


GO
ALTER TABLE [ORCID.].[PersonToken] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonToken_Permissions] FOREIGN KEY ([PermissionID]) REFERENCES [ORCID.].[REF_Permission] ([PermissionID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonToken_Person]...';


GO
ALTER TABLE [ORCID.].[PersonToken] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonToken_Person] FOREIGN KEY ([PersonID]) REFERENCES [ORCID.].[Person] ([PersonID]);


GO
PRINT N'Creating [ORCID.].[FK_Person_PersonURL]...';


GO
ALTER TABLE [ORCID.].[PersonURL] WITH NOCHECK
    ADD CONSTRAINT [FK_Person_PersonURL] FOREIGN KEY ([PersonID]) REFERENCES [ORCID.].[Person] ([PersonID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonMessage_PersonURL]...';


GO
ALTER TABLE [ORCID.].[PersonURL] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonMessage_PersonURL] FOREIGN KEY ([PersonMessageID]) REFERENCES [ORCID.].[PersonMessage] ([PersonMessageID]);


GO
PRINT N'Creating [ORCID.].[FK_REFDecision_PersonURL]...';


GO
ALTER TABLE [ORCID.].[PersonURL] WITH NOCHECK
    ADD CONSTRAINT [FK_REFDecision_PersonURL] FOREIGN KEY ([DecisionID]) REFERENCES [ORCID.].[REF_Decision] ([DecisionID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonWork_Person]...';


GO
ALTER TABLE [ORCID.].[PersonWork] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonWork_Person] FOREIGN KEY ([PersonID]) REFERENCES [ORCID.].[Person] ([PersonID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonWork_PersonMessage]...';


GO
ALTER TABLE [ORCID.].[PersonWork] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonWork_PersonMessage] FOREIGN KEY ([PersonMessageID]) REFERENCES [ORCID.].[PersonMessage] ([PersonMessageID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonWork_REF_Decision]...';


GO
ALTER TABLE [ORCID.].[PersonWork] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonWork_REF_Decision] FOREIGN KEY ([DecisionID]) REFERENCES [ORCID.].[REF_Decision] ([DecisionID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonWorkIdentifier_PersonWork]...';


GO
ALTER TABLE [ORCID.].[PersonWorkIdentifier] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonWorkIdentifier_PersonWork] FOREIGN KEY ([PersonWorkID]) REFERENCES [ORCID.].[PersonWork] ([PersonWorkID]);


GO
PRINT N'Creating [ORCID.].[FK_PersonWorkIdentifier_WorkExternalTypeID]...';


GO
ALTER TABLE [ORCID.].[PersonWorkIdentifier] WITH NOCHECK
    ADD CONSTRAINT [FK_PersonWorkIdentifier_WorkExternalTypeID] FOREIGN KEY ([WorkExternalTypeID]) REFERENCES [ORCID.].[REF_WorkExternalType] ([WorkExternalTypeID]);


GO
PRINT N'Altering [Utility.Application].[fnEncryptRC4]...';


GO
ALTER FUNCTION [Utility.Application].[fnEncryptRC4]( @strInput VARCHAR(max), @strPassword VARCHAR(100) ) 
RETURNS VARCHAR(MAX)
AS
BEGIN
    --Returns a string encrypted with key k 
    --     ( RC4 encryption )
    --Original code: Eric Hodges http://www.planet-source-code.com/vb/scripts/ShowCode.asp?txtCodeId=29691&lngWId=1
    --Originally translated to TSQL by Joseph Gama
    DECLARE @i int, @j int, @n int, @t int, @s VARCHAR(256), @k VARCHAR(256),
     @tmp1 CHAR(1), @tmp2 CHAR(1), @result VARCHAR(max)
    SET @i=0 SET @s='' SET @k='' SET @result=''
    SET @strPassword = 'PRNS'+@strPassword
    WHILE @i<=255--127--255
    	BEGIN
    	SET @s=@s+CHAR(@i)
    	SET @k=@k+CHAR(ASCII(SUBSTRING(@strPassword, 1+@i % LEN(@strPassword),1)))
    	SET @i=@i+1
    	END
    SET @i=0 SET @j=0
    WHILE @i<=255--127--255
    	BEGIN
    	SET @j=(@j+ ASCII(SUBSTRING(@s,@i+1,1))+ASCII(SUBSTRING(@k,@i+1,1)))% 256 --256
    	SET @tmp1=SUBSTRING(@s,@i+1,1)
    	SET @tmp2=SUBSTRING(@s,@j+1,1)
    	SET @s=STUFF(@s,@i+1,1,@tmp2)
    	SET @s=STUFF(@s,@j+1,1,@tmp1)
    	SET @i=@i+1
    	END
    SET @i=0 SET @j=0
    SET @n=1
    WHILE @n<=LEN(@strInput)
    	BEGIN
    	SET @i=(@i+1) % 256--128--256
    	SET @j=(@j+ASCII(SUBSTRING(@s,@i+1,1))) % 256--128--256
    	SET @tmp1=SUBSTRING(@s,@i+1,1)
    	SET @tmp2=SUBSTRING(@s,@j+1,1)
    	SET @s=STUFF(@s,@i+1,1,@tmp2)
    	SET @s=STUFF(@s,@j+1,1,@tmp1)
    	SET @t=((ASCII(SUBSTRING(@s,@i+1,1))+ASCII(SUBSTRING(@s,@j+1,1))) % 256)--128)	--256)
    	IF ASCII(SUBSTRING(@s,@t+1,1))=ASCII(SUBSTRING(@strInput,@n,1))
    		SET @result=@result+SUBSTRING(@strInput,@n,1)
    	ELSE	
    		SET @result=@result+CHAR(ASCII(SUBSTRING(@s,@t+1,1)) ^ ASCII(SUBSTRING(@strInput,@n,1)))
    	SET @n=@n+1
    	END
    RETURN @result
END
GO
PRINT N'Altering [RDF.SemWeb].[vwHash2Base64]...';


GO
ALTER VIEW [RDF.SemWeb].[vwHash2Base64]
	AS
	SELECT NodeID, SemWebHash
		FROM [RDF.SemWeb].[Hash2Base64]

	/*

	-- This version of the view allows truncation / modification to [RDF.].Node	
	AS
	SELECT NodeID, [RDF.SemWeb].[fnHash2Base64](ValueHash) SemWebHash
		FROM [RDF.].Node

	-- This version of the view allows indexes
	WITH SCHEMABINDING
	AS
	SELECT NodeID, [RDF.SemWeb].[fnHash2Base64](ValueHash) SemWebHash
		FROM [RDF.].Node
	
	--Run after creating this view
	CREATE UNIQUE CLUSTERED INDEX [idx_SemWebHash] ON [RDF.SemWeb].[vwHash2Base64]([SemWebHash] ASC)
	CREATE UNIQUE NONCLUSTERED INDEX [idx_NodeID] ON [RDF.SemWeb].[vwHash2Base64]([NodeID] ASC)

	*/
GO
PRINT N'Refreshing [RDF.SemWeb].[vwPrivate_Literals]...';


GO
EXECUTE sp_refreshsqlmodule N'[RDF.SemWeb].[vwPrivate_Literals]';


GO
PRINT N'Refreshing [RDF.SemWeb].[vwPublic_Literals]...';


GO
EXECUTE sp_refreshsqlmodule N'[RDF.SemWeb].[vwPublic_Literals]';


GO
PRINT N'Creating [RDF.].[vwLiteral]...';


GO
CREATE VIEW [RDF.].[vwLiteral]
	WITH SCHEMABINDING
	AS
	SELECT NodeID, Value
		FROM [RDF.].[Node]
		WHERE ObjectType = 1 
			AND (DataType IS NULL OR DataType <> 'http://www.w3.org/2001/XMLSchema#float')
GO
PRINT N'Creating [RDF.].[vwLiteral].[idx_NodeID]...';


GO
CREATE UNIQUE CLUSTERED INDEX [idx_NodeID]
    ON [RDF.].[vwLiteral]([NodeID] ASC);


GO
PRINT N'Creating Full-text Index on [RDF.].[vwLiteral]...';


GO
CREATE FULLTEXT INDEX ON [RDF.].[vwLiteral]
    ([Value] LANGUAGE 1033)
    KEY INDEX [idx_NodeID]
    ON [ft];


GO
PRINT N'Altering [Profile.Data].[Publication.Pubmed.AddPublication]...';


GO
ALTER procedure [Profile.Data].[Publication.Pubmed.AddPublication] 
	@UserID INT,
	@pmid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	if exists (select * from [Profile.Data].[Publication.PubMed.AllXML] where pmid = @pmid)
	begin
 
		declare @ParseDate datetime
		set @ParseDate = (select coalesce(ParseDT,'1/1/1900') from [Profile.Data].[Publication.PubMed.AllXML] where pmid = @pmid)
		if (@ParseDate < '1/1/2000')
		begin
			exec [Profile.Data].[Publication.Pubmed.ParsePubMedXML] 
			 @pmid
		end
 BEGIN TRY 
		BEGIN TRANSACTION
 
			if not exists (select * from [Profile.Data].[Publication.Person.Include] where PersonID = @UserID and pmid = @pmid)
			begin
 
				declare @pubid uniqueidentifier
				declare @mpid varchar(50)
 
				set @mpid = null
 
				set @pubid = (select top 1 pubid from [Profile.Data].[Publication.Person.Exclude] where PersonID = @UserID and pmid = @pmid)
				if @pubid is not null
					begin
						set @mpid = (select mpid from [Profile.Data].[Publication.Person.Exclude] where pubid = @pubid)
						delete from [Profile.Data].[Publication.Person.Exclude] where pubid = @pubid
					end
				else
					begin
						set @pubid = (select newid())
					end
 
				insert into [Profile.Data].[Publication.Person.Include](pubid,PersonID,pmid,mpid)
					values (@pubid,@UserID,@pmid,@mpid)
 
				insert into [Profile.Data].[Publication.Person.Add](pubid,PersonID,pmid,mpid)
					values (@pubid,@UserID,@pmid,@mpid)
 
				EXEC  [Profile.Data].[Publication.Pubmed.AddOneAuthorPosition] @PersonID = @UserID, @pmid = @pmid
 
				-- Popluate [Publication.Entity.Authorship] and [Publication.Entity.InformationResource] tables
				EXEC [Profile.Data].[Publication.Entity.UpdateEntityOnePerson]@UserID
				
			end
 
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		
 
	END
 
END
GO
PRINT N'Altering [Framework.].[CreateInstallData]...';


GO
ALTER procedure [Framework.].[CreateInstallData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @x xml

	select @x = (
		select
			(
				select
					--------------------------------------------------------
					-- [Framework.]
					--------------------------------------------------------
					(
						select	'[Framework.].[Parameter]' 'Table/@Name',
								(
									select	ParameterID 'ParameterID', 
											Value 'Value'
									from [Framework.].[Parameter]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Framework.].[RestPath]' 'Table/@Name',
								(
									select	ApplicationName 'ApplicationName',
											Resolver 'Resolver'
									from [Framework.].[RestPath]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Framework.].[Job]' 'Table/@Name',
								(
									select	JobID 'JobID',
											JobGroup 'JobGroup',
											Step 'Step',
											IsActive 'IsActive',
											Script 'Script'
									from [Framework.].[Job]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Framework.].[JobGroup]' 'Table/@Name',
								(
									SELECT  JobGroup 'JobGroup',
											Name 'Name',
											Type 'Type',
											Description 'Description'	
									from [Framework.].JobGroup
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					--------------------------------------------------------
					-- [Ontology.]
					--------------------------------------------------------
					(
						select	'[Ontology.].[ClassGroup]' 'Table/@Name',
								(
									select	ClassGroupURI 'ClassGroupURI',
											SortOrder 'SortOrder',
											IsVisible 'IsVisible'
									from [Ontology.].[ClassGroup]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Ontology.].[ClassGroupClass]' 'Table/@Name',
								(
									select	ClassGroupURI 'ClassGroupURI',
											ClassURI 'ClassURI',
											SortOrder 'SortOrder'
									from [Ontology.].[ClassGroupClass]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Ontology.].[ClassProperty]' 'Table/@Name',
								(
									select	ClassPropertyID 'ClassPropertyID',
											Class 'Class',
											NetworkProperty 'NetworkProperty',
											Property 'Property',
											IsDetail 'IsDetail',
											Limit 'Limit',
											IncludeDescription 'IncludeDescription',
											IncludeNetwork 'IncludeNetwork',
											SearchWeight 'SearchWeight',
											CustomDisplay 'CustomDisplay',
											CustomEdit 'CustomEdit',
											ViewSecurityGroup 'ViewSecurityGroup',
											EditSecurityGroup 'EditSecurityGroup',
											EditPermissionsSecurityGroup 'EditPermissionsSecurityGroup',
											EditExistingSecurityGroup 'EditExistingSecurityGroup',
											EditAddNewSecurityGroup 'EditAddNewSecurityGroup',
											EditAddExistingSecurityGroup 'EditAddExistingSecurityGroup',
											EditDeleteSecurityGroup 'EditDeleteSecurityGroup',
											MinCardinality 'MinCardinality',
											MaxCardinality 'MaxCardinality',
											CustomDisplayModule 'CustomDisplayModule',
											CustomEditModule 'CustomEditModule'
									from [Ontology.].ClassProperty
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Ontology.].[DataMap]' 'Table/@Name',
						
								(
									select  DataMapID 'DataMapID',
											DataMapGroup 'DataMapGroup',
											IsAutoFeed 'IsAutoFeed',
											Graph 'Graph',
											Class 'Class',
											NetworkProperty 'NetworkProperty',
											Property 'Property',
											MapTable 'MapTable',
											sInternalType 'sInternalType',
											sInternalID 'sInternalID',
											cClass 'cClass',
											cInternalType 'cInternalType',
											cInternalID 'cInternalID',
											oClass 'oClass',
											oInternalType 'oInternalType',
											oInternalID 'oInternalID',
											oValue 'oValue',
											oDataType 'oDataType',
											oLanguage 'oLanguage',
											oStartDate 'oStartDate',
											oStartDatePrecision 'oStartDatePrecision',
											oEndDate 'oEndDate',
											oEndDatePrecision 'oEndDatePrecision',
											oObjectType 'oObjectType',
											Weight 'Weight',
											OrderBy 'OrderBy',
											ViewSecurityGroup 'ViewSecurityGroup',
											EditSecurityGroup 'EditSecurityGroup',
											_ClassNode '_ClassNode',
											_NetworkPropertyNode '_NetworkPropertyNode',
											_PropertyNode '_PropertyNode'
									from [Ontology.].[DataMap]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Ontology.].[Namespace]' 'Table/@Name',
								(
									select	URI 'URI',
											Prefix 'Prefix'
									from [Ontology.].[Namespace]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Ontology.].[PropertyGroup]' 'Table/@Name',
								(
									select	PropertyGroupURI 'PropertyGroupURI',
											SortOrder 'SortOrder',
											_PropertyGroupLabel '_PropertyGroupLabel',
											_PropertyGroupNode '_PropertyGroupNode',
											_NumberOfNodes '_NumberOfNodes'
									from [Ontology.].[PropertyGroup]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Ontology.].[PropertyGroupProperty]' 'Table/@Name',
								(
									select	PropertyGroupURI 'PropertyGroupURI',
											PropertyURI 'PropertyURI',
											SortOrder 'SortOrder',
											CustomDisplayModule 'CustomDisplayModule',
											CustomEditModule 'CustomEditModule',
											_PropertyGroupNode '_PropertyGroupNode',
											_PropertyNode '_PropertyNode',
											_TagName '_TagName',
											_PropertyLabel '_PropertyLabel',
											_NumberOfNodes '_NumberOfNodes'
									from [Ontology.].[PropertyGroupProperty]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					--------------------------------------------------------
					-- [Ontology.Presentation]
					--------------------------------------------------------
					(
						select	'[Ontology.Presentation].[XML]' 'Table/@Name',
								(
									select	PresentationID 'PresentationID', 
											type 'type',
											subject 'subject',
											predicate 'predicate',
											object 'object',
											presentationXML 'presentationXML'
									from [Ontology.Presentation].[XML]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					--------------------------------------------------------
					-- [RDF.Security]
					--------------------------------------------------------
					(
						select	'[RDF.Security].[Group]' 'Table/@Name',
								(
									select	SecurityGroupID 'SecurityGroupID',
											Label 'Label',
											HasSpecialViewAccess 'HasSpecialViewAccess',
											HasSpecialEditAccess 'HasSpecialEditAccess',
											Description 'Description'
									from [RDF.Security].[Group]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					--------------------------------------------------------
					-- [Utility.NLP]
					--------------------------------------------------------
					(
						select	'[Utility.NLP].[ParsePorterStemming]' 'Table/@Name',
								(
									select	step 'Step',
											Ordering 'Ordering',
											phrase1 'phrase1',
											phrase2 'phrase2'
									from [Utility.NLP].ParsePorterStemming
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Utility.NLP].[StopWord]' 'Table/@Name',
								(
									select	word 'word',
											stem 'stem',
											scope 'scope'
									from [Utility.NLP].[StopWord]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					(
						select	'[Utility.NLP].[Thesaurus.Source]' 'Table/@Name',
								(
									select	Source 'Source',
											SourceName 'SourceName'
									from [Utility.NLP].[Thesaurus.Source]
									for xml path('Row'), type
								) 'Table'
						for xml path(''), type
					),
					--------------------------------------------------------
					-- [User.Session]
					--------------------------------------------------------
					(
						select	'[User.Session].Bot' 'Table/@Name',
							(
								SELECT UserAgent 'UserAgent' 
								  FROM [User.Session].Bot
				  					for xml path('Row'), type
			   				) 'Table'  
						for xml path(''), type
					),
					--------------------------------------------------------
					-- [Direct.]
					--------------------------------------------------------
					(
						select	'[Direct.].[Sites]' 'Table/@Name',
							(
								SELECT SiteID 'SiteID',
										BootstrapURL 'BootstrapURL',
										SiteName 'SiteName',
										QueryURL 'QueryURL',
										SortOrder 'SortOrder',
										IsActive 'IsActive'  
								  FROM [Direct.].[Sites] 
			 					for xml path('Row'), type
					 		) 'Table'   
						for xml path(''), TYPE
					),
					--------------------------------------------------------
					-- [Profile.Data]
					--------------------------------------------------------
					(
						select	'[Profile.Data].[Publication.Type]' 'Table/@Name',
							(
								SELECT	pubidtype_id 'pubidtype_id',
										name 'name',
										sort_order 'sort_order'
								  FROM [Profile.Data].[Publication.Type]
				  					for xml path('Row'), type
			   				) 'Table'  
						for xml path(''), type
					),
					(
						select	'[Profile.Data].[Publication.MyPub.Category]' 'Table/@Name',
							(
								SELECT	HmsPubCategory 'HmsPubCategory',
										CategoryName 'CategoryName'
								  FROM [Profile.Data].[Publication.MyPub.Category]
				  					for xml path('Row'), type
							) 'Table'  
						for xml path(''), type
					),
					--------------------------------------------------------
					-- [ORCID.]
					--------------------------------------------------------
					(
						select '[ORCID.].[REF_Permission]' 'Table/@Name',
						(
							SELECT	PermissionScope 'PermissionScope', 
									PermissionDescription 'PermissionDescription', 
									MethodAndRequest 'MethodAndRequest',
									SuccessMessage 'SuccessMessage',
									FailedMessage 'FailedMessage'
								from [ORCID.].[REF_Permission]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					),
					(
						select '[ORCID.].[REF_PersonStatusType]' 'Table/@Name',
						(
							SELECT	StatusDescription 'StatusDescription'
								from [ORCID.].[REF_PersonStatusType]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					),
					(
						select '[ORCID.].[REF_WorkExternalType]' 'Table/@Name',
						(
							SELECT	WorkExternalType 'WorkExternalType',
									WorkExternalDescription 'WorkExternalDescription'
								from [ORCID.].[REF_WorkExternalType]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					),
					(
						select '[ORCID.].[REF_RecordStatus]' 'Table/@Name',
						(
							SELECT	RecordStatusID 'RecordStatusID',
									StatusDescription, 'StatusDescription'
								from [ORCID.].[REF_RecordStatus]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					),
					(
						select '[ORCID.].[REF_Decision]' 'Table/@Name',
						(
							SELECT	DecisionDescription 'DecisionDescription',
									DecisionDescriptionLong 'DecisionDescriptionLong'
								from [ORCID.].[REF_Decision]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					),
					(
						select '[ORCID.].[RecordLevelAuditType]' 'Table/@Name',
						(
							SELECT	AuditType 'AuditType'
								from [ORCID.].[RecordLevelAuditType]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					),
					(
						select '[ORCID.].[DefaultORCIDDecisionIDMapping]' 'Table/@Name',
						(
							SELECT	SecurityGroupID 'SecurityGroupID',
									DefaultORCIDDecisionID 'DefaultORCIDDecisionID'
								from [ORCID.].[DefaultORCIDDecisionIDMapping]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					)	

				for xml path(''), type
			) 'Import'
		for xml path(''), type
	)

	insert into [Framework.].[InstallData] (Data)
		select @x


   --Use to generate select lists for new tables
   --SELECT    c.name +  ' ''' + name + ''','
   --FROM sys.columns c  
   --WHERE object_id IN (SELECT object_id FROM sys.tables WHERE name = 'Publication.MyPub.Category')  

END
SET ANSI_NULLS ON
GO
PRINT N'Altering [Framework.].[LICENCE]...';


GO
ALTER PROCEDURE [Framework.].[LICENCE]
AS
BEGIN
PRINT 
'
Copyright (c) 2008-2014 by the President and Fellows of Harvard College. All rights reserved.  Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD., and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the National Center for Research Resources and Harvard University.
 
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
	* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
	* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
	* Neither the name "Harvard" nor the names of its contributors nor the name "Harvard Catalyst" may be used to endorse or promote products derived from this software without specific prior written permission.
 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER (PRESIDENT AND FELLOWS OF HARVARD COLLEGE) AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
'
END
GO
PRINT N'Altering [Framework.].[LoadInstallData]...';


GO
ALTER procedure [Framework.].[LoadInstallData]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 DECLARE @x XML
 SELECT @x = ( SELECT TOP 1
                        Data
               FROM     [Framework.].[InstallData]
               ORDER BY InstallDataID DESC
             ) 

---------------------------------------------------------------
-- [Utility.Math]
---------------------------------------------------------------


-- [Utility.Math].N
; WITH   E00 ( N )
          AS ( SELECT   1
               UNION ALL
               SELECT   1
             ),
        E02 ( N )
          AS ( SELECT   1
               FROM     E00 a ,
                        E00 b
             ),
        E04 ( N )
          AS ( SELECT   1
               FROM     E02 a ,
                        E02 b
             ),
        E08 ( N )
          AS ( SELECT   1
               FROM     E04 a ,
                        E04 b
             ),
        E16 ( N )
          AS ( SELECT   1
               FROM     E08 a ,
                        E08 b
             ),
        E32 ( N )
          AS ( SELECT   1
               FROM     E16 a ,
                        E16 b
             ),
        cteTally ( N )
          AS ( SELECT   ROW_NUMBER() OVER ( ORDER BY N )
               FROM     E32
             )
    
    INSERT INTO [Utility.Math].N
    SELECT  N -1
    FROM    cteTally
    WHERE   N <= 100000 ; 
			 
---------------------------------------------------------------
-- [Framework.]
---------------------------------------------------------------
 
             
-- [Framework.].[Parameter]
TRUNCATE TABLE [Framework.].[Parameter]
INSERT INTO [Framework.].Parameter
	( ParameterID, Value )        
SELECT	R.x.value('ParameterID[1]', 'varchar(max)') ,
		R.x.value('Value[1]', 'varchar(max)')
FROM    ( SELECT
			@x.query
			('Import[1]/Table[@Name=''[Framework.].[Parameter]'']')
			x
		) t
CROSS APPLY x.nodes('//Row') AS R ( x )

  
       
-- [Framework.].[RestPath] 
INSERT INTO [Framework.].RestPath
        ( ApplicationName, Resolver )   
SELECT  R.x.value('ApplicationName[1]', 'varchar(max)') ,
        R.x.value('Resolver[1]', 'varchar(max)') 
FROM    ( SELECT
                    @x.query
                    ('Import[1]/Table[@Name=''[Framework.].[RestPath]'']')
                    x
        ) t
CROSS APPLY x.nodes('//Row') AS R ( x )

   
--[Framework.].[Job]
INSERT INTO [Framework.].Job
        ( JobID,
		  JobGroup,
          Step,
          IsActive,
          Script
        ) 
SELECT	R.x.value('JobID[1]','varchar(max)'),
		R.x.value('JobGroup[1]','varchar(max)'),
		R.x.value('Step[1]','varchar(max)'),
		R.x.value('IsActive[1]','varchar(max)'),
		R.x.value('Script[1]','varchar(max)')
FROM    ( SELECT
                  @x.query
                  ('Import[1]/Table[@Name=''[Framework.].[Job]'']')
                  x
      ) t
CROSS APPLY x.nodes('//Row') AS R ( x )

	
--[Framework.].[JobGroup]
INSERT INTO [Framework.].JobGroup
        ( JobGroup, Name, Type, Description ) 
SELECT	R.x.value('JobGroup[1]','varchar(max)'),
		R.x.value('Name[1]','varchar(max)'),
		R.x.value('Type[1]','varchar(max)'),
		R.x.value('Description[1]','varchar(max)')
FROM    ( SELECT
                  @x.query
                  ('Import[1]/Table[@Name=''[Framework.].[JobGroup]'']')
                  x
      ) t
CROSS APPLY x.nodes('//Row') AS R ( x )
       
  

---------------------------------------------------------------
-- [Ontology.]
---------------------------------------------------------------
 
 --[Ontology.].[ClassGroup]
 TRUNCATE TABLE [Ontology.].[ClassGroup]
 INSERT INTO [Ontology.].ClassGroup
         ( ClassGroupURI,
           SortOrder,
           IsVisible
         )
  SELECT  R.x.value('ClassGroupURI[1]', 'varchar(max)') ,
          R.x.value('SortOrder[1]', 'varchar(max)'),
          R.x.value('IsVisible[1]', 'varchar(max)')
  FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.].[ClassGroup]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x ) 
  
 --[Ontology.].[ClassGroupClass]
 TRUNCATE TABLE [Ontology.].[ClassGroupClass]
 INSERT INTO [Ontology.].ClassGroupClass
         ( ClassGroupURI,
           ClassURI,
           SortOrder
         )
  SELECT  R.x.value('ClassGroupURI[1]', 'varchar(max)') ,
          R.x.value('ClassURI[1]', 'varchar(max)'),
          R.x.value('SortOrder[1]', 'varchar(max)')
  FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.].[ClassGroupClass]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )

  
--[Ontology.].[ClassProperty]
INSERT INTO [Ontology.].ClassProperty
        ( ClassPropertyID,
          Class,
          NetworkProperty,
          Property,
          IsDetail,
          Limit,
          IncludeDescription,
          IncludeNetwork,
          SearchWeight,
          CustomDisplay,
          CustomEdit,
          ViewSecurityGroup,
          EditSecurityGroup,
          EditPermissionsSecurityGroup,
          EditExistingSecurityGroup,
          EditAddNewSecurityGroup,
          EditAddExistingSecurityGroup,
          EditDeleteSecurityGroup,
          MinCardinality,
          MaxCardinality,
          CustomDisplayModule,
          CustomEditModule
        )
SELECT  R.x.value('ClassPropertyID[1]','varchar(max)'),
		R.x.value('Class[1]','varchar(max)'),
		R.x.value('NetworkProperty[1]','varchar(max)'),
		R.x.value('Property[1]','varchar(max)'),
		R.x.value('IsDetail[1]','varchar(max)'),
		R.x.value('Limit[1]','varchar(max)'),
		R.x.value('IncludeDescription[1]','varchar(max)'),
		R.x.value('IncludeNetwork[1]','varchar(max)'),
		R.x.value('SearchWeight[1]','varchar(max)'),
		R.x.value('CustomDisplay[1]','varchar(max)'),
		R.x.value('CustomEdit[1]','varchar(max)'),
		R.x.value('ViewSecurityGroup[1]','varchar(max)'),
		R.x.value('EditSecurityGroup[1]','varchar(max)'),
		R.x.value('EditPermissionsSecurityGroup[1]','varchar(max)'),
		R.x.value('EditExistingSecurityGroup[1]','varchar(max)'),
		R.x.value('EditAddNewSecurityGroup[1]','varchar(max)'),
		R.x.value('EditAddExistingSecurityGroup[1]','varchar(max)'),
		R.x.value('EditDeleteSecurityGroup[1]','varchar(max)'),
		R.x.value('MinCardinality[1]','varchar(max)'),
		R.x.value('MaxCardinality[1]','varchar(max)'),
		(case when CAST(R.x.query('CustomDisplayModule[1]/*') AS NVARCHAR(MAX))<>'' then R.x.query('CustomDisplayModule[1]/*') else NULL end),
		(case when CAST(R.x.query('CustomEditModule[1]/*') AS NVARCHAR(MAX))<>'' then R.x.query('CustomEditModule[1]/*') else NULL end)
  FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.].[ClassProperty]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )

  
  --[Ontology.].[DataMap]
  TRUNCATE TABLE [Ontology.].DataMap
  INSERT INTO [Ontology.].DataMap
          ( DataMapID,
			DataMapGroup ,
            IsAutoFeed ,
            Graph ,
            Class ,
            NetworkProperty ,
            Property ,
            MapTable ,
            sInternalType ,
            sInternalID ,
            cClass ,
            cInternalType ,
            cInternalID ,
            oClass ,
            oInternalType ,
            oInternalID ,
            oValue ,
            oDataType ,
            oLanguage ,
            oStartDate ,
            oStartDatePrecision ,
            oEndDate ,
            oEndDatePrecision ,
            oObjectType ,
            Weight ,
            OrderBy ,
            ViewSecurityGroup ,
            EditSecurityGroup ,
            [_ClassNode] ,
            [_NetworkPropertyNode] ,
            [_PropertyNode]
          )
  SELECT    R.x.value('DataMapID[1]','varchar(max)'),
			R.x.value('DataMapGroup[1]','varchar(max)'),
			R.x.value('IsAutoFeed[1]','varchar(max)'),
			R.x.value('Graph[1]','varchar(max)'),
			R.x.value('Class[1]','varchar(max)'),
			R.x.value('NetworkProperty[1]','varchar(max)'),
			R.x.value('Property[1]','varchar(max)'),
			R.x.value('MapTable[1]','varchar(max)'),
			R.x.value('sInternalType[1]','varchar(max)'),
			R.x.value('sInternalID[1]','varchar(max)'),
			R.x.value('cClass[1]','varchar(max)'),
			R.x.value('cInternalType[1]','varchar(max)'),
			R.x.value('cInternalID[1]','varchar(max)'),
			R.x.value('oClass[1]','varchar(max)'),
			R.x.value('oInternalType[1]','varchar(max)'),
			R.x.value('oInternalID[1]','varchar(max)'),
			R.x.value('oValue[1]','varchar(max)'),
			R.x.value('oDataType[1]','varchar(max)'),
			R.x.value('oLanguage[1]','varchar(max)'),
			R.x.value('oStartDate[1]','varchar(max)'),
			R.x.value('oStartDatePrecision[1]','varchar(max)'),
			R.x.value('oEndDate[1]','varchar(max)'),
			R.x.value('oEndDatePrecision[1]','varchar(max)'),
			R.x.value('oObjectType[1]','varchar(max)'),
			R.x.value('Weight[1]','varchar(max)'),
			R.x.value('OrderBy[1]','varchar(max)'),
			R.x.value('ViewSecurityGroup[1]','varchar(max)'),
			R.x.value('EditSecurityGroup[1]','varchar(max)'),
			R.x.value('_ClassNode[1]','varchar(max)'),
			R.x.value('_NetworkPropertyNode[1]','varchar(max)'),
			R.x.value('_PropertyNode[1]','varchar(max)')
  FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.].[DataMap]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
  
  
 -- [Ontology.].[Namespace]
 TRUNCATE TABLE [Ontology.].[Namespace]
 INSERT INTO [Ontology.].[Namespace]
        ( URI ,
          Prefix
        )
  SELECT  R.x.value('URI[1]', 'varchar(max)') ,
          R.x.value('Prefix[1]', 'varchar(max)')
  FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.].[Namespace]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
  

   --[Ontology.].[PropertyGroup]
   INSERT INTO [Ontology.].PropertyGroup
           ( PropertyGroupURI ,
             SortOrder ,
             [_PropertyGroupLabel] ,
             [_PropertyGroupNode] ,
             [_NumberOfNodes]
           ) 
	SELECT	R.x.value('PropertyGroupURI[1]','varchar(max)'),
			R.x.value('SortOrder[1]','varchar(max)'),
			R.x.value('_PropertyGroupLabel[1]','varchar(max)'), 
			R.x.value('_PropertyGroupNode[1]','varchar(max)'),
			R.x.value('_NumberOfNodes[1]','varchar(max)')
	 FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.].[PropertyGroup]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
  
  
	--[Ontology.].[PropertyGroupProperty]
	INSERT INTO [Ontology.].PropertyGroupProperty
	        ( PropertyGroupURI ,
	          PropertyURI ,
	          SortOrder ,
	          CustomDisplayModule ,
	          CustomEditModule ,
	          [_PropertyGroupNode] ,
	          [_PropertyNode] ,
	          [_TagName] ,
	          [_PropertyLabel] ,
	          [_NumberOfNodes]
	        ) 
	SELECT	R.x.value('PropertyGroupURI[1]','varchar(max)'),
			R.x.value('PropertyURI[1]','varchar(max)'),
			R.x.value('SortOrder[1]','varchar(max)'),
			(case when CAST(R.x.query('CustomDisplayModule[1]/*') AS NVARCHAR(MAX))<>'' then R.x.query('CustomDisplayModule[1]/*') else NULL end),
			(case when CAST(R.x.query('CustomEditModule[1]/*') AS NVARCHAR(MAX))<>'' then R.x.query('CustomEditModule[1]/*') else NULL end),
			R.x.value('_PropertyGroupNode[1]','varchar(max)'),
			R.x.value('_PropertyNode[1]','varchar(max)'),
			R.x.value('_TagName[1]','varchar(max)'),
			R.x.value('_PropertyLabel[1]','varchar(max)'),
			R.x.value('_NumberOfNodes[1]','varchar(max)')
	 FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.].[PropertyGroupProperty]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
  

---------------------------------------------------------------
-- [Ontology.Presentation]
---------------------------------------------------------------


 --[Ontology.Presentation].[XML]
 INSERT INTO [Ontology.Presentation].[XML]
         ( PresentationID,
			type ,
           subject ,
           predicate ,
           object ,
           presentationXML ,
           _SubjectNode ,
           _PredicateNode ,
           _ObjectNode
         )       
  SELECT  R.x.value('PresentationID[1]', 'varchar(max)') ,
		  R.x.value('type[1]', 'varchar(max)') ,
          R.x.value('subject[1]', 'varchar(max)'),
          R.x.value('predicate[1]', 'varchar(max)'),
          R.x.value('object[1]', 'varchar(max)'),
          (case when CAST(R.x.query('presentationXML[1]/*') AS NVARCHAR(MAX))<>'' then R.x.query('presentationXML[1]/*') else NULL end) , 
          R.x.value('_SubjectNode[1]', 'varchar(max)'),
          R.x.value('_PredicateNode[1]', 'varchar(max)'),
          R.x.value('_ObjectNode[1]', 'varchar(max)')
  FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Ontology.Presentation].[XML]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )

  
---------------------------------------------------------------
-- [RDF.Security]
---------------------------------------------------------------
             
 -- [RDF.Security].[Group]
 TRUNCATE TABLE [RDF.Security].[Group]
 INSERT INTO [RDF.Security].[Group]
 
         ( SecurityGroupID ,
           Label ,
           HasSpecialViewAccess ,
           HasSpecialEditAccess ,
           Description
         )
 SELECT   R.x.value('SecurityGroupID[1]', 'varchar(max)') ,
          R.x.value('Label[1]', 'varchar(max)'),
          R.x.value('HasSpecialViewAccess[1]', 'varchar(max)'),
          R.x.value('HasSpecialEditAccess[1]', 'varchar(max)'),
          R.x.value('Description[1]', 'varchar(max)')
  FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[RDF.Security].[Group]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x ) 



---------------------------------------------------------------
-- [Utility.NLP]
---------------------------------------------------------------
   
	--[Utility.NLP].[ParsePorterStemming]
	INSERT INTO [Utility.NLP].ParsePorterStemming
	        ( Step, Ordering, phrase1, phrase2 ) 
	SELECT	R.x.value('Step[1]','varchar(max)'),
			R.x.value('Ordering[1]','varchar(max)'), 
			R.x.value('phrase1[1]','varchar(max)'), 
			R.x.value('phrase2[1]','varchar(max)')
	 FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Utility.NLP].[ParsePorterStemming]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
	
	--[Utility.NLP].[StopWord]
	INSERT INTO [Utility.NLP].StopWord
	        ( word, stem, scope ) 
	SELECT	R.x.value('word[1]','varchar(max)'),
			R.x.value('stem[1]','varchar(max)'),
			R.x.value('scope[1]','varchar(max)')
	 FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Utility.NLP].[StopWord]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
  
	--[Utility.NLP].[Thesaurus.Source]
	INSERT INTO [Utility.NLP].[Thesaurus.Source]
	        ( Source, SourceName ) 
	SELECT	R.x.value('Source[1]','varchar(max)'),
			R.x.value('SourceName[1]','varchar(max)')
	 FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Utility.NLP].[Thesaurus.Source]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )


---------------------------------------------------------------
-- [User.Session]
---------------------------------------------------------------

  --[User.Session].Bot		
  INSERT INTO [User.Session].Bot  ( UserAgent )
   SELECT	R.x.value('UserAgent[1]','varchar(max)') 
	 FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[User.Session].Bot'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
  
  
  
---------------------------------------------------------------
-- [Direct.]
---------------------------------------------------------------
   
  --[Direct.].[Sites]
  INSERT INTO [Direct.].[Sites]
          ( SiteID ,
            BootstrapURL ,
            SiteName ,
            QueryURL ,
            SortOrder ,
            IsActive
          )
  SELECT	R.x.value('SiteID[1]','varchar(max)'),
			R.x.value('BootstrapURL[1]','varchar(max)'),
			R.x.value('SiteName[1]','varchar(max)'),
			R.x.value('QueryURL[1]','varchar(max)'),
			R.x.value('SortOrder[1]','varchar(max)'),
			R.x.value('IsActive[1]','varchar(max)')
	 FROM    ( SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Direct.].[Sites]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
	
	
---------------------------------------------------------------
-- [Profile.Data]
---------------------------------------------------------------
 
    --[Profile.Data].[Publication.Type]		
  INSERT INTO [Profile.Data].[Publication.Type]
          ( pubidtype_id, name, sort_order )
           
   SELECT	R.x.value('pubidtype_id[1]','varchar(max)'),
			R.x.value('name[1]','varchar(max)'),
			R.x.value('sort_order[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Profile.Data].[Publication.Type]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
   
  --[Profile.Data].[Publication.MyPub.Category]
  TRUNCATE TABLE [Profile.Data].[Publication.MyPub.Category]
  INSERT INTO [Profile.Data].[Publication.MyPub.Category]
          ( [HmsPubCategory] ,
            [CategoryName]
          ) 
   SELECT	R.x.value('HmsPubCategory[1]','varchar(max)'),
			R.x.value('CategoryName[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[Profile.Data].[Publication.MyPub.Category]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )
  
 ---------------------------------------------------------------
-- [ORCID.]
---------------------------------------------------------------
  
	INSERT INTO [ORCID.].[REF_Permission]
		(
			[PermissionScope],
			[PermissionDescription],
			[MethodAndRequest],
			[SuccessMessage],
			[FailedMessage]
		)
   SELECT	R.x.value('PermissionScope[1]','varchar(max)'),
			R.x.value('PermissionDescription[1]','varchar(max)'),
			R.x.value('MethodAndRequest[1]','varchar(max)'),
			R.x.value('SuccessMessage[1]','varchar(max)'),
			R.x.value('FailedMessage[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORCID.].[REF_Permission]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )


	INSERT INTO [ORCID.].[REF_PersonStatusType]
		(
			[StatusDescription]
		)
   SELECT	R.x.value('StatusDescription[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORCID.].[REF_PersonStatusType]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )


	INSERT INTO [ORCID.].[REF_RecordStatus]
		(
			[RecordStatusID],
			[StatusDescription]
		)
   SELECT	R.x.value('RecordStatusID[1]','varchar(max)'),
			R.x.value('StatusDescription[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORCID.].[REF_RecordStatus]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )


	INSERT INTO [ORCID.].[REF_Decision]
		(
			[DecisionDescription],
			[DecisionDescriptionLong]
		)
   SELECT	R.x.value('DecisionDescription[1]','varchar(max)'),
			R.x.value('DecisionDescriptionLong[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORCID.].[REF_Decision]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )

	INSERT INTO [ORCID.].[REF_WorkExternalType]
		(
			[WorkExternalType],
			[WorkExternalDescription]
		)
   SELECT	R.x.value('WorkExternalType[1]','varchar(max)'),
			R.x.value('WorkExternalDescription[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORCID.].[REF_WorkExternalType]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )


	INSERT INTO [ORCID.].[RecordLevelAuditType]
		(
			[AuditType]
		)
   SELECT	R.x.value('AuditType[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORCID.].[RecordLevelAuditType]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )



	INSERT INTO [ORCID.].[DefaultORCIDDecisionIDMapping]
		(
			[SecurityGroupID],
			[DefaultORCIDDecisionID]
		)
   SELECT	R.x.value('SecurityGroupID[1]','varchar(max)'),
			R.x.value('DefaultORCIDDecisionID[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORCID.].[DefaultORCIDDecisionIDMapping]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )

  -- Use to generate select lists for new tables
  -- SELECT   'R.x.value(''' + c.name +  '[1]'',' + '''varchar(max)'')'+ ',' ,* 
  -- FROM sys.columns c 
  -- JOIN  sys.types t ON t.system_type_id = c.system_type_id 
  -- WHERE object_id IN (SELECT object_id FROM sys.tables WHERE name = 'Publication.MyPub.Category') 
  -- AND T.NAME<>'sysname'ORDER BY c.column_id
	 
END
SET ANSI_NULLS ON
GO
PRINT N'Altering [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]...';


GO
ALTER procedure [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]
AS
BEGIN
BEGIN TRY  
BEGIN TRAN
 
-- Remove orphaned pubs
DELETE FROM [Profile.Data].[Publication.Person.Include]
	  WHERE NOT EXISTS (SELECT *
						  FROM [Profile.Data].[Publication.PubMed.Disambiguation] p
						 WHERE p.personid = [Profile.Data].[Publication.Person.Include].personid
						   AND p.pmid = [Profile.Data].[Publication.Person.Include].pmid)
		AND mpid IS NULL

-- Add Added Pubs
insert into [Profile.Data].[Publication.Person.Include](pubid,PersonID,pmid,mpid)
select a.PubID, a.PersonID, a.PMID, a.MPID from [Profile.Data].[Publication.Person.Add] a
	left join [Profile.Data].[Publication.Person.Include] i
	on a.PersonID = i.PersonID
	and isnull(a.PMID, -1) = isnull(i.PMID, -1)
	and isnull(a.mpid, '') = isnull(i.mpid, '')
	where i.personid is null
	and (a.pmid is null or a.PMID in (select pmid from [Profile.Data].[Publication.PubMed.General]))
	and (a.mpid is null or a.MPID in (select mpid from [Profile.Data].[Publication.MyPub.General]))
		
--Move in new pubs
INSERT INTO [Profile.Data].[Publication.Person.Include]
SELECT	 NEWID(),
		 personid,
		 pmid,
		 NULL
  FROM [Profile.Data].[Publication.PubMed.Disambiguation] d
 WHERE NOT EXISTS (SELECT *
					 FROM  [Profile.Data].[Publication.Person.Include] p
					WHERE p.personid = d.personid
					  AND p.pmid = d.pmid)
  AND EXISTS (SELECT 1 FROM [Profile.Data].[Publication.PubMed.General] g where g.pmid = d.pmid)					  
 
COMMIT
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		
 
-- Popluate [Publication.Entity.Authorship] and [Publication.Entity.InformationResource] tables
	EXEC [Profile.Data].[Publication.Entity.UpdateEntity]
END
GO
PRINT N'Altering [RDF.].[GetDataRDF]...';


GO
ALTER PROCEDURE [RDF.].[GetDataRDF]
	@subject BIGINT=NULL,
	@predicate BIGINT=NULL,
	@object BIGINT=NULL,
	@offset BIGINT=NULL,
	@limit BIGINT=NULL,
	@showDetails BIT=1,
	@expand BIT=1,
	@SessionID UNIQUEIDENTIFIER=NULL,
	@NodeListXML XML=NULL,
	@ExpandRDFListXML XML=NULL,
	@returnXML BIT=1,
	@returnXMLasStr BIT=0,
	@dataStr NVARCHAR (MAX)=NULL OUTPUT,
	@dataStrDataType NVARCHAR (255)=NULL OUTPUT,
	@dataStrLanguage NVARCHAR (255)=NULL OUTPUT,
	@RDF XML=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*

	This stored procedure returns the data for a node in RDF format.

	Input parameters:
		@subject		The NodeID whose RDF should be returned.
		@predicate		The predicate NodeID for a network.
		@object			The object NodeID for a connection.
		@offset			Pagination - The first object node to return.
		@limit			Pagination - The number of object nodes to return.
		@showDetails	If 1, then additional properties will be returned.
		@expand			If 1, then object properties will be expanded.
		@SessionID		The SessionID of the user requesting the data.

	There are two ways to call this procedure. By default, @returnXML = 1,
	and the RDF is returned as XML. When @returnXML = 0, the data is instead
	returned as the strings @dataStr, @dataStrDataType, and @dataStrLanguage.
	This second method of calling this procedure is used by other procedures
	and is generally not called directly by the website.

	The RDF returned by this procedure is not equivalent to what is
	returned by SPARQL. This procedure applies security rules, expands
	nodes as defined by [Ontology.].[RDFExpand], and calculates network
	information on-the-fly.

	*/

	declare @d datetime

	declare @baseURI nvarchar(400)
	select @baseURI = value from [Framework.].Parameter where ParameterID = 'baseURI'

	select @subject = null where @subject = 0
	select @predicate = null where @predicate = 0
	select @object = null where @object = 0
		
	declare @firstURI nvarchar(400)
	select @firstURI = @baseURI+cast(@subject as varchar(50))

	declare @firstValue nvarchar(400)
	select @firstValue = null
	
	declare @typeID bigint
	select @typeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')

	declare @labelID bigint
	select @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')	

	declare @validURI bit
	select @validURI = 1

	--*******************************************************************************************
	--*******************************************************************************************
	-- Define temp tables
	--*******************************************************************************************
	--*******************************************************************************************

	/*
		drop table #subjects
		drop table #types
		drop table #expand
		drop table #properties
		drop table #connections
	*/

	create table #subjects (
		subject bigint primary key,
		showDetail bit,
		expanded bit,
		uri nvarchar(400)
	)
	
	create table #types (
		subject bigint not null,
		object bigint not null,
		predicate bigint,
		showDetail bit,
		uri nvarchar(400)
	)
	create unique clustered index idx_sop on #types (subject,object,predicate)

	create table #expand (
		subject bigint not null,
		predicate bigint not null,
		uri nvarchar(400),
		property nvarchar(400),
		tagName nvarchar(1000),
		propertyLabel nvarchar(400),
		IsDetail bit,
		limit bigint,
		showStats bit,
		showSummary bit
	)
	alter table #expand add primary key (subject,predicate)

	create table #properties (
		uri nvarchar(400),
		subject bigint,
		predicate bigint,
		object bigint,
		showSummary bit,
		property nvarchar(400),
		tagName nvarchar(1000),
		propertyLabel nvarchar(400),
		Language nvarchar(255),
		DataType nvarchar(255),
		Value nvarchar(max),
		ObjectType bit,
		SortOrder int
	)

	create table #connections (
		subject bigint,
		subjectURI nvarchar(400),
		predicate bigint,
		predicateURI nvarchar(400),
		object bigint,
		Language nvarchar(255),
		DataType nvarchar(255),
		Value nvarchar(max),
		ObjectType bit,
		SortOrder int,
		Weight float,
		Reitification bigint,
		ReitificationURI nvarchar(400),
		connectionURI nvarchar(400)
	)
	
	create table #ClassPropertyCustom (
		ClassPropertyID int primary key,
		IncludeProperty bit,
		Limit int,
		IncludeNetwork bit,
		IncludeDescription bit
	)

	--*******************************************************************************************
	--*******************************************************************************************
	-- Setup variables used for security
	--*******************************************************************************************
	--*******************************************************************************************

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT, @HasSecurityGroupNodes BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @Subject
	SELECT @HasSecurityGroupNodes = (CASE WHEN EXISTS (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END)


	--*******************************************************************************************
	--*******************************************************************************************
	-- Check if user has access to the URI
	--*******************************************************************************************
	--*******************************************************************************************

	if @subject is not null
		select @validURI = 0
			where not exists (
				select *
				from [RDF.].Node
				where NodeID = @subject
					and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
			)

	if @predicate is not null
		select @validURI = 0
			where not exists (
				select *
				from [RDF.].Node
				where NodeID = @predicate and ObjectType = 0
					and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
			)

	if @object is not null
		select @validURI = 0
			where not exists (
				select *
				from [RDF.].Node
				where NodeID = @object and ObjectType = 0
					and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
			)


	--*******************************************************************************************
	--*******************************************************************************************
	-- Get subject information when it is a literal
	--*******************************************************************************************
	--*******************************************************************************************

	select @dataStr = Value, @dataStrDataType = DataType, @dataStrLanguage = Language
		from [RDF.].Node
		where NodeID = @subject and ObjectType = 1
			and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )


	--*******************************************************************************************
	--*******************************************************************************************
	-- Seed temp tables
	--*******************************************************************************************
	--*******************************************************************************************

	---------------------------------------------------------------------------------------------
	-- Profile [seed with the subject(s)]
	---------------------------------------------------------------------------------------------
	if (@subject is not null) and (@predicate is null) and (@object is null)
	begin
		insert into #subjects(subject,showDetail,expanded,URI)
			select NodeID, @showDetails, 0, Value
				from [RDF.].Node
				where NodeID = @subject
					and ((ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		select @firstValue = URI
			from #subjects s, [RDF.].Node n
			where s.subject = @subject
				and s.subject = n.NodeID and n.ObjectType = 0
	end
	if (@NodeListXML is not null)
	begin
		insert into #subjects(subject,showDetail,expanded,URI)
			select n.NodeID, t.ShowDetails, 0, n.Value
			from [RDF.].Node n, (
				select NodeID, MAX(ShowDetails) ShowDetails
				from (
					select x.value('@ID','bigint') NodeID, IsNull(x.value('@ShowDetails','tinyint'),0) ShowDetails
					from @NodeListXML.nodes('//Node') as N(x)
				) t
				group by NodeID
				having NodeID not in (select subject from #subjects)
			) t
			where n.NodeID = t.NodeID and n.ObjectType = 0
	end
	
	---------------------------------------------------------------------------------------------
	-- Get all connections
	---------------------------------------------------------------------------------------------
	insert into #connections (subject, subjectURI, predicate, predicateURI, object, Language, DataType, Value, ObjectType, SortOrder, Weight, Reitification, ReitificationURI, connectionURI)
		select	s.NodeID subject, s.value subjectURI, 
				p.NodeID predicate, p.value predicateURI,
				t.object, o.Language, o.DataType, o.Value, o.ObjectType,
				t.SortOrder, t.Weight, 
				r.NodeID Reitification, r.Value ReitificationURI,
				@baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50))+'/'+cast(object as varchar(50)) connectionURI
			from [RDF.].Triple t
				inner join [RDF.].Node s
					on t.subject = s.NodeID
				inner join [RDF.].Node p
					on t.predicate = p.NodeID
				inner join [RDF.].Node o
					on t.object = o.NodeID
				left join [RDF.].Node r
					on t.reitification = r.NodeID
						and t.reitification is not null
						and ((r.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (r.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (r.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			where @subject is not null and @predicate is not null
				and s.NodeID = @subject 
				and p.NodeID = @predicate 
				and o.NodeID = IsNull(@object,o.NodeID)
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((s.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (s.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (s.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((p.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (p.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (p.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))

	-- Make sure there are connections
	if (@subject is not null) and (@predicate is not null)
		select @validURI = 0
		where not exists (select * from #connections)

	---------------------------------------------------------------------------------------------
	-- Network [seed with network statistics and connections]
	---------------------------------------------------------------------------------------------
	if (@subject is not null) and (@predicate is not null) and (@object is null)
	begin
		select @firstURI = @baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50))
		-- Basic network properties
		;with networkProperties as (
			select 1 n, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' property, 'rdf:type' tagName, 'type' propertyLabel, 0 ObjectType
			union all select 2, 'http://profiles.catalyst.harvard.edu/ontology/prns#numberOfConnections', 'prns:numberOfConnections', 'number of connections', 1
			union all select 3, 'http://profiles.catalyst.harvard.edu/ontology/prns#maxWeight', 'prns:maxWeight', 'maximum connection weight', 1
			union all select 4, 'http://profiles.catalyst.harvard.edu/ontology/prns#minWeight', 'prns:minWeight', 'minimum connection weight', 1
			union all select 5, 'http://profiles.catalyst.harvard.edu/ontology/prns#predicateNode', 'prns:predicateNode', 'predicate node', 0
			union all select 6, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate', 'rdf:predicate', 'predicate', 0
			union all select 7, 'http://www.w3.org/2000/01/rdf-schema#label', 'rdfs:label', 'label', 1
			union all select 8, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#subject', 'rdf:subject', 'subject', 0
		), networkStats as (
			select	cast(isnull(count(*),0) as varchar(50)) numberOfConnections,
					cast(isnull(max(Weight),1) as varchar(50)) maxWeight,
					cast(isnull(min(Weight),1) as varchar(50)) minWeight,
					max(predicateURI) predicateURI
				from #connections
		), subjectLabel as (
			select IsNull(Max(o.Value),'') Label
			from [RDF.].Triple t, [RDF.].Node o
			where t.subject = @subject
				and t.predicate = @labelID
				and t.object = o.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		)
		insert into #properties (uri,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
			select	@firstURI,
					[RDF.].fnURI2NodeID(p.property), p.property, p.tagName, p.propertyLabel,
					(case p.n when 1 then 'http://profiles.catalyst.harvard.edu/ontology/prns#Network'
								when 2 then n.numberOfConnections
								when 3 then n.maxWeight
								when 4 then n.minWeight
								when 5 then @baseURI+cast(@predicate as varchar(50))
								when 6 then n.predicateURI
								when 7 then l.Label
								when 8 then @baseURI+cast(@subject as varchar(50))
								end),
					p.ObjectType,
					1
				from networkStats n, networkProperties p, subjectLabel l
		-- Limit the number of connections if the subject is not a person
		select @limit = 10
			where (@limit is null) 
				and not exists (
					select *
					from [rdf.].[triple]
					where subject = @subject
						and predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
						and object = [RDF.].fnURI2NodeID('http://xmlns.com/foaf/0.1/Person')
				)
		-- Remove connections not within offset-limit window
		delete from #connections
			where (SortOrder < 1+IsNull(@offset,0)) or (SortOrder > IsNull(@limit,SortOrder) + (case when IsNull(@offset,0)<1 then 0 else @offset end))
		-- Add hasConnection properties
		insert into #properties (uri,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
			select	@baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50)),
					[RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#hasConnection'), 
					'http://profiles.catalyst.harvard.edu/ontology/prns#hasConnection', 'prns:hasConnection', 'has connection',
					connectionURI,
					0,
					SortOrder
				from #connections
	end

	---------------------------------------------------------------------------------------------
	-- Connection [seed with connection]
	---------------------------------------------------------------------------------------------
	if (@subject is not null) and (@predicate is not null) and (@object is not null)
	begin
		select @firstURI = @baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50))+'/'+cast(@object as varchar(50))
	end

	---------------------------------------------------------------------------------------------
	-- Expanded Connections [seed with statistics, subject, object, and connectionDetails]
	---------------------------------------------------------------------------------------------
	if (@expand = 1 or @object is not null) and exists (select * from #connections)
	begin
		-- Connection statistics
		;with connectionProperties as (
			select 1 n, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' property, 'rdf:type' tagName, 'type' propertyLabel, 0 ObjectType
			union all select 2, 'http://profiles.catalyst.harvard.edu/ontology/prns#connectionWeight', 'prns:connectionWeight', 'connection weight', 1
			union all select 3, 'http://profiles.catalyst.harvard.edu/ontology/prns#sortOrder', 'prns:sortOrder', 'sort order', 1
			union all select 4, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#object', 'rdf:object', 'object', 0
			union all select 5, 'http://profiles.catalyst.harvard.edu/ontology/prns#hasConnectionDetails', 'prns:hasConnectionDetails', 'connection details', 0
			union all select 6, 'http://profiles.catalyst.harvard.edu/ontology/prns#predicateNode', 'prns:predicateNode', 'predicate node', 0
			union all select 7, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate', 'rdf:predicate', 'predicate', 0
			union all select 8, 'http://www.w3.org/2000/01/rdf-schema#label', 'rdfs:label', 'label', 1
			union all select 9, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#subject', 'rdf:subject', 'subject', 0
			union all select 10, 'http://profiles.catalyst.harvard.edu/ontology/prns#connectionInNetwork', 'prns:connectionInNetwork', 'connection in network', 0
		)
		insert into #properties (uri,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
			select	connectionURI,
					[RDF.].fnURI2NodeID(p.property), p.property, p.tagName, p.propertyLabel,
					(case p.n	when 1 then 'http://profiles.catalyst.harvard.edu/ontology/prns#Connection'
								when 2 then cast(c.Weight as varchar(50))
								when 3 then cast(c.SortOrder as varchar(50))
								when 4 then c.value
								when 5 then c.ReitificationURI
								when 6 then @baseURI+cast(@predicate as varchar(50))
								when 7 then c.predicateURI
								when 8 then l.value
								when 9 then c.subjectURI
								when 10 then c.subjectURI+'/'+cast(@predicate as varchar(50))
								end),
					(case p.n when 4 then c.ObjectType else p.ObjectType end),
					1
				from #connections c, connectionProperties p
					left outer join (
						select o.value
							from [RDF.].Triple t, [RDF.].Node o
							where t.subject = @subject 
								and t.predicate = @labelID
								and t.object = o.NodeID
								and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
								and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
					) l on p.n = 8
				where (p.n < 5) 
					or (p.n = 5 and c.ReitificationURI is not null)
					or (p.n > 5 and @object is not null)
		if (@expand = 1)
		begin
			-- Connection subject
			insert into #subjects (subject, showDetail, expanded, URI)
				select NodeID, 0, 0, Value
					from [RDF.].Node
					where NodeID = @subject
			-- Connection objects
			insert into #subjects (subject, showDetail, expanded, URI)
				select object, 0, 0, value
					from #connections
					where ObjectType = 0 and object not in (select subject from #subjects)
			-- Connection details (reitifications)
			insert into #subjects (subject, showDetail, expanded, URI)
				select Reitification, 0, 0, ReitificationURI
					from #connections
					where Reitification is not null and Reitification not in (select subject from #subjects)
		end
	end

	--*******************************************************************************************
	--*******************************************************************************************
	-- Get property values
	--*******************************************************************************************
	--*******************************************************************************************

	-- Get custom settings to override the [Ontology.].[ClassProperty] default values
	insert into #ClassPropertyCustom (ClassPropertyID, IncludeProperty, Limit, IncludeNetwork, IncludeDescription)
		select p.ClassPropertyID, t.IncludeProperty, t.Limit, t.IncludeNetwork, t.IncludeDescription
			from [Ontology.].[ClassProperty] p
				inner join (
					select	x.value('@Class','varchar(400)') Class,
							x.value('@NetworkProperty','varchar(400)') NetworkProperty,
							x.value('@Property','varchar(400)') Property,
							(case x.value('@IncludeProperty','varchar(5)') when 'true' then 1 when 'false' then 0 else null end) IncludeProperty,
							x.value('@Limit','int') Limit,
							(case x.value('@IncludeNetwork','varchar(5)') when 'true' then 1 when 'false' then 0 else null end) IncludeNetwork,
							(case x.value('@IncludeDescription','varchar(5)') when 'true' then 1 when 'false' then 0 else null end) IncludeDescription
					from @ExpandRDFListXML.nodes('//ExpandRDF') as R(x)
				) t
				on p.Class=t.Class and p.Property=t.Property
					and ((p.NetworkProperty is null and t.NetworkProperty is null) or (p.NetworkProperty = t.NetworkProperty))

	-- Get properties and loop if objects need to be expanded
	declare @numLoops int
	declare @maxLoops int
	declare @actualLoops int
	declare @NewSubjects int
	select @numLoops = 0, @maxLoops = 10, @actualLoops = 0
	while (@numLoops < @maxLoops)
	begin
		-- Get the types of each subject that hasn't been expanded
		truncate table #types
		insert into #types(subject,object,predicate,showDetail,uri)
			select s.subject, t.object, null, s.showDetail, s.uri
				from #subjects s 
					inner join [RDF.].Triple t on s.subject = t.subject 
						and t.predicate = @typeID 
					inner join [RDF.].Node n on t.object = n.NodeID
						and ((n.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (n.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN n.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
						and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				where s.expanded = 0				   
		-- Get the subject types of each reitification that hasn't been expanded
		insert into #types(subject,object,predicate,showDetail,uri)
		select distinct s.subject, t.object, r.predicate, s.showDetail, s.uri
			from #subjects s 
				inner join [RDF.].Triple r on s.subject = r.reitification
				inner join [RDF.].Triple t on r.subject = t.subject 
					and t.predicate = @typeID 
				inner join [RDF.].Node n on t.object = n.NodeID
					and ((n.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (n.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN n.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					and ((r.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (r.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN r.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
			where s.expanded = 0
		-- Get the items that should be expanded
		truncate table #expand
		insert into #expand(subject, predicate, uri, property, tagName, propertyLabel, IsDetail, limit, showStats, showSummary)
			select p.subject, o._PropertyNode, max(p.uri) uri, o.property, o._TagName, o._PropertyLabel, min(o.IsDetail*1) IsDetail, 
					(case when min(o.IsDetail*1) = 0 then max(case when o.IsDetail=0 then IsNull(c.limit,o.limit) else null end) else max(IsNull(c.limit,o.limit)) end) limit,
					(case when min(o.IsDetail*1) = 0 then max(case when o.IsDetail=0 then IsNull(c.IncludeNetwork,o.IncludeNetwork)*1 else 0 end) else max(IsNull(c.IncludeNetwork,o.IncludeNetwork)*1) end) showStats,
					(case when min(o.IsDetail*1) = 0 then max(case when o.IsDetail=0 then IsNull(c.IncludeDescription,o.IncludeDescription)*1 else 0 end) else max(IsNull(c.IncludeDescription,o.IncludeDescription)*1) end) showSummary
				from #types p
					inner join [Ontology.].ClassProperty o
						on p.object = o._ClassNode 
						and ((p.predicate is null and o._NetworkPropertyNode is null) or (p.predicate = o._NetworkPropertyNode))
						and o.IsDetail <= p.showDetail
					left outer join #ClassPropertyCustom c
						on o.ClassPropertyID = c.ClassPropertyID
				where IsNull(c.IncludeProperty,1) = 1
				group by p.subject, o.property, o._PropertyNode, o._TagName, o._PropertyLabel
		-- Get the values for each property that should be expanded
		insert into #properties (uri,subject,predicate,object,showSummary,property,tagName,propertyLabel,Language,DataType,Value,ObjectType,SortOrder)
			select e.uri, e.subject, t.predicate, t.object, e.showSummary,
					e.property, e.tagName, e.propertyLabel, 
					o.Language, o.DataType, o.Value, o.ObjectType, t.SortOrder
			from #expand e
				inner join [RDF.].Triple t
					on t.subject = e.subject and t.predicate = e.predicate
						and (e.limit is null or t.sortorder <= e.limit)
						and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				inner join [RDF.].Node p
					on t.predicate = p.NodeID
						and ((p.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (p.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN p.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				inner join [RDF.].Node o
					on t.object = o.NodeID
						and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
		-- Get network properties
		if (@numLoops = 0)
		begin
			-- Calculate network statistics
			select e.uri, e.subject, t.predicate, e.property, e.tagName, e.PropertyLabel, 
					cast(isnull(count(*),0) as varchar(50)) numberOfConnections,
					cast(isnull(max(t.Weight),1) as varchar(50)) maxWeight,
					cast(isnull(min(t.Weight),1) as varchar(50)) minWeight,
					@baseURI+cast(e.subject as varchar(50))+'/'+cast(t.predicate as varchar(50)) networkURI
				into #networks
				from #expand e
					inner join [RDF.].Triple t
						on t.subject = e.subject and t.predicate = e.predicate
							and (e.showStats = 1)
							and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					inner join [RDF.].Node p
						on t.predicate = p.NodeID
							and ((p.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (p.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN p.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					inner join [RDF.].Node o
						on t.object = o.NodeID
							and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				group by e.uri, e.subject, t.predicate, e.property, e.tagName, e.PropertyLabel
			-- Create properties from network statistics
			;with networkProperties as (
				select 1 n, 'http://profiles.catalyst.harvard.edu/ontology/prns#hasNetwork' property, 'prns:hasNetwork' tagName, 'has network' propertyLabel, 0 ObjectType
				union all select 2, 'http://profiles.catalyst.harvard.edu/ontology/prns#numberOfConnections', 'prns:numberOfConnections', 'number of connections', 1
				union all select 3, 'http://profiles.catalyst.harvard.edu/ontology/prns#maxWeight', 'prns:maxWeight', 'maximum connection weight', 1
				union all select 4, 'http://profiles.catalyst.harvard.edu/ontology/prns#minWeight', 'prns:minWeight', 'minimum connection weight', 1
				union all select 5, 'http://profiles.catalyst.harvard.edu/ontology/prns#predicateNode', 'prns:predicateNode', 'predicate node', 0
				union all select 6, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate', 'rdf:predicate', 'predicate', 0
				union all select 7, 'http://www.w3.org/2000/01/rdf-schema#label', 'rdfs:label', 'label', 1
				union all select 8, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'rdf:type', 'type', 0
			)
			insert into #properties (uri,subject,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
				select	(case p.n when 1 then n.uri else n.networkURI end),
						(case p.n when 1 then subject else null end),
						[RDF.].fnURI2NodeID(p.property), p.property, p.tagName, p.propertyLabel,
						(case p.n when 1 then n.networkURI 
									when 2 then n.numberOfConnections
									when 3 then n.maxWeight
									when 4 then n.minWeight
									when 5 then @baseURI+cast(n.predicate as varchar(50))
									when 6 then n.property
									when 7 then n.PropertyLabel
									when 8 then 'http://profiles.catalyst.harvard.edu/ontology/prns#Network'
									end),
						p.ObjectType,
						1
					from #networks n, networkProperties p
					where p.n = 1 or @expand = 1
		end
		-- Mark that all previous subjects have been expanded
		update #subjects set expanded = 1 where expanded = 0
		-- See if there are any new subjects that need to be expanded
		insert into #subjects(subject,showDetail,expanded,uri)
			select distinct object, 0, 0, value
				from #properties
				where showSummary = 1
					and ObjectType = 0
					and object not in (select subject from #subjects)
		select @NewSubjects = @@ROWCOUNT		
		insert into #subjects(subject,showDetail,expanded,uri)
			select distinct predicate, 0, 0, property
				from #properties
				where predicate is not null
					and predicate not in (select subject from #subjects)
		-- If no subjects need to be expanded, then we are done
		if @NewSubjects + @@ROWCOUNT = 0
			select @numLoops = @maxLoops
		select @numLoops = @numLoops + 1 + @maxLoops * (1 - @expand)
		select @actualLoops = @actualLoops + 1
	end
	-- Add tagName as a property of DatatypeProperty and ObjectProperty classes
	insert into #properties (uri, subject, showSummary, property, tagName, propertyLabel, Value, ObjectType, SortOrder)
		select p.uri, p.subject, 0, 'http://profiles.catalyst.harvard.edu/ontology/prns#tagName', 'prns:tagName', 'tag name', 
				n.prefix+':'+substring(p.uri,len(n.uri)+1,len(p.uri)), 1, 1
			from #properties p, [Ontology.].Namespace n
			where p.property = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
				and p.value in ('http://www.w3.org/2002/07/owl#DatatypeProperty','http://www.w3.org/2002/07/owl#ObjectProperty')
				and p.uri like n.uri+'%'
	--select @actualLoops
	--select * from #properties order by (case when uri = @firstURI then 0 else 1 end), uri, tagName, value


	--*******************************************************************************************
	--*******************************************************************************************
	-- Handle the special case where a local node is storing a copy of an external URI
	--*******************************************************************************************
	--*******************************************************************************************

	if (@firstValue IS NOT NULL) AND (@firstValue <> @firstURI)
		insert into #properties (uri, subject, predicate, object, 
				showSummary, property, 
				tagName, propertyLabel, 
				Language, DataType, Value, ObjectType, SortOrder
			)
			select @firstURI uri, @subject subject, predicate, object, 
					showSummary, property, 
					tagName, propertyLabel, 
					Language, DataType, Value, ObjectType, 1 SortOrder
				from #properties
				where uri = @firstValue
					and not exists (select * from #properties where uri = @firstURI)
			union all
			select @firstURI uri, @subject subject, null predicate, null object, 
					0 showSummary, 'http://www.w3.org/2002/07/owl#sameAs' property,
					'owl:sameAs' tagName, 'same as' propertyLabel, 
					null Language, null DataType, @firstValue Value, 0 ObjectType, 1 SortOrder

	--*******************************************************************************************
	--*******************************************************************************************
	-- Generate an XML string from the node properties table
	--*******************************************************************************************
	--*******************************************************************************************

	declare @description nvarchar(max)
	select @description = ''
	-- sort the tags
	select *, 
			row_number() over (partition by uri order by i) j, 
			row_number() over (partition by uri order by i desc) k 
		into #propertiesSorted
		from (
			select *, row_number() over (order by (case when uri = @firstURI then 0 else 1 end), uri, tagName, SortOrder, value) i
				from #properties
		) t
	create unique clustered index idx_i on #propertiesSorted(i)
	-- handle special xml characters in the uri and value strings
	update #propertiesSorted
		set uri = replace(replace(replace(uri,'&','&amp;'),'<','&lt;'),'>','&gt;')
		where uri like '%[&<>]%'
	update #propertiesSorted
		set value = replace(replace(replace(value,'&','&amp;'),'<','&lt;'),'>','&gt;')
		where value like '%[&<>]%'
	-- concatenate the tags
	select @description = (
			select (case when j=1 then '<rdf:Description rdf:about="' + uri + '">' else '' end)
					+'<'+tagName
					+(case when ObjectType = 0 then ' rdf:resource="'+value+'"/>' else '>'+value+'</'+tagName+'>' end)
					+(case when k=1 then '</rdf:Description>' else '' end)
			from #propertiesSorted
			order by i
			for xml path(''), type
		).value('(./text())[1]','nvarchar(max)')
	-- default description if none exists
	if (@description IS NULL) OR (@validURI = 0)
		select @description = '<rdf:Description rdf:about="' + @firstURI + '"'
			+IsNull(' xml:lang="'+@dataStrLanguage+'"','')
			+IsNull(' rdf:datatype="'+@dataStrDataType+'"','')
			+IsNull(' >'+replace(replace(replace(@dataStr,'&','&amp;'),'<','&lt;'),'>','&gt;')+'</rdf:Description>',' />')


	--*******************************************************************************************
	--*******************************************************************************************
	-- Return as a string or as XML
	--*******************************************************************************************
	--*******************************************************************************************

	select @dataStr = IsNull(@dataStr,@description)

	declare @x as varchar(max)
	select @x = '<rdf:RDF'
	select @x = @x + ' xmlns:'+Prefix+'="'+URI+'"' 
		from [Ontology.].Namespace
	select @x = @x + ' >' + @description + '</rdf:RDF>'

	if @returnXML = 1 and @returnXMLasStr = 0
		select cast(replace(@x,char(13),'&#13;') as xml) RDF

	if @returnXML = 1 and @returnXMLasStr = 1
		select @x RDF

	/*	
		declare @d datetime
		select @d = getdate()
		select datediff(ms,@d,getdate())
	*/
		
END
GO
PRINT N'Altering [RDF.].[GetStoreNode]...';


GO
ALTER PROCEDURE [RDF.].[GetStoreNode]
	-- Cat0
	@ExistingNodeID bigint = null,
	-- Cat1
	@Value nvarchar(max) = null,
	@Language nvarchar(255) = null,
	@DataType nvarchar(255) = null,
	@ObjectType bit = null,
	-- Cat2
	@Class nvarchar(400) = null,
	@InternalType nvarchar(100) = null,
	@InternalID nvarchar(100) = null,
	-- Cat3
	@TripleID bigint = null,
	-- Cat5, Cat6
	@StartTime nvarchar(100) = null,
	@EndTime nvarchar(100) = null,
	@TimePrecision nvarchar(100) = null,
	-- Cat7
	@DefaultURI bit = null,
	-- Cat8
	@EntityClassID bigint = null,
	@EntityClassURI varchar(400) = null,
	@Label nvarchar(max) = null,
	@ForceNewEntity bit = 0,
	-- Cat9
	@SubjectID bigint = null,
	@PredicateID bigint = null,
	@SortOrder int = null,
	-- Attributes
	@ViewSecurityGroup bigint = null,
	@EditSecurityGroup bigint = null,
	-- Security
	@SessionID uniqueidentifier = NULL,
	-- Output variables
	@Error bit = NULL OUTPUT,
	@NodeID bigint = NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/* 
	The node can be defined in different ways:
		Cat 0: ExistingNodeID (a NodeID from [RDF.].Node)
		Cat 1: Value, Language, DataType, ObjectType (standard RDF literal [ObjectType=1], or just Value if URI [ObjectType=0])
		Cat 2: NodeType (primary VIVO type, http://xmlns.com/foaf/0.1/Person), InternalType (Profiles10 type, such as "Person"), InternalID (personID=32213)
		Cat 3: TripleID (from [RDF.].Triple -- a reitification)
		Cat 5: StartTime, EndTime, TimePrecision (VIVO's DateTimeInterval, DateTimeValue, and DateTimeValuePrecision classes)
		Cat 6: StartTime, TimePrecision (VIVO's DateTimeValue, and DateTimeValuePrecision classes)
		Cat 7: The default URI: baseURI+NodeID
		Cat 8: New entity with class (by node ID or URI) and label; ForceNewEntity=1 always creates a new node
		Cat 9: The object node of a triple given the SubjectID node, PredicateID node, and the triple sort order
	*/

	SELECT @Error = 0

	SELECT @ExistingNodeID = NULL WHERE @ExistingNodeID = 0
	SELECT @TripleID = NULL WHERE @TripleID = 0

 	IF (@EntityClassID IS NULL) AND (@EntityClassURI IS NOT NULL)
		SELECT @EntityClassID = [RDF.].fnURI2NodeID(@EntityClassURI)

	-- Determine the category
	DECLARE @Category INT
	SELECT @Category = (
		CASE
			WHEN (@ExistingNodeID IS NOT NULL) THEN 0
			WHEN (@Value IS NOT NULL) THEN 1
			WHEN ((@Class IS NOT NULL) AND (@InternalType IS NOT NULL) AND (@InternalID IS NOT NULL)) THEN 2
			WHEN (@TripleID IS NOT NULL) THEN 3
			WHEN ((@StartTime IS NOT NULL) AND (@EndTime IS NOT NULL) AND (@TimePrecision IS NOT NULL)) THEN 5
			WHEN ((@StartTime IS NOT NULL) AND (@TimePrecision IS NOT NULL)) THEN 6
			WHEN (@DefaultURI = 1) THEN 7
			WHEN ((@EntityClassID IS NOT NULL) AND (IsNull(@Label,'')<>'')) THEN 8
			WHEN ((@SubjectID IS NOT NULL) AND (@PredicateID IS NOT NULL) AND (@SortOrder IS NOT NULL)) THEN 9
			ELSE NULL END)

	IF @Category IS NULL
	BEGIN
		SELECT @Error = 1
		RETURN
	END

	-- Determine if the node already exists
	SELECT @NodeID = (CASE
		WHEN @Category = 0 THEN (
				SELECT NodeID
				FROM [RDF.].[Node]
				WHERE NodeID = @ExistingNodeID
			)
		WHEN @Category = 1 THEN (
				SELECT NodeID
				FROM [RDF.].[Node]
				WHERE ValueHash = [RDF.].[fnValueHash](@Language,@DataType,@Value)
			)
		WHEN @Category = 2 THEN (
				SELECT NodeID
				FROM [RDF.Stage].InternalNodeMap
				WHERE Class = @Class AND InternalType = @InternalType AND InternalID = @InternalID
			)
		WHEN @Category = 8 THEN (
				SELECT NodeID
				FROM [RDF.].Triple t, [RDF.].Triple v, [RDF.].Node n
				WHERE t.subject = v.subject
					AND t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
					AND t.object = @EntityClassID
					AND v.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
					AND v.object = n.NodeID
					AND n.ValueHash = [RDF.].[fnValueHash](null,null,@Label)
					AND @ForceNewEntity = 0
			)
		WHEN @Category = 9 THEN (
				SELECT t.Object
				FROM [RDF.].[Triple] t
				WHERE t.subject = @SubjectID
					AND t.predicate = @PredicateID
					AND t.SortOrder = @SortOrder
			)
		ELSE NULL END)

	-- Update attributes of an existing node
	IF (@NodeID IS NOT NULL) AND (IsNull(@ViewSecurityGroup,@EditSecurityGroup) IS NOT NULL)
	BEGIN
		UPDATE [RDF.].Node
			SET ViewSecurityGroup = IsNull(@ViewSecurityGroup,ViewSecurityGroup),
				EditSecurityGroup = IsNull(@EditSecurityGroup,EditSecurityGroup)
			WHERE NodeID = @NodeID
	END

	-- Check that if a new node is needed, then all attributes are defined
	IF (@NodeID IS NULL)
	BEGIN
		SELECT	@ViewSecurityGroup = IsNull(@ViewSecurityGroup,-1),
				@EditSecurityGroup = IsNull(@EditSecurityGroup,-40)
		SELECT	@ObjectType = (CASE WHEN @Value LIKE 'http://%' or @Value LIKE 'https://%' THEN 0 ELSE 1 END)
			WHERE (@Category=1 AND @ObjectType IS NULL)
	END

	-- Create a new node if needed
	IF (@NodeID IS NULL)	
	BEGIN
		BEGIN TRY 
		BEGIN TRANSACTION

		-- Lookup the base URI
		DECLARE @baseURI NVARCHAR(400)
		SELECT @baseURI = Value FROM [Framework.].Parameter WHERE ParameterID = 'baseURI'

		-- Create node based on category
		IF @Category = 1
			BEGIN
				INSERT INTO [RDF.].[Node] (ViewSecurityGroup, EditSecurityGroup, Language, DataType, Value, ObjectType, ValueHash)
					SELECT @ViewSecurityGroup, @EditSecurityGroup, @Language, @DataType, @Value, @ObjectType,
						[RDF.].[fnValueHash](@Language,@DataType,@Value)
				SET @NodeID = @@IDENTITY
			END
		IF @Category = 2
			BEGIN
				-- Create the InternalNodeMap record
				DECLARE @InternalNodeMapID BIGINT
				INSERT INTO [RDF.Stage].[InternalNodeMap] (InternalType, InternalID, Class, Status, InternalHash)
					SELECT @InternalType, @InternalID, @Class, 4, 
						[RDF.].fnValueHash(null,null,@Class+'^^'+@InternalType+'^^'+@InternalID)
				SET @InternalNodeMapID = @@IDENTITY
				-- Create the Node
				INSERT INTO [RDF.].[Node] (ViewSecurityGroup, EditSecurityGroup, InternalNodeMapID, ObjectType, Value, ValueHash)
					SELECT @ViewSecurityGroup, @EditSecurityGroup, @InternalNodeMapID, 0,
						'#INM'+cast(@InternalNodeMapID as nvarchar(50)),
						[RDF.].fnValueHash(null,null,'#INM'+cast(@InternalNodeMapID as nvarchar(50)))
				SET @NodeID = @@IDENTITY
				-- Update the InternalNodeMap, given the NodeID
				UPDATE [RDF.Stage].[InternalNodeMap]
					SET NodeID = @NodeID, Status = 3,
						ValueHash = [RDF.].fnValueHash(null,null,@baseURI+cast(@NodeID as nvarchar(50)))
					WHERE InternalNodeMapID = @InternalNodeMapID
				-- Update the Node, given the NodeID
				UPDATE [RDF.].[Node]
					SET Value = @baseURI+cast(@NodeID as nvarchar(50)),
						ValueHash = [RDF.].fnValueHash(null,null,@baseURI+cast(@NodeID as nvarchar(50)))
					WHERE NodeID = @NodeID
			END
		IF @Category = 7
			BEGIN
				-- Create the Node
				DECLARE @TempValue varchar(50)
				SELECT @TempValue = '#NODE'+cast(NewID() as varchar(50))
				INSERT INTO [RDF.].[Node] (ViewSecurityGroup, EditSecurityGroup, Value, ObjectType, ValueHash)
					SELECT @ViewSecurityGroup, @EditSecurityGroup, @TempValue, 0, [RDF.].[fnValueHash](NULL,NULL,@TempValue)
				SET @NodeID = @@IDENTITY
				-- Update the Node, given the NodeID
				UPDATE [RDF.].[Node]
					SET Value = @baseURI+cast(@NodeID as nvarchar(50)),
						ValueHash = [RDF.].fnValueHash(null,null,@baseURI+cast(@NodeID as nvarchar(50)))
					WHERE NodeID = @NodeID
			END
		IF @Category = 8
			BEGIN
				-- Create the new node
				EXEC [RDF.].GetStoreNode	@DefaultURI = 1,
											@ViewSecurityGroup = @ViewSecurityGroup,
											@EditSecurityGroup = @EditSecurityGroup,
											@SessionID = @SessionID,
											@Error = @Error OUTPUT,
											@NodeID = @NodeID OUTPUT
				IF @Error = 1
				BEGIN
					RETURN
				END
				-- Convert URIs to NodeIDs
				DECLARE @TypeID BIGINT
				DECLARE @LabelID BIGINT
				DECLARE @ClassID BIGINT
				DECLARE @SubClassID BIGINT
				SELECT	@TypeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type'),
						@LabelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label'),
						@ClassID = [RDF.].fnURI2NodeID('http://www.w3.org/2002/07/owl#Class'),
						@SubClassID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#subClassOf')
				-- Add class(es) to new node
				DECLARE @TempClassID BIGINT
				SELECT @TempClassID = @EntityClassID
				WHILE (@TempClassID IS NOT NULL)
				BEGIN
					EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
												@PredicateID = @TypeID,
												@ObjectID = @TempClassID,
												@ViewSecurityGroup = -1,
												@Weight = 1,
												@SessionID = @SessionID,
												@Error = @Error OUTPUT
					IF @Error = 1
					BEGIN
						RETURN
					END
					-- Determine if there is a parent class
					SELECT @TempClassID = (
							SELECT TOP 1 t.object
							FROM [RDF.].Triple t, [RDF.].Triple c
							WHERE t.subject = @TempClassID
								AND t.predicate = @SubClassID
								AND c.subject = t.object
								AND c.predicate = @TypeID
								AND c.object = @ClassID
								AND NOT EXISTS (
									SELECT *
									FROM [RDF.].Triple v
									WHERE v.subject = @NodeID
										AND v.predicate = @TypeID
										AND v.object = t.object
								)
						)
				END
				-- Get node ID for label
				DECLARE @LabelNodeID BIGINT
				EXEC [RDF.].GetStoreNode	@Value = @Label,
											@ObjectType = 1,
											@ViewSecurityGroup = -1,
											@EditSecurityGroup = -40,
											@SessionID = @SessionID,
											@Error = @Error OUTPUT,
											@NodeID = @LabelNodeID OUTPUT
				IF @Error = 1
				BEGIN
					RETURN
				END
				-- Add label to new node
				EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
											@PredicateID = @LabelID,
											@ObjectID = @LabelNodeID,
											@ViewSecurityGroup = -1,
											@Weight = 1,
											@SortOrder = 1,
											@SessionID = @SessionID,
											@Error = @Error OUTPUT
				IF @Error = 1
				BEGIN
					RETURN
				END
			END
		IF @Category = 9
			BEGIN
				-- We can't create a new node in this case, so throw an error
				SELECT @Error = 1
			END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK

		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()

		RAISERROR(@ErrMsg, @ErrSeverity, 1)

	END CATCH		
	END

END
GO
PRINT N'Altering [User.Session].[CreateSession]...';


GO
ALTER procedure [User.Session].[CreateSession]
    @RequestIP VARCHAR(16),
    @UserAgent VARCHAR(500) = NULL,
    @UserID VARCHAR(200) = NULL,
	@SessionPersonNodeID BIGINT = NULL OUTPUT,
	@SessionPersonURI VARCHAR(400) = NULL OUTPUT
AS 
BEGIN
 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON ;

	-- See if there is a PersonID associated with the user	
	DECLARE @PersonID INT
	IF @UserID IS NOT NULL
		SELECT @PersonID = PersonID
			FROM [User.Account].[User]
			WHERE UserID = @UserID

	-- Get the NodeID and URI of the PersonID
	IF @PersonID IS NOT NULL
	BEGIN
		SELECT @SessionPersonNodeID = m.NodeID, @SessionPersonURI = p.Value + CAST(m.NodeID AS VARCHAR(50))
			FROM [RDF.Stage].InternalNodeMap m, [Framework.].[Parameter] p
			WHERE m.InternalID = @PersonID
				AND m.InternalType = 'person'
				AND m.Class = 'http://xmlns.com/foaf/0.1/Person'
				AND p.ParameterID = 'baseURI'
	END


	-- Create a SessionID
    DECLARE @SessionID UNIQUEIDENTIFIER
	SELECT @SessionID = NEWID()
 
	-- Create the Session table record
	INSERT INTO [User.Session].Session
		(	SessionID,
			CreateDate,
			LastUsedDate,
			LoginDate,
			LogoutDate,
			RequestIP,
			UserID,
			UserNode,
			PersonID,
			UserAgent,
			IsBot
		)
        SELECT  @SessionID ,
                GETDATE() ,
                GETDATE() ,
                CASE WHEN @UserID IS NULL THEN NULL
                        ELSE GETDATE()
                END ,
                NULL ,
                @RequestIP ,
                @UserID ,
				(SELECT NodeID FROM [User.Account].[User] WHERE UserID = @UserID AND @UserID IS NOT NULL),
                @PersonID,
                @UserAgent,
                0
                    
    -- Check if bot
	DECLARE @IsBot BIT
	SELECT @IsBot = 0
	SELECT @IsBot = 1
		WHERE @UserAgent IS NOT NULL AND EXISTS (SELECT * FROM [User.Session].[Bot] WHERE @UserAgent LIKE UserAgent)
	If (@IsBot = 1)
		UPDATE [User.Session].Session
			SET IsBot = 1
			WHERE SessionID = @SessionID

	-- Create a node if not a bot
	If (@IsBot = 0)
	BEGIN

		-- Get the BaseURI
		DECLARE @baseURI NVARCHAR(400)
		SELECT @baseURI = Value FROM [Framework.].Parameter WHERE ParameterID = 'baseURI'

		-- Create the Node
		DECLARE @NodeID BIGINT
		INSERT INTO [RDF.].[Node] (ViewSecurityGroup, EditSecurityGroup, Value, ObjectType, ValueHash)
			SELECT IDENT_CURRENT('[RDF.].[Node]'), -50, @baseURI+CAST(IDENT_CURRENT('[RDF.].[Node]') as varchar(50)), 0,
				[RDF.].fnValueHash(null,null,@baseURI+CAST(IDENT_CURRENT('[RDF.].[Node]') as nvarchar(50)))
		SELECT @NodeID = @@IDENTITY


		-- Confirm the node values are correct
		IF EXISTS (
			SELECT *
			FROM [RDF.].[Node]
			WHERE NodeID = @NodeID
				AND (
					Value <> @baseURI+cast(@NodeID as nvarchar(50))
					OR ValueHash <> [RDF.].fnValueHash(null,null,@baseURI+cast(@NodeID as nvarchar(50)))
					OR ViewSecurityGroup <> @NodeID
				)
			)

		BEGIN
			UPDATE [RDF.].[Node]
				SET Value = @baseURI+cast(@NodeID as nvarchar(50)),
					ValueHash = [RDF.].fnValueHash(null,null,@baseURI+cast(@NodeID as nvarchar(50))),
					ViewSecurityGroup = @NodeID
				WHERE NodeID = @NodeID
		END
 
		-- Add properties to the node
		DECLARE @Error INT
		DECLARE @TypeID BIGINT
		DECLARE @SessionClass BIGINT
		DECLARE @TripleID BIGINT
		SELECT	@TypeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type'),
				@SessionClass = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#Session')
		EXEC [RDF.].[GetStoreTriple]	@SubjectID = @NodeID,
										@PredicateID = @TypeID,
										@ObjectID = @SessionClass,
										@ViewSecurityGroup = @NodeID,
										@Weight = 1,
										@SortOrder = 1,
										@SessionID = @SessionID,
										@Error = @Error OUTPUT,
										@TripleID = @TripleID OUTPUT

		-- If no error, then assign the NodeID to the session
		IF (@Error = 0)
		BEGIN
			-- Update the Session record with the NodeID
			UPDATE [User.Session].Session
				SET NodeID = @NodeID
				WHERE SessionID = @SessionID
		END
	END

    SELECT *
		FROM [User.Session].[Session]
		WHERE SessionID = @SessionID AND @SessionID IS NOT NULL
 
END
GO
PRINT N'Altering [Search.].[ParseSearchString]...';


GO
ALTER PROCEDURE [Search.].[ParseSearchString]
	@SearchString VARCHAR(500) = NULL,
	@NumberOfPhrases INT = 0 OUTPUT,
	@CombinedSearchString VARCHAR(8000) = '' OUTPUT,
	@SearchString1 VARCHAR(8000) = NULL OUTPUT,
	@SearchString2 VARCHAR(8000) = NULL OUTPUT,
	@SearchString3 VARCHAR(8000) = NULL OUTPUT,
	@SearchPhraseXML XML = NULL OUTPUT,
	@SearchPhraseFormsXML XML = NULL OUTPUT,
	@ProcessTime INT = 0 OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

	-- Start timer
	declare @d datetime
	select @d = GetDate()


	-- Remove bad characters
	declare @SearchStringNormalized varchar(max)
	select @SearchStringNormalized = ''
	declare @StringPos int
	select @StringPos = 1
	declare @InQuotes tinyint
	select @InQuotes = 0
	declare @Char char(1)
	while @StringPos <= len(@SearchString)
	begin
		select @Char = substring(@SearchString,@StringPos,1)
		select @InQuotes = 1 - @InQuotes where @Char = '"'
		if @Char like '[0-9A-Za-z]'
			select @SearchStringNormalized = @SearchStringNormalized + @Char
		else if @Char = '"'
			select @SearchStringNormalized = @SearchStringNormalized + ' '
		else if right(@SearchStringNormalized,1) not in (' ','_')
			select @SearchStringNormalized = @SearchStringNormalized + (case when @InQuotes = 1 then '_' else ' ' end)
		select @StringPos = @StringPos + 1
	end
	select @SearchStringNormalized = replace(@SearchStringNormalized,'  ',' ')
	select @SearchStringNormalized = ' ' + ltrim(rtrim(replace(replace(' '+@SearchStringNormalized+' ',' _',' '),'_ ',' '))) + ' |'


	-- Find phrase positions
	declare @PhraseBreakPositions table (z int, n int, m int, i int)
	;with a as (
		select n.n, row_number() over (order by n.n) - 1 i
			from [Utility.Math].N n
			where n.n between 1 and len(@SearchStringNormalized) and substring(@SearchStringNormalized,n.n,1) = ' '
	), b as (
		select count(*)-1 j from a
	)
	insert into @PhraseBreakPositions
		select n.n z, a.n, a.i m, row_number() over (partition by n.n order by a.n) i
			from a, b, [Utility.Math].N n
			where n.n < Power(2,b.j-1)
				and 1 = (case when a.i=0 then 1 when a.i=b.j then 1 when Power(2,a.i-1) & n.n > 0 then 1 else 0 end)
	select @SearchStringNormalized = replace(@SearchStringNormalized,'_',' ')


	-- Extract phrases
	declare @TempPhraseList table (i int, w varchar(max), x int) 
	;with d as (
		select c.*, substring(@SearchStringNormalized,c.n+1,d.n-c.n-1) w, d.m-c.m l
			from @PhraseBreakPositions c, @PhraseBreakPositions d
			where c.z=d.z and c.i=d.i-1
	), e as (
		select d.*, IsNull(t.x,0) x
		from d outer apply (select top 1 1 x from [Utility.NLP].Thesaurus t where d.w = t.TermName) t
	), f as (
		select top 1 z
		from e
		group by z 
		order by sum(l*l*x) desc, z desc
	)
	insert into @TempPhraseList
		select row_number() over (order by e.i) i, e.w, e.x
			from e, f
			where e.z = f.z
				and e.w not in (select word from [Utility.NLP].StopWord where scope = 0)
				and e.w <> ''
	declare @PhraseList table (PhraseID int, Phrase varchar(max), ThesaurusMatch bit, Forms varchar(max))
	insert into @PhraseList (PhraseID, Phrase, ThesaurusMatch, Forms)
		select i, w, x, (case when x = 0 then '"'+[Utility.NLP].fnPorterAlgorithm(p.w)+'*"'
						else substring(cast( (
									select distinct ' OR "'+v.TermName+'"'
										from [Utility.NLP].Thesaurus t, [Utility.NLP].Thesaurus v
										where p.w=t.TermName and t.Source=v.Source and t.ConceptID=v.ConceptID
										for xml path(''), type
								) as varchar(max)),5,999999)
						end)
		from @TempPhraseList p
	select @NumberOfPhrases = (select max(PhraseID) from @PhraseList)
	select @SearchStringNormalized = substring(@SearchStringNormalized,2,len(@SearchStringNormalized)-3)

	-- Create a combined string for fulltext search
	/*
	select @CombinedSearchString = 
			(case when @NumberOfPhrases = 0 then ''
				when @NumberOfPhrases = 1 then
					'"'+@SearchStringNormalized+'" OR ' + (select Forms from @PhraseList)
				else
					'"'+@SearchStringNormalized+'"'
					+ ' OR '
					--+ '(' + replace(@SearchStringNormalized,' ',' NEAR ') + ')'
					+ '(' + substring(cast((select ' NEAR '+Phrase from @PhraseList order by PhraseID for xml path(''), type) as varchar(max)),7,999999) + ')'
					+ ' OR '
					+ '(' + substring(cast((select ' AND ('+Forms+')' from @PhraseList order by PhraseID for xml path(''), type) as varchar(max)),6,999999) + ')'
				end)
	*/
	if @NumberOfPhrases = 0
		select @SearchString1 = NULL, @SearchString2 = NULL, @SearchString3 = NULL
	if @NumberOfPhrases = 1
		select	@SearchString1 = '"'+@SearchStringNormalized+'"', 
				@SearchString2 = (select Forms from @PhraseList),
				@SearchString3 = NULL
	if @NumberOfPhrases > 1
		select	@SearchString1 = '"'+@SearchStringNormalized+'"', 
				@SearchString2 = '(' + substring(cast((select ' NEAR "'+Phrase+'"' from @PhraseList order by PhraseID for xml path(''), type) as varchar(max)),7,999999) + ')',
				@SearchString3 = '(' + substring(cast((select ' AND ('+Forms+')' from @PhraseList order by PhraseID for xml path(''), type) as varchar(max)),6,999999) + ')'
	select @CombinedSearchString = IsNull(@SearchString1,'') + IsNull(' OR '+@SearchString2,'') + IsNull(' OR '+@SearchString3,'')
	
	-- Create an XML message listing the parsed phrases
	select @SearchPhraseXML =		(select
										(select PhraseID "SearchPhrase/@ID", 
											(case when ThesaurusMatch='1' then 'true' else 'false' end) "SearchPhrase/@ThesaurusMatch",
											Phrase "SearchPhrase"
										from @PhraseList
										order by PhraseID
										for xml path(''), type) "SearchPhraseList"
									for xml path(''), type)
	select @SearchPhraseFormsXML =	(select
										(select PhraseID "SearchPhrase/@ID", 
											(case when ThesaurusMatch='1' then 'true' else 'false' end) "SearchPhrase/@ThesaurusMatch",
											Forms "SearchPhrase/@Forms",
											Phrase "SearchPhrase"
										from @PhraseList
										order by PhraseID
										for xml path(''), type) "SearchPhraseList"
									for xml path(''), type)

					
	-- End timer
	select @ProcessTime = datediff(ms,@d,GetDate())

END
GO
PRINT N'Altering [Search.Cache].[Public.GetNodes]...';


GO
ALTER PROCEDURE [Search.Cache].[Public.GetNodes]
	@SearchOptions XML,
	@SessionID UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

	/*
	
	EXEC [Search.].[GetNodes] @SearchOptions = '
	<SearchOptions>
		<MatchOptions>
			<SearchString ExactMatch="false">options for "lung cancer" treatment</SearchString>
			<ClassURI>http://xmlns.com/foaf/0.1/Person</ClassURI>
			<SearchFiltersList>
				<SearchFilter Property="http://xmlns.com/foaf/0.1/lastName" MatchType="Left">Smit</SearchFilter>
			</SearchFiltersList>
		</MatchOptions>
		<OutputOptions>
			<Offset>0</Offset>
			<Limit>5</Limit>
			<SortByList>
				<SortBy IsDesc="1" Property="http://xmlns.com/foaf/0.1/firstName" />
				<SortBy IsDesc="0" Property="http://xmlns.com/foaf/0.1/lastName" />
			</SortByList>
		</OutputOptions>	
	</SearchOptions>
	'
		
	*/

	declare @MatchOptions xml
	declare @OutputOptions xml
	declare @SearchString varchar(500)
	declare @ClassGroupURI varchar(400)
	declare @ClassURI varchar(400)
	declare @SearchFiltersXML xml
	declare @offset bigint
	declare @limit bigint
	declare @SortByXML xml
	declare @DoExpandedSearch bit
	
	select	@MatchOptions = @SearchOptions.query('SearchOptions[1]/MatchOptions[1]'),
			@OutputOptions = @SearchOptions.query('SearchOptions[1]/OutputOptions[1]')
	
	select	@SearchString = @MatchOptions.value('MatchOptions[1]/SearchString[1]','varchar(500)'),
			@DoExpandedSearch = (case when @MatchOptions.value('MatchOptions[1]/SearchString[1]/@ExactMatch','varchar(50)') = 'true' then 0 else 1 end),
			@ClassGroupURI = @MatchOptions.value('MatchOptions[1]/ClassGroupURI[1]','varchar(400)'),
			@ClassURI = @MatchOptions.value('MatchOptions[1]/ClassURI[1]','varchar(400)'),
			@SearchFiltersXML = @MatchOptions.query('MatchOptions[1]/SearchFiltersList[1]'),
			@offset = @OutputOptions.value('OutputOptions[1]/Offset[1]','bigint'),
			@limit = @OutputOptions.value('OutputOptions[1]/Limit[1]','bigint'),
			@SortByXML = @OutputOptions.query('OutputOptions[1]/SortByList[1]')

	declare @baseURI nvarchar(400)
	select @baseURI = value from [Framework.].Parameter where ParameterID = 'baseURI'

	declare @d datetime
	declare @dd datetime
	select @d = GetDate()
	
	declare @IsBot bit
	if @SessionID is not null
		select @IsBot = IsBot
			from [User.Session].[Session]
			where SessionID = @SessionID
	select @IsBot = IsNull(@IsBot,0)

	select @limit = 100
		where (@limit is null) or (@limit > 100)
	
	declare @SearchHistoryQueryID int
	insert into [Search.].[History.Query] (StartDate, SessionID, IsBot, SearchOptions)
		select GetDate(), @SessionID, @IsBot, @SearchOptions
	select @SearchHistoryQueryID = @@IDENTITY

	-------------------------------------------------------
	-- Parse search string and convert to fulltext query
	-------------------------------------------------------
select @d = GetDate()
/*
	declare @NumberOfPhrases INT
	declare @CombinedSearchString VARCHAR(8000)
	declare @SearchPhraseXML XML
	declare @SearchPhraseFormsXML XML
	declare @ParseProcessTime INT

	EXEC [Search.].[ParseSearchString]	@SearchString = @SearchString,
										@NumberOfPhrases = @NumberOfPhrases OUTPUT,
										@CombinedSearchString = @CombinedSearchString OUTPUT,
										@SearchPhraseXML = @SearchPhraseXML OUTPUT,
										@SearchPhraseFormsXML = @SearchPhraseFormsXML OUTPUT,
										@ProcessTime = @ParseProcessTime OUTPUT

*/

	declare @NumberOfPhrases INT
	declare @CombinedSearchString VARCHAR(8000)
	declare @SearchString1 VARCHAR(8000)
	declare @SearchString2 VARCHAR(8000)
	declare @SearchString3 VARCHAR(8000)
	declare @SearchPhraseXML XML
	declare @SearchPhraseFormsXML XML
	declare @ParseProcessTime INT

	EXEC [Search.].[ParseSearchString]	@SearchString = @SearchString,
										@NumberOfPhrases = @NumberOfPhrases OUTPUT,
										@CombinedSearchString = @CombinedSearchString OUTPUT,
										@SearchString1 = @SearchString1 OUTPUT,
										@SearchString2 = @SearchString2 OUTPUT,
										@SearchString3 = @SearchString3 OUTPUT,
										@SearchPhraseXML = @SearchPhraseXML OUTPUT,
										@SearchPhraseFormsXML = @SearchPhraseFormsXML OUTPUT,
										@ProcessTime = @ParseProcessTime OUTPUT

	declare @PhraseList table (PhraseID int, Phrase varchar(max), ThesaurusMatch bit, Forms varchar(max))
	insert into @PhraseList (PhraseID, Phrase, ThesaurusMatch, Forms)
	select	x.value('@ID','INT'),
			x.value('.','VARCHAR(MAX)'),
			x.value('@ThesaurusMatch','BIT'),
			x.value('@Forms','VARCHAR(MAX)')
		from @SearchPhraseFormsXML.nodes('//SearchPhrase') as p(x)

	--SELECT @NumberOfPhrases, @CombinedSearchString, @SearchPhraseXML, @SearchPhraseFormsXML, @ParseProcessTime
	--SELECT * FROM @PhraseList
	--select datediff(ms,@d,GetDate())
--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'parse search string', datediff(ms,@d,GetDate()), @CombinedSearchString
select @d = GetDate()

	-------------------------------------------------------
	-- Parse search filters
	-------------------------------------------------------

	create table #SearchFilters (
		SearchFilterID int identity(0,1) primary key,
		IsExclude bit,
		PropertyURI varchar(400),
		PropertyURI2 varchar(400),
		MatchType varchar(100),
		Value varchar(750),
		Predicate bigint,
		Predicate2 bigint
	)
	
	insert into #SearchFilters (IsExclude, PropertyURI, PropertyURI2, MatchType, Value, Predicate, Predicate2)	
		select t.IsExclude, t.PropertyURI, t.PropertyURI2, t.MatchType, t.Value,
				--left(t.Value,750)+(case when t.MatchType='Left' then '%' else '' end),
				t.Predicate, t.Predicate2
			from (
				select IsNull(IsExclude,0) IsExclude, PropertyURI, PropertyURI2, MatchType, Value,
					[RDF.].fnURI2NodeID(PropertyURI) Predicate,
					[RDF.].fnURI2NodeID(PropertyURI2) Predicate2
				from (
					select distinct S.x.value('@IsExclude','bit') IsExclude,
							S.x.value('@Property','varchar(400)') PropertyURI,
							S.x.value('@Property2','varchar(400)') PropertyURI2,
							S.x.value('@MatchType','varchar(100)') MatchType,
							--S.x.value('.','nvarchar(max)') Value
							(case when cast(S.x.query('./*') as nvarchar(max)) <> '' then cast(S.x.query('./*') as nvarchar(max)) else S.x.value('.','nvarchar(max)') end) Value
					from @SearchFiltersXML.nodes('//SearchFilter') as S(x)
				) t
			) t
			where t.Value IS NOT NULL and t.Value <> ''
			
	declare @NumberOfIncludeFilters int
	select @NumberOfIncludeFilters = IsNull((select count(*) from #SearchFilters where IsExclude=0),0)

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'parse search filters', datediff(ms,@d,GetDate()), cast(@NumberOfIncludeFilters as varchar(max))
select @d = GetDate()

	-------------------------------------------------------
	-- Parse sort by options
	-------------------------------------------------------

	create table #SortBy (
		SortByID int identity(1,1) primary key,
		IsDesc bit,
		PropertyURI varchar(400),
		PropertyURI2 varchar(400),
		PropertyURI3 varchar(400),
		Predicate bigint,
		Predicate2 bigint,
		Predicate3 bigint
	)
	
	insert into #SortBy (IsDesc, PropertyURI, PropertyURI2, PropertyURI3, Predicate, Predicate2, Predicate3)	
		select IsNull(IsDesc,0), PropertyURI, PropertyURI2, PropertyURI3,
				[RDF.].fnURI2NodeID(PropertyURI) Predicate,
				[RDF.].fnURI2NodeID(PropertyURI2) Predicate2,
				[RDF.].fnURI2NodeID(PropertyURI3) Predicate3
			from (
				select S.x.value('@IsDesc','bit') IsDesc,
						S.x.value('@Property','varchar(400)') PropertyURI,
						S.x.value('@Property2','varchar(400)') PropertyURI2,
						S.x.value('@Property3','varchar(400)') PropertyURI3
				from @SortByXML.nodes('//SortBy') as S(x)
			) t

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'parse sort by options', datediff(ms,@d,GetDate()), null
select @d = GetDate()
	-------------------------------------------------------
	-- Get initial list of matching nodes (before filters)
	-------------------------------------------------------

	create table #FullNodeMatch (
		NodeID bigint not null,
		Paths bigint,
		Weight float
	)

	if @CombinedSearchString <> ''
	begin

select @dd=GetDate()

		-- Get nodes that match separate phrases
		create table #PhraseNodeMatch (
			PhraseID int not null,
			NodeID bigint not null,
			Paths bigint,
			Weight float
		)
		if (@NumberOfPhrases > 1) and (@DoExpandedSearch = 1)
		begin
			declare @PhraseSearchString varchar(8000)
			declare @loop int
			select @loop = 1
			while @loop <= @NumberOfPhrases
			begin
				select @PhraseSearchString = Forms
					from @PhraseList
					where PhraseID = @loop
				select * into #NodeRankTemp from containstable ([RDF.].[vwLiteral], value, @PhraseSearchString, 100000)
				alter table #NodeRankTemp add primary key ([Key])
				insert into #PhraseNodeMatch (PhraseID, NodeID, Paths, Weight)
					select @loop, s.NodeID, count(*) Paths, 1-exp(sum(log(case when s.Weight*(m.[Rank]*0.000999+0.001) > 0.999999 then 0.000001 else 1-s.Weight*(m.[Rank]*0.000999+0.001) end))) Weight
						from #NodeRankTemp m
							inner loop join [Search.Cache].[Public.NodeMap] s
								on s.MatchedByNodeID = m.[Key]
						group by s.NodeID
				drop table #NodeRankTemp
				select @loop = @loop + 1
			end
			--create clustered index idx_n on #PhraseNodeMatch(NodeID)
		end

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'initial list (PhraseMatch)', datediff(ms,@dd,GetDate()), cast(@NumberOfPhrases as varchar(50))
select @dd = GetDate()

		-- Get nodes that match the combined search string
		create table #TempMatchNodes (
			NodeID bigint,
			MatchedByNodeID bigint,
			Distance int,
			Paths int,
			Weight float,
			mWeight float
		)
		-- Run each search string
		if @SearchString1 <> ''
				select * into #CombinedSearch1 from containstable ([RDF.].[vwLiteral], value, @SearchString1, 100000) t
		if @SearchString2 <> ''
				select * into #CombinedSearch2 from containstable ([RDF.].[vwLiteral], value, @SearchString2, 100000) t
		if @SearchString3 <> ''
				select * into #CombinedSearch3 from containstable ([RDF.].[vwLiteral], value, @SearchString3, 100000) t
		-- Combine each search string
		create table #CombinedSearch ([key] bigint primary key, [rank] int)
		if IsNull(@SearchString1,'') <> '' and IsNull(@SearchString2,'') = '' and IsNull(@SearchString3,'') = ''
			insert into #CombinedSearch select [key], max([rank]) [rank] from #CombinedSearch1 t group by [key]
		if IsNull(@SearchString1,'') <> '' and IsNull(@SearchString2,'') <> '' and IsNull(@SearchString3,'') = ''
			insert into #CombinedSearch select [key], max([rank]) [rank] from (select * from #CombinedSearch1 union all select * from #CombinedSearch2) t group by [key]
		if IsNull(@SearchString1,'') <> '' and IsNull(@SearchString2,'') <> '' and IsNull(@SearchString3,'') <> ''
			insert into #CombinedSearch select [key], max([rank]) [rank] from (select * from #CombinedSearch1 union all select * from #CombinedSearch2 union all select * from #CombinedSearch3) t group by [key]
		-- Get the TempMatchNodes
		insert into #TempMatchNodes (NodeID, MatchedByNodeID, Distance, Paths, Weight, mWeight)
			select s.*, m.[Rank]*0.000999+0.001 mWeight
				from #CombinedSearch m
					inner loop join [Search.Cache].[Public.NodeMap] s
						on s.MatchedByNodeID = m.[key]
--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'initial list (TempMatch Contains)', datediff(ms,@dd,GetDate()), cast(@@ROWCOUNT as varchar(50)) + ': ' + @CombinedSearchString
		-- Delete temp tables
		if @SearchString1 <> ''
				drop table #CombinedSearch1
		if @SearchString2 <> ''
				drop table #CombinedSearch2
		if @SearchString3 <> ''
				drop table #CombinedSearch3
		drop table #CombinedSearch


--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'initial list (TempMatch)', datediff(ms,@dd,GetDate()), @CombinedSearchString
select @dd = GetDate()

		-- Get nodes that match either all phrases or the combined search string
		insert into #FullNodeMatch (NodeID, Paths, Weight)
			select IsNull(a.NodeID,b.NodeID) NodeID, IsNull(a.Paths,b.Paths) Paths,
					(case when a.weight is null or b.weight is null then IsNull(a.Weight,b.Weight) else 1-(1-a.Weight)*(1-b.Weight) end) Weight
				from (
					select NodeID, exp(sum(log(Paths))) Paths, exp(sum(log(Weight))) Weight
						from #PhraseNodeMatch
						group by NodeID
						having count(*) = @NumberOfPhrases
				) a full outer join (
					select NodeID, count(*) Paths, 1-exp(sum(log(case when Weight*mWeight > 0.999999 then 0.000001 else 1-Weight*mWeight end))) Weight
						from #TempMatchNodes
						group by NodeID
				) b on a.NodeID = b.NodeID
		--select 'Text Matches Found', datediff(ms,@d,getdate())

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'initial list (FullMatch)', datediff(ms,@dd,GetDate()), cast(@@ROWCOUNT as varchar(50))
select @dd = GetDate()

	end
	else if (@NumberOfIncludeFilters > 0)
	begin
		insert into #FullNodeMatch (NodeID, Paths, Weight)
			select t1.Subject, 1, 1
				from #SearchFilters f
					inner join [RDF.].Triple t1
						on f.Predicate is not null
							and t1.Predicate = f.Predicate 
							and t1.ViewSecurityGroup = -1
					left outer join [Search.Cache].[Public.NodePrefix] n1
						on n1.NodeID = t1.Object
					left outer join [RDF.].Triple t2
						on f.Predicate2 is not null
							and t2.Subject = n1.NodeID
							and t2.Predicate = f.Predicate2
							and t2.ViewSecurityGroup = -1
					left outer join [Search.Cache].[Public.NodePrefix] n2
						on n2.NodeID = t2.Object
				where f.IsExclude = 0
					and 1 = (case	when (f.Predicate2 is not null) then
										(case	when f.MatchType = 'Left' then
													(case when n2.Prefix like f.Value+'%' then 1 else 0 end)
												when f.MatchType = 'In' then
													(case when n2.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
												else
													(case when n2.Prefix = f.Value then 1 else 0 end)
												end)
									else
										(case	when f.MatchType = 'Left' then
													(case when n1.Prefix like f.Value+'%' then 1 else 0 end)
												when f.MatchType = 'In' then
													(case when n1.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
												else
													(case when n1.Prefix = f.Value then 1 else 0 end)
												end)
									end)
					--and (case when f.Predicate2 is not null then n2.Prefix else n1.Prefix end)
					--	like f.Value
				group by t1.Subject
				having count(distinct f.SearchFilterID) = @NumberOfIncludeFilters
		delete from #SearchFilters where IsExclude = 0
		select @NumberOfIncludeFilters = 0
	end
	else if (IsNull(@ClassGroupURI,'') <> '' or IsNull(@ClassURI,'') <> '')
	begin
		insert into #FullNodeMatch (NodeID, Paths, Weight)
			select distinct n.NodeID, 1, 1
				from [Search.Cache].[Public.NodeClass] n, [Ontology.].ClassGroupClass c
				where n.Class = c._ClassNode
					and ((@ClassGroupURI is null) or (c.ClassGroupURI = @ClassGroupURI))
					and ((@ClassURI is null) or (c.ClassURI = @ClassURI))
		select @ClassGroupURI = null, @ClassURI = null
	end

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'initial list of nodes', datediff(ms,@d,GetDate()), cast(@NumberOfIncludeFilters as varchar(max))
select @d = GetDate()

	-------------------------------------------------------
	-- Run the actual search
	-------------------------------------------------------
	create table #Node (
		SortOrder bigint identity(0,1) primary key,
		NodeID bigint,
		Paths bigint,
		Weight float
	)

	insert into #Node (NodeID, Paths, Weight)
		select s.NodeID, s.Paths, s.Weight
			from #FullNodeMatch s
				inner join [Search.Cache].[Public.NodeSummary] n on
					s.NodeID = n.NodeID
					and ( IsNull(@ClassGroupURI,@ClassURI) is null or s.NodeID in (
							select NodeID
								from [Search.Cache].[Public.NodeClass] x, [Ontology.].ClassGroupClass c
								where x.Class = c._ClassNode
									and c.ClassGroupURI = IsNull(@ClassGroupURI,c.ClassGroupURI)
									and c.ClassURI = IsNull(@ClassURI,c.ClassURI)
						) )
					and ( @NumberOfIncludeFilters =
							(select count(distinct f.SearchFilterID)
								from #SearchFilters f
									inner join [RDF.].Triple t1
										on f.Predicate is not null
											and t1.Subject = s.NodeID
											and t1.Predicate = f.Predicate 
											and t1.ViewSecurityGroup = -1
									left outer join [Search.Cache].[Public.NodePrefix] n1
										on n1.NodeID = t1.Object
									left outer join [RDF.].Triple t2
										on f.Predicate2 is not null
											and t2.Subject = n1.NodeID
											and t2.Predicate = f.Predicate2
											and t2.ViewSecurityGroup = -1
									left outer join [Search.Cache].[Public.NodePrefix] n2
										on n2.NodeID = t2.Object
								where f.IsExclude = 0
									and 1 = (case	when (f.Predicate2 is not null) then
														(case	when f.MatchType = 'Left' then
																	(case when n2.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n2.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n2.Prefix = f.Value then 1 else 0 end)
																end)
													else
														(case	when f.MatchType = 'Left' then
																	(case when n1.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n1.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n1.Prefix = f.Value then 1 else 0 end)
																end)
													end)
									--and (case when f.Predicate2 is not null then n2.Prefix else n1.Prefix end)
									--	like f.Value
							)
						)
					and not exists (
							select *
								from #SearchFilters f
									inner join [RDF.].Triple t1
										on f.Predicate is not null
											and t1.Subject = s.NodeID
											and t1.Predicate = f.Predicate 
											and t1.ViewSecurityGroup = -1
									left outer join [Search.Cache].[Public.NodePrefix] n1
										on n1.NodeID = t1.Object
									left outer join [RDF.].Triple t2
										on f.Predicate2 is not null
											and t2.Subject = n1.NodeID
											and t2.Predicate = f.Predicate2
											and t2.ViewSecurityGroup = -1
									left outer join [Search.Cache].[Public.NodePrefix] n2
										on n2.NodeID = t2.Object
								where f.IsExclude = 1
									and 1 = (case	when (f.Predicate2 is not null) then
														(case	when f.MatchType = 'Left' then
																	(case when n2.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n2.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n2.Prefix = f.Value then 1 else 0 end)
																end)
													else
														(case	when f.MatchType = 'Left' then
																	(case when n1.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n1.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n1.Prefix = f.Value then 1 else 0 end)
																end)
													end)
									--and (case when f.Predicate2 is not null then n2.Prefix else n1.Prefix end)
									--	like f.Value
						)
				outer apply (
					select	max(case when SortByID=1 then AscSortBy else null end) AscSortBy1,
							max(case when SortByID=2 then AscSortBy else null end) AscSortBy2,
							max(case when SortByID=3 then AscSortBy else null end) AscSortBy3,
							max(case when SortByID=1 then DescSortBy else null end) DescSortBy1,
							max(case when SortByID=2 then DescSortBy else null end) DescSortBy2,
							max(case when SortByID=3 then DescSortBy else null end) DescSortBy3
						from (
							select	SortByID,
									(case when f.IsDesc = 1 then null
											when f.Predicate3 is not null then n3.Value
											when f.Predicate2 is not null then n2.Value
											else n1.Value end) AscSortBy,
									(case when f.IsDesc = 0 then null
											when f.Predicate3 is not null then n3.Value
											when f.Predicate2 is not null then n2.Value
											else n1.Value end) DescSortBy
								from #SortBy f
									inner join [RDF.].Triple t1
										on f.Predicate is not null
											and t1.Subject = s.NodeID
											and t1.Predicate = f.Predicate 
											and t1.ViewSecurityGroup = -1
									left outer join [RDF.].Node n1
										on n1.NodeID = t1.Object
											and n1.ViewSecurityGroup = -1
									left outer join [RDF.].Triple t2
										on f.Predicate2 is not null
											and t2.Subject = n1.NodeID
											and t2.Predicate = f.Predicate2
											and t2.ViewSecurityGroup = -1
									left outer join [RDF.].Node n2
										on n2.NodeID = t2.Object
											and n2.ViewSecurityGroup = -1
									left outer join [RDF.].Triple t3
										on f.Predicate3 is not null
											and t3.Subject = n2.NodeID
											and t3.Predicate = f.Predicate3
											and t3.ViewSecurityGroup = -1
									left outer join [RDF.].Node n3
										on n3.NodeID = t3.Object
											and n3.ViewSecurityGroup = -1
							) t
					) o
			order by	(case when o.AscSortBy1 is null then 1 else 0 end),
						o.AscSortBy1,
						(case when o.DescSortBy1 is null then 1 else 0 end),
						o.DescSortBy1 desc,
						(case when o.AscSortBy2 is null then 1 else 0 end),
						o.AscSortBy2,
						(case when o.DescSortBy2 is null then 1 else 0 end),
						o.DescSortBy2 desc,
						(case when o.AscSortBy3 is null then 1 else 0 end),
						o.AscSortBy3,
						(case when o.DescSortBy3 is null then 1 else 0 end),
						o.DescSortBy3 desc,
						s.Weight desc,
						n.ShortLabel,
						n.NodeID

	--select 'Search Nodes Found', datediff(ms,@d,GetDate())

	-------------------------------------------------------
	-- Get network counts
	-------------------------------------------------------

	declare @NumberOfConnections as bigint
	declare @MaxWeight as float
	declare @MinWeight as float

	select @NumberOfConnections = count(*), @MaxWeight = max(Weight), @MinWeight = min(Weight) 
		from #Node

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'run search', datediff(ms,@d,GetDate()), cast(@NumberOfConnections as varchar(max))
select @d = GetDate()


	-------------------------------------------------------
	-- Get matching class groups and classes
	-------------------------------------------------------

	declare @MatchesClassGroups nvarchar(max)

/*
	select c.ClassGroupURI, c.ClassURI, n.NodeID
		into #NodeClass
		from #Node n, [Search.Cache].[Public.NodeClass] s, [Ontology.].ClassGroupClass c
		where n.NodeID = s.NodeID and s.Class = c._ClassNode
*/

	select n.NodeID, s.Class
		into #NodeClassTemp
		from #Node n
			inner join [Search.Cache].[Public.NodeClass] s
				on n.NodeID = s.NodeID
	select c.ClassGroupURI, c.ClassURI, n.NodeID
		into #NodeClass
		from #NodeClassTemp n
			inner join [Ontology.].ClassGroupClass c
				on n.Class = c._ClassNode

	;with a as (
		select ClassGroupURI, count(distinct NodeID) NumberOfNodes
			from #NodeClass s
			group by ClassGroupURI
	), b as (
		select ClassGroupURI, ClassURI, count(distinct NodeID) NumberOfNodes
			from #NodeClass s
			group by ClassGroupURI, ClassURI
	)
	select @MatchesClassGroups = replace(cast((
			select	g.ClassGroupURI "@rdf_.._resource", 
				g._ClassGroupLabel "rdfs_.._label",
				'http://www.w3.org/2001/XMLSchema#int' "prns_.._numberOfConnections/@rdf_.._datatype",
				a.NumberOfNodes "prns_.._numberOfConnections",
				g.SortOrder "prns_.._sortOrder",
				(
					select	c.ClassURI "@rdf_.._resource",
							c._ClassLabel "rdfs_.._label",
							'http://www.w3.org/2001/XMLSchema#int' "prns_.._numberOfConnections/@rdf_.._datatype",
							b.NumberOfNodes "prns_.._numberOfConnections",
							c.SortOrder "prns_.._sortOrder"
						from b, [Ontology.].ClassGroupClass c
						where b.ClassGroupURI = c.ClassGroupURI and b.ClassURI = c.ClassURI
							and c.ClassGroupURI = g.ClassGroupURI
						order by c.SortOrder
						for xml path('prns_.._matchesClass'), type
				)
			from a, [Ontology.].ClassGroup g
			where a.ClassGroupURI = g.ClassGroupURI and g.IsVisible = 1
			order by g.SortOrder
			for xml path('prns_.._matchesClassGroup'), type
		) as nvarchar(max)),'_.._',':')

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'matching class groups', datediff(ms,@d,GetDate()), null
select @d = GetDate()

	-------------------------------------------------------
	-- Get RDF of search results objects
	-------------------------------------------------------

	declare @ObjectNodesRDF nvarchar(max)

	if @NumberOfConnections > 0
	begin
		/*
			-- Alternative methods that uses GetDataRDF to get the RDF
			declare @NodeListXML xml
			select @NodeListXML = (
					select (
							select NodeID "@ID"
							from #Node
							where SortOrder >= IsNull(@offset,0) and SortOrder < IsNull(IsNull(@offset,0)+@limit,SortOrder+1)
							order by SortOrder
							for xml path('Node'), type
							)
					for xml path('NodeList'), type
				)
			exec [RDF.].GetDataRDF @NodeListXML = @NodeListXML, @expand = 1, @showDetails = 0, @returnXML = 0, @dataStr = @ObjectNodesRDF OUTPUT
		*/
		create table #OutputNodes (
			NodeID bigint primary key,
			k int
		)
		insert into #OutputNodes (NodeID,k)
			SELECT DISTINCT  NodeID,0
			from #Node
			where SortOrder >= IsNull(@offset,0) and SortOrder < IsNull(IsNull(@offset,0)+@limit,SortOrder+1)
		declare @k int
		select @k = 0
		while @k < 10
		begin
			insert into #OutputNodes (NodeID,k)
				select distinct e.ExpandNodeID, @k+1
				from #OutputNodes o, [Search.Cache].[Public.NodeExpand] e
				where o.k = @k and o.NodeID = e.NodeID
					and e.ExpandNodeID not in (select NodeID from #OutputNodes)
			if @@ROWCOUNT = 0
				select @k = 10
			else
				select @k = @k + 1
		end
		select @ObjectNodesRDF = replace(replace(cast((
				select r.RDF + ''
				from #OutputNodes n, [Search.Cache].[Public.NodeRDF] r
				where n.NodeID = r.NodeID
				order by n.NodeID
				for xml path(''), type
			) as nvarchar(max)),'_TAGLT_','<'),'_TAGGT_','>')
	end

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'get rdf of nodes', datediff(ms,@d,GetDate()), null
select @d = GetDate()

	-------------------------------------------------------
	-- Form search results RDF
	-------------------------------------------------------

	declare @results nvarchar(max)

	select @results = ''
			+'<rdf:Description rdf:nodeID="SearchResults">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Network" />'
			+'<rdfs:label>Search Results</rdfs:label>'
			+'<prns:numberOfConnections rdf:datatype="http://www.w3.org/2001/XMLSchema#int">'+cast(IsNull(@NumberOfConnections,0) as nvarchar(50))+'</prns:numberOfConnections>'
			+'<prns:offset rdf:datatype="http://www.w3.org/2001/XMLSchema#int"' + IsNull('>'+cast(@offset as nvarchar(50))+'</prns:offset>',' />')
			+'<prns:limit rdf:datatype="http://www.w3.org/2001/XMLSchema#int"' + IsNull('>'+cast(@limit as nvarchar(50))+'</prns:limit>',' />')
			+'<prns:maxWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#float"' + IsNull('>'+cast(@MaxWeight as nvarchar(50))+'</prns:maxWeight>',' />')
			+'<prns:minWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#float"' + IsNull('>'+cast(@MinWeight as nvarchar(50))+'</prns:minWeight>',' />')
			+'<vivo:overview rdf:parseType="Literal">'
			+IsNull(cast(@SearchOptions as nvarchar(max)),'')
			+'<SearchDetails>'+IsNull(cast(@SearchPhraseXML as nvarchar(max)),'')+'</SearchDetails>'
			+IsNull('<prns:matchesClassGroupsList>'+@MatchesClassGroups+'</prns:matchesClassGroupsList>','')
			+'</vivo:overview>'
			+IsNull((select replace(replace(cast((
					select '_TAGLT_prns:hasConnection rdf:nodeID="C'+cast(SortOrder as nvarchar(50))+'" /_TAGGT_'
					from #Node
					where SortOrder >= IsNull(@offset,0) and SortOrder < IsNull(IsNull(@offset,0)+@limit,SortOrder+1)
					order by SortOrder
					for xml path(''), type
				) as nvarchar(max)),'_TAGLT_','<'),'_TAGGT_','>')),'')
			+'</rdf:Description>'
			+IsNull((select replace(replace(cast((
					select ''
						+'_TAGLT_rdf:Description rdf:nodeID="C'+cast(x.SortOrder as nvarchar(50))+'"_TAGGT_'
						+'_TAGLT_prns:connectionWeight_TAGGT_'+cast(x.Weight as nvarchar(50))+'_TAGLT_/prns:connectionWeight_TAGGT_'
						+'_TAGLT_prns:sortOrder_TAGGT_'+cast(x.SortOrder as nvarchar(50))+'_TAGLT_/prns:sortOrder_TAGGT_'
						+'_TAGLT_rdf:object rdf:resource="'+replace(n.Value,'"','')+'"/_TAGGT_'
						+'_TAGLT_rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Connection" /_TAGGT_'
						+'_TAGLT_rdfs:label_TAGGT_'+(case when s.ShortLabel<>'' then ltrim(rtrim(s.ShortLabel)) else 'Untitled' end)+'_TAGLT_/rdfs:label_TAGGT_'
						+IsNull(+'_TAGLT_vivo:overview_TAGGT_'+s.ClassName+'_TAGLT_/vivo:overview_TAGGT_','')
						+'_TAGLT_/rdf:Description_TAGGT_'
					from #Node x, [RDF.].Node n, [Search.Cache].[Public.NodeSummary] s
					where x.SortOrder >= IsNull(@offset,0) and x.SortOrder < IsNull(IsNull(@offset,0)+@limit,x.SortOrder+1)
						and x.NodeID = n.NodeID
						and x.NodeID = s.NodeID
					order by x.SortOrder
					for xml path(''), type
				) as nvarchar(max)),'_TAGLT_','<'),'_TAGGT_','>')),'')
			+IsNull(@ObjectNodesRDF,'')

	declare @x as varchar(max)
	select @x = '<rdf:RDF'
	select @x = @x + ' xmlns:'+Prefix+'="'+URI+'"' 
		from [Ontology.].Namespace
	select @x = @x + ' >' + @results + '</rdf:RDF>'
	select cast(@x as xml) RDF

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'form search rdf', datediff(ms,@d,GetDate()), null
select @d = GetDate()

	-------------------------------------------------------
	-- Log results
	-------------------------------------------------------

	update [Search.].[History.Query]
		set EndDate = GetDate(),
			DurationMS = datediff(ms,StartDate,GetDate()),
			NumberOfConnections = IsNull(@NumberOfConnections,0)
		where SearchHistoryQueryID = @SearchHistoryQueryID
	
	insert into [Search.].[History.Phrase] (SearchHistoryQueryID, PhraseID, ThesaurusMatch, Phrase, EndDate, IsBot, NumberOfConnections)
		select	@SearchHistoryQueryID,
				PhraseID,
				ThesaurusMatch,
				Phrase,
				GetDate(),
				@IsBot,
				IsNull(@NumberOfConnections,0)
			from @PhraseList

--insert into [Search.Cache].[Public.DebugLog] (SearchHistoryQueryID,Step,DurationMS,Notes) select @SearchHistoryQueryID, 'log results', datediff(ms,@d,GetDate()), null
select @d = GetDate()

END
GO
PRINT N'Altering [Search.Cache].[Private.GetNodes]...';


GO
ALTER PROCEDURE [Search.Cache].[Private.GetNodes]
	@SearchOptions XML,
	@SessionID UNIQUEIDENTIFIER=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON;

	/*
	
	EXEC [Search.Cache].[Private.GetNodes] @SearchOptions = '
	<SearchOptions>
		<MatchOptions>
			<SearchString ExactMatch="false">options for "lung cancer" treatment</SearchString>
			<ClassURI>http://xmlns.com/foaf/0.1/Person</ClassURI>
			<SearchFiltersList>
				<SearchFilter Property="http://xmlns.com/foaf/0.1/lastName" MatchType="Left">Smit</SearchFilter>
			</SearchFiltersList>
		</MatchOptions>
		<OutputOptions>
			<Offset>0</Offset>
			<Limit>5</Limit>
			<SortByList>
				<SortBy IsDesc="1" Property="http://xmlns.com/foaf/0.1/firstName" />
				<SortBy IsDesc="0" Property="http://xmlns.com/foaf/0.1/lastName" />
			</SortByList>
		</OutputOptions>	
	</SearchOptions>
	'
		
	*/

	declare @MatchOptions xml
	declare @OutputOptions xml
	declare @SearchString varchar(500)
	declare @ClassGroupURI varchar(400)
	declare @ClassURI varchar(400)
	declare @SearchFiltersXML xml
	declare @offset bigint
	declare @limit bigint
	declare @SortByXML xml
	declare @DoExpandedSearch bit
	
	select	@MatchOptions = @SearchOptions.query('SearchOptions[1]/MatchOptions[1]'),
			@OutputOptions = @SearchOptions.query('SearchOptions[1]/OutputOptions[1]')
	
	select	@SearchString = @MatchOptions.value('MatchOptions[1]/SearchString[1]','varchar(500)'),
			@DoExpandedSearch = (case when @MatchOptions.value('MatchOptions[1]/SearchString[1]/@ExactMatch','varchar(50)') = 'true' then 0 else 1 end),
			@ClassGroupURI = @MatchOptions.value('MatchOptions[1]/ClassGroupURI[1]','varchar(400)'),
			@ClassURI = @MatchOptions.value('MatchOptions[1]/ClassURI[1]','varchar(400)'),
			@SearchFiltersXML = @MatchOptions.query('MatchOptions[1]/SearchFiltersList[1]'),
			@offset = @OutputOptions.value('OutputOptions[1]/Offset[1]','bigint'),
			@limit = @OutputOptions.value('OutputOptions[1]/Limit[1]','bigint'),
			@SortByXML = @OutputOptions.query('OutputOptions[1]/SortByList[1]')

	declare @baseURI nvarchar(400)
	select @baseURI = value from [Framework.].Parameter where ParameterID = 'baseURI'

	declare @d datetime
	select @d = GetDate()
	

	-------------------------------------------------------
	-- Parse search string and convert to fulltext query
	-------------------------------------------------------

	declare @NumberOfPhrases INT
	declare @CombinedSearchString VARCHAR(8000)
	declare @SearchString1 VARCHAR(8000)
	declare @SearchString2 VARCHAR(8000)
	declare @SearchString3 VARCHAR(8000)
	declare @SearchPhraseXML XML
	declare @SearchPhraseFormsXML XML
	declare @ParseProcessTime INT

	EXEC [Search.].[ParseSearchString]	@SearchString = @SearchString,
										@NumberOfPhrases = @NumberOfPhrases OUTPUT,
										@CombinedSearchString = @CombinedSearchString OUTPUT,
										@SearchString1 = @SearchString1 OUTPUT,
										@SearchString2 = @SearchString2 OUTPUT,
										@SearchString3 = @SearchString3 OUTPUT,
										@SearchPhraseXML = @SearchPhraseXML OUTPUT,
										@SearchPhraseFormsXML = @SearchPhraseFormsXML OUTPUT,
										@ProcessTime = @ParseProcessTime OUTPUT

	declare @PhraseList table (PhraseID int, Phrase varchar(max), ThesaurusMatch bit, Forms varchar(max))
	insert into @PhraseList (PhraseID, Phrase, ThesaurusMatch, Forms)
	select	x.value('@ID','INT'),
			x.value('.','VARCHAR(MAX)'),
			x.value('@ThesaurusMatch','BIT'),
			x.value('@Forms','VARCHAR(MAX)')
		from @SearchPhraseFormsXML.nodes('//SearchPhrase') as p(x)

	--SELECT @NumberOfPhrases, @CombinedSearchString, @SearchPhraseXML, @SearchPhraseFormsXML, @ParseProcessTime, @SearchString1, @SearchString2, @SearchString3
	--SELECT * FROM @PhraseList
	--select datediff(ms,@d,GetDate())


	-------------------------------------------------------
	-- Parse search filters
	-------------------------------------------------------

	create table #SearchFilters (
		SearchFilterID int identity(0,1) primary key,
		IsExclude bit,
		PropertyURI varchar(400),
		PropertyURI2 varchar(400),
		MatchType varchar(100),
		Value nvarchar(max),
		Predicate bigint,
		Predicate2 bigint
	)
	
	insert into #SearchFilters (IsExclude, PropertyURI, PropertyURI2, MatchType, Value, Predicate, Predicate2)	
		select t.IsExclude, t.PropertyURI, t.PropertyURI2, t.MatchType, t.Value,
				--left(t.Value,750)+(case when t.MatchType='Left' then '%' else '' end),
				t.Predicate, t.Predicate2
			from (
				select IsNull(IsExclude,0) IsExclude, PropertyURI, PropertyURI2, MatchType, Value,
					[RDF.].fnURI2NodeID(PropertyURI) Predicate,
					[RDF.].fnURI2NodeID(PropertyURI2) Predicate2
				from (
					select distinct S.x.value('@IsExclude','bit') IsExclude,
							S.x.value('@Property','varchar(400)') PropertyURI,
							S.x.value('@Property2','varchar(400)') PropertyURI2,
							S.x.value('@MatchType','varchar(100)') MatchType,
							--S.x.value('.','nvarchar(max)') Value
							--cast(S.x.query('./*') as nvarchar(max)) Value
							(case when cast(S.x.query('./*') as nvarchar(max)) <> '' then cast(S.x.query('./*') as nvarchar(max)) else S.x.value('.','nvarchar(max)') end) Value
					from @SearchFiltersXML.nodes('//SearchFilter') as S(x)
				) t
			) t
			where t.Value IS NOT NULL and t.Value <> ''
			
	declare @NumberOfIncludeFilters int
	select @NumberOfIncludeFilters = IsNull((select count(*) from #SearchFilters where IsExclude=0),0)

	-------------------------------------------------------
	-- SPECIAL CASE FOR CATALYST: Harvard ID
	-------------------------------------------------------

	declare @HarvardID varchar(10)
	declare @HarvardIDFilter int
	select @HarvardID = cast(Value as varchar(10)),
			@HarvardIDFilter = SearchFilterID
		from #SearchFilters
		where PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/catalyst#harvardID' and PropertyURI2 is null
	if (@HarvardID is not null) and (@HarvardID <> '') and (IsNumeric(@HarvardID)=1)
	begin
		-- Make sure the HarvardID is in the MPI table and get the PersonID
		declare @PersonID int
		if not exists (select * from resnav_home.dbo.mpi where HarvardID = @HarvardID and EndDate is null)
		begin
			insert into resnav_home.dbo.mpi (ProfilesUserid, HarvardID, eCommonsLogin, eCommonsUsername, IsActive, StartDate)
				select (select max(ProfilesUserID)+1 from resnav_home.dbo.mpi),
					@HarvardID, '', '', 1, GetDate()
		end
		declare @eCommonsLogin varchar(50)
		select @PersonID = ProfilesUserID, @eCommonsLogin = eCommonsLogin
			from resnav_home.dbo.mpi
			where HarvardID = @HarvardID and EndDate is null
		-- Determine if the PersonID has a node
		declare @PersonNodeID bigint
		select @PersonNodeID = NodeID
			from [RDF.Stage].InternalNodeMap
			where InternalHash = [RDF.].fnValueHash(null,null,'http://xmlns.com/foaf/0.1/Person^^Person^^'+cast(@PersonID as varchar(50)))
		if @PersonNodeID is not null
		begin
			-- Replace HarvardID filter with a PersonID filter
			update #SearchFilters
				set PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#personId',
					Value = cast(@PersonID as varchar(50)),
					Predicate = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#personId')
				where PropertyURI = 'http://profiles.catalyst.harvard.edu/ontology/catalyst#harvardID'
		end
		else
		begin
			-- Return a hard-coded result
			declare @HUresults nvarchar(max)
			select @HUresults = 
				  '<rdf:Description rdf:nodeID="SearchResults">
					<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Network" />
					<rdfs:label>Search Results</rdfs:label>
					<prns:numberOfConnections rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</prns:numberOfConnections>
					<prns:offset rdf:datatype="http://www.w3.org/2001/XMLSchema#int"' + IsNull('>'+cast(@offset as nvarchar(50))+'</prns:offset>',' />') +'
					<prns:limit rdf:datatype="http://www.w3.org/2001/XMLSchema#int"' + IsNull('>'+cast(@limit as nvarchar(50))+'</prns:limit>',' />') +'
					<prns:maxWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#float">1</prns:maxWeight>
					<prns:minWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#float">1</prns:minWeight>
					<vivo:overview rdf:parseType="Literal">
					  '+IsNull(cast(@SearchOptions as nvarchar(max)),'')+'
					  <prns:matchesClassGroupsList>
						<prns:matchesClassGroup rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#ClassGroupPeople">
						  <rdfs:label>People</rdfs:label>
						  <prns:numberOfConnections rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</prns:numberOfConnections>
						  <prns:sortOrder>1</prns:sortOrder>
						  <prns:matchesClass rdf:resource="http://xmlns.com/foaf/0.1/Person">
							<rdfs:label>Person</rdfs:label>
							<prns:numberOfConnections rdf:datatype="http://www.w3.org/2001/XMLSchema#int">1</prns:numberOfConnections>
							<prns:sortOrder>1</prns:sortOrder>
						  </prns:matchesClass>
						</prns:matchesClassGroup>
					  </prns:matchesClassGroupsList>
					</vivo:overview>
					<prns:hasConnection rdf:nodeID="C0" />
				  </rdf:Description>
				  <rdf:Description rdf:nodeID="C0">
					<prns:connectionWeight>1</prns:connectionWeight>
					<prns:sortOrder>0</prns:sortOrder>
					<rdf:object rdf:nodeID="P0" />
					<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Connection" />
					<vivo:overview>Person</vivo:overview>
				  </rdf:Description>
				  <rdf:Description rdf:nodeID="P0">
					<catalyst:eCommonsLogin>' + IsNull(@eCommonsLogin,'') + '</catalyst:eCommonsLogin>
					<prns:personId>' + cast(@PersonID as varchar(50)) + '</prns:personId>
					<rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Agent" />
					<rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Person" />
				  </rdf:Description>'
			declare @HUx as varchar(max)
			select @HUx = '<rdf:RDF'
			select @HUx = @HUx + ' xmlns:'+Prefix+'="'+URI+'"' 
				from [Ontology.].Namespace
			select @HUx = @HUx + ' >' + @HUresults + '</rdf:RDF>'
			select cast(@HUx as xml) RDF
			return
		end
	end

	-------------------------------------------------------
	-- Parse sort by options
	-------------------------------------------------------

	create table #SortBy (
		SortByID int identity(1,1) primary key,
		IsDesc bit,
		PropertyURI varchar(400),
		PropertyURI2 varchar(400),
		PropertyURI3 varchar(400),
		Predicate bigint,
		Predicate2 bigint,
		Predicate3 bigint
	)
	
	insert into #SortBy (IsDesc, PropertyURI, PropertyURI2, PropertyURI3, Predicate, Predicate2, Predicate3)	
		select IsNull(IsDesc,0), PropertyURI, PropertyURI2, PropertyURI3,
				[RDF.].fnURI2NodeID(PropertyURI) Predicate,
				[RDF.].fnURI2NodeID(PropertyURI2) Predicate2,
				[RDF.].fnURI2NodeID(PropertyURI3) Predicate3
			from (
				select S.x.value('@IsDesc','bit') IsDesc,
						S.x.value('@Property','varchar(400)') PropertyURI,
						S.x.value('@Property2','varchar(400)') PropertyURI2,
						S.x.value('@Property3','varchar(400)') PropertyURI3
				from @SortByXML.nodes('//SortBy') as S(x)
			) t

	-------------------------------------------------------
	-- Get initial list of matching nodes (before filters)
	-------------------------------------------------------

	create table #FullNodeMatch (
		NodeID bigint not null,
		Paths bigint,
		Weight float
	)

	if @CombinedSearchString <> ''
	begin

		-- Get nodes that match separate phrases
		create table #PhraseNodeMatch (
			PhraseID int not null,
			NodeID bigint not null,
			Paths bigint,
			Weight float
		)
		if (@NumberOfPhrases > 1) and (@DoExpandedSearch = 1)
		begin
			declare @PhraseSearchString varchar(8000)
			declare @loop int
			select @loop = 1
			while @loop <= @NumberOfPhrases
			begin
				select @PhraseSearchString = Forms
					from @PhraseList
					where PhraseID = @loop
				select * into #NodeRankTemp from containstable ([RDF.].[vwLiteral], value, @PhraseSearchString, 100000)
				alter table #NodeRankTemp add primary key ([Key])
				insert into #PhraseNodeMatch (PhraseID, NodeID, Paths, Weight)
					select @loop, s.NodeID, count(*) Paths, 1-exp(sum(log(case when s.Weight*(m.[Rank]*0.000999+0.001) > 0.999999 then 0.000001 else 1-s.Weight*(m.[Rank]*0.000999+0.001) end))) Weight
						from #NodeRankTemp m
							inner loop join [Search.Cache].[Private.NodeMap] s
								on s.MatchedByNodeID = m.[Key]
						group by s.NodeID
				drop table #NodeRankTemp
				select @loop = @loop + 1
			end
			--create clustered index idx_n on #PhraseNodeMatch(NodeID)
		end

		-- Get nodes that match the combined search string
		create table #TempMatchNodes (
			NodeID bigint,
			MatchedByNodeID bigint,
			Distance int,
			Paths int,
			Weight float,
			mWeight float
		)
		-- Run each search string
		if @SearchString1 <> ''
				select * into #CombinedSearch1 from containstable ([RDF.].[vwLiteral], value, @SearchString1, 100000) t
		if @SearchString2 <> ''
				select * into #CombinedSearch2 from containstable ([RDF.].[vwLiteral], value, @SearchString2, 100000) t
		if @SearchString3 <> ''
				select * into #CombinedSearch3 from containstable ([RDF.].[vwLiteral], value, @SearchString3, 100000) t
		-- Combine each search string
		create table #CombinedSearch ([key] bigint primary key, [rank] int)
		if IsNull(@SearchString1,'') <> '' and IsNull(@SearchString2,'') = '' and IsNull(@SearchString3,'') = ''
			insert into #CombinedSearch select [key], max([rank]) [rank] from #CombinedSearch1 t group by [key]
		if IsNull(@SearchString1,'') <> '' and IsNull(@SearchString2,'') <> '' and IsNull(@SearchString3,'') = ''
			insert into #CombinedSearch select [key], max([rank]) [rank] from (select * from #CombinedSearch1 union all select * from #CombinedSearch2) t group by [key]
		if IsNull(@SearchString1,'') <> '' and IsNull(@SearchString2,'') <> '' and IsNull(@SearchString3,'') <> ''
			insert into #CombinedSearch select [key], max([rank]) [rank] from (select * from #CombinedSearch1 union all select * from #CombinedSearch2 union all select * from #CombinedSearch3) t group by [key]
		-- Get the TempMatchNodes
		insert into #TempMatchNodes (NodeID, MatchedByNodeID, Distance, Paths, Weight, mWeight)
			select s.*, m.[Rank]*0.000999+0.001 mWeight
				from #CombinedSearch m
					inner loop join [Search.Cache].[Private.NodeMap] s
						on s.MatchedByNodeID = m.[key]
		-- Delete temp tables
		if @SearchString1 <> ''
				drop table #CombinedSearch1
		if @SearchString2 <> ''
				drop table #CombinedSearch2
		if @SearchString3 <> ''
				drop table #CombinedSearch3
		drop table #CombinedSearch

		-- Get nodes that match either all phrases or the combined search string
		insert into #FullNodeMatch (NodeID, Paths, Weight)
			select IsNull(a.NodeID,b.NodeID) NodeID, IsNull(a.Paths,b.Paths) Paths,
					(case when a.weight is null or b.weight is null then IsNull(a.Weight,b.Weight) else 1-(1-a.Weight)*(1-b.Weight) end) Weight
				from (
					select NodeID, exp(sum(log(Paths))) Paths, exp(sum(log(Weight))) Weight
						from #PhraseNodeMatch
						group by NodeID
						having count(*) = @NumberOfPhrases
				) a full outer join (
					select NodeID, count(*) Paths, 1-exp(sum(log(case when Weight*mWeight > 0.999999 then 0.000001 else 1-Weight*mWeight end))) Weight
						from #TempMatchNodes
						group by NodeID
				) b on a.NodeID = b.NodeID
		--select 'Text Matches Found', datediff(ms,@d,getdate())
	end
	else if (@NumberOfIncludeFilters > 0)
	begin
		insert into #FullNodeMatch (NodeID, Paths, Weight)
			select t1.Subject, 1, 1
				from #SearchFilters f
					inner join [RDF.].Triple t1
						on f.Predicate is not null
							and t1.Predicate = f.Predicate 
							and t1.ViewSecurityGroup between -30 and -1
					left outer join [Search.Cache].[Private.NodePrefix] n1
						on n1.NodeID = t1.Object
					left outer join [RDF.].Triple t2
						on f.Predicate2 is not null
							and t2.Subject = n1.NodeID
							and t2.Predicate = f.Predicate2
							and t2.ViewSecurityGroup between -30 and -1
					left outer join [Search.Cache].[Private.NodePrefix] n2
						on n2.NodeID = t2.Object
				where f.IsExclude = 0
					and 1 = (case	when (f.Predicate2 is not null) then
										(case	when f.MatchType = 'Left' then
													(case when n2.Prefix like f.Value+'%' then 1 else 0 end)
												when f.MatchType = 'In' then
													(case when n2.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
												else
													(case when n2.Prefix = f.Value then 1 else 0 end)
												end)
									else
										(case	when f.MatchType = 'Left' then
													(case when n1.Prefix like f.Value+'%' then 1 else 0 end)
												when f.MatchType = 'In' then
													(case when n1.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
												else
													(case when n1.Prefix = f.Value then 1 else 0 end)
												end)
									end)
					--and (case when f.Predicate2 is not null then n2.Prefix else n1.Prefix end)
					--	like f.Value
				group by t1.Subject
				having count(distinct f.SearchFilterID) = @NumberOfIncludeFilters
		delete from #SearchFilters where IsExclude = 0
		select @NumberOfIncludeFilters = 0
	end
	else if (IsNull(@ClassGroupURI,'') <> '' or IsNull(@ClassURI,'') <> '')
	begin
		insert into #FullNodeMatch (NodeID, Paths, Weight)
			select distinct n.NodeID, 1, 1
				from [Search.Cache].[Private.NodeClass] n, [Ontology.].ClassGroupClass c
				where n.Class = c._ClassNode
					and ((@ClassGroupURI is null) or (c.ClassGroupURI = @ClassGroupURI))
					and ((@ClassURI is null) or (c.ClassURI = @ClassURI))
		select @ClassGroupURI = null, @ClassURI = null
	end

	-------------------------------------------------------
	-- Run the actual search
	-------------------------------------------------------
	create table #Node (
		SortOrder bigint identity(0,1) primary key,
		NodeID bigint,
		Paths bigint,
		Weight float
	)

	insert into #Node (NodeID, Paths, Weight)
		select s.NodeID, s.Paths, s.Weight
			from #FullNodeMatch s
				inner join [Search.Cache].[Private.NodeSummary] n on
					s.NodeID = n.NodeID
					and ( IsNull(@ClassGroupURI,@ClassURI) is null or s.NodeID in (
							select NodeID
								from [Search.Cache].[Private.NodeClass] x, [Ontology.].ClassGroupClass c
								where x.Class = c._ClassNode
									and c.ClassGroupURI = IsNull(@ClassGroupURI,c.ClassGroupURI)
									and c.ClassURI = IsNull(@ClassURI,c.ClassURI)
						) )
					and ( @NumberOfIncludeFilters =
							(select count(distinct f.SearchFilterID)
								from #SearchFilters f
									inner join [RDF.].Triple t1
										on f.Predicate is not null
											and t1.Subject = s.NodeID
											and t1.Predicate = f.Predicate 
											and t1.ViewSecurityGroup between -30 and -1
									left outer join [Search.Cache].[Private.NodePrefix] n1
										on n1.NodeID = t1.Object
									left outer join [RDF.].Triple t2
										on f.Predicate2 is not null
											and t2.Subject = n1.NodeID
											and t2.Predicate = f.Predicate2
											and t2.ViewSecurityGroup between -30 and -1
									left outer join [Search.Cache].[Private.NodePrefix] n2
										on n2.NodeID = t2.Object
								where f.IsExclude = 0
									and 1 = (case	when (f.Predicate2 is not null) then
														(case	when f.MatchType = 'Left' then
																	(case when n2.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n2.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n2.Prefix = f.Value then 1 else 0 end)
																end)
													else
														(case	when f.MatchType = 'Left' then
																	(case when n1.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n1.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n1.Prefix = f.Value then 1 else 0 end)
																end)
													end)
									--and (case when f.Predicate2 is not null then n2.Prefix else n1.Prefix end)
									--	like f.Value
							)
						)
					and not exists (
							select *
								from #SearchFilters f
									inner join [RDF.].Triple t1
										on f.Predicate is not null
											and t1.Subject = s.NodeID
											and t1.Predicate = f.Predicate 
											and t1.ViewSecurityGroup between -30 and -1
									left outer join [Search.Cache].[Private.NodePrefix] n1
										on n1.NodeID = t1.Object
									left outer join [RDF.].Triple t2
										on f.Predicate2 is not null
											and t2.Subject = n1.NodeID
											and t2.Predicate = f.Predicate2
											and t2.ViewSecurityGroup between -30 and -1
									left outer join [Search.Cache].[Private.NodePrefix] n2
										on n2.NodeID = t2.Object
								where f.IsExclude = 1
									and 1 = (case	when (f.Predicate2 is not null) then
														(case	when f.MatchType = 'Left' then
																	(case when n2.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n2.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n2.Prefix = f.Value then 1 else 0 end)
																end)
													else
														(case	when f.MatchType = 'Left' then
																	(case when n1.Prefix like f.Value+'%' then 1 else 0 end)
																when f.MatchType = 'In' then
																	(case when n1.Prefix in (select r.x.value('.','varchar(max)') v from (select cast(f.Value as xml) x) t cross apply x.nodes('//Item') as r(x)) then 1 else 0 end)
																else
																	(case when n1.Prefix = f.Value then 1 else 0 end)
																end)
													end)
									--and (case when f.Predicate2 is not null then n2.Prefix else n1.Prefix end)
									--	like f.Value
						)
				outer apply (
					select	max(case when SortByID=1 then AscSortBy else null end) AscSortBy1,
							max(case when SortByID=2 then AscSortBy else null end) AscSortBy2,
							max(case when SortByID=3 then AscSortBy else null end) AscSortBy3,
							max(case when SortByID=1 then DescSortBy else null end) DescSortBy1,
							max(case when SortByID=2 then DescSortBy else null end) DescSortBy2,
							max(case when SortByID=3 then DescSortBy else null end) DescSortBy3
						from (
							select	SortByID,
									(case when f.IsDesc = 1 then null
											when f.Predicate3 is not null then n3.Value
											when f.Predicate2 is not null then n2.Value
											else n1.Value end) AscSortBy,
									(case when f.IsDesc = 0 then null
											when f.Predicate3 is not null then n3.Value
											when f.Predicate2 is not null then n2.Value
											else n1.Value end) DescSortBy
								from #SortBy f
									inner join [RDF.].Triple t1
										on f.Predicate is not null
											and t1.Subject = s.NodeID
											and t1.Predicate = f.Predicate 
											and t1.ViewSecurityGroup between -30 and -1
									left outer join [RDF.].Node n1
										on n1.NodeID = t1.Object
											and n1.ViewSecurityGroup between -30 and -1
									left outer join [RDF.].Triple t2
										on f.Predicate2 is not null
											and t2.Subject = n1.NodeID
											and t2.Predicate = f.Predicate2
											and t2.ViewSecurityGroup between -30 and -1
									left outer join [RDF.].Node n2
										on n2.NodeID = t2.Object
											and n2.ViewSecurityGroup between -30 and -1
									left outer join [RDF.].Triple t3
										on f.Predicate3 is not null
											and t3.Subject = n2.NodeID
											and t3.Predicate = f.Predicate3
											and t3.ViewSecurityGroup between -30 and -1
									left outer join [RDF.].Node n3
										on n3.NodeID = t3.Object
											and n3.ViewSecurityGroup between -30 and -1
							) t
					) o
			order by	(case when o.AscSortBy1 is null then 1 else 0 end),
						o.AscSortBy1,
						(case when o.DescSortBy1 is null then 1 else 0 end),
						o.DescSortBy1 desc,
						(case when o.AscSortBy2 is null then 1 else 0 end),
						o.AscSortBy2,
						(case when o.DescSortBy2 is null then 1 else 0 end),
						o.DescSortBy2 desc,
						(case when o.AscSortBy3 is null then 1 else 0 end),
						o.AscSortBy3,
						(case when o.DescSortBy3 is null then 1 else 0 end),
						o.DescSortBy3 desc,
						s.Weight desc,
						n.ShortLabel,
						n.NodeID


	--select 'Search Nodes Found', datediff(ms,@d,GetDate())

	-------------------------------------------------------
	-- Get network counts
	-------------------------------------------------------

	declare @NumberOfConnections as bigint
	declare @MaxWeight as float
	declare @MinWeight as float

	select @NumberOfConnections = count(*), @MaxWeight = max(Weight), @MinWeight = min(Weight) 
		from #Node

	-------------------------------------------------------
	-- Get matching class groups and classes
	-------------------------------------------------------

	declare @MatchesClassGroups nvarchar(max)

	select n.NodeID, s.Class
		into #NodeClassTemp
		from #Node n
			inner join [Search.Cache].[Private.NodeClass] s
				on n.NodeID = s.NodeID
	select c.ClassGroupURI, c.ClassURI, n.NodeID
		into #NodeClass
		from #NodeClassTemp n
			inner join [Ontology.].ClassGroupClass c
				on n.Class = c._ClassNode

	;with a as (
		select ClassGroupURI, count(distinct NodeID) NumberOfNodes
			from #NodeClass s
			group by ClassGroupURI
	), b as (
		select ClassGroupURI, ClassURI, count(distinct NodeID) NumberOfNodes
			from #NodeClass s
			group by ClassGroupURI, ClassURI
	)
	select @MatchesClassGroups = replace(cast((
			select	g.ClassGroupURI "@rdf_.._resource", 
				g._ClassGroupLabel "rdfs_.._label",
				'http://www.w3.org/2001/XMLSchema#int' "prns_.._numberOfConnections/@rdf_.._datatype",
				a.NumberOfNodes "prns_.._numberOfConnections",
				g.SortOrder "prns_.._sortOrder",
				(
					select	c.ClassURI "@rdf_.._resource",
							c._ClassLabel "rdfs_.._label",
							'http://www.w3.org/2001/XMLSchema#int' "prns_.._numberOfConnections/@rdf_.._datatype",
							b.NumberOfNodes "prns_.._numberOfConnections",
							c.SortOrder "prns_.._sortOrder"
						from b, [Ontology.].ClassGroupClass c
						where b.ClassGroupURI = c.ClassGroupURI and b.ClassURI = c.ClassURI
							and c.ClassGroupURI = g.ClassGroupURI
						order by c.SortOrder
						for xml path('prns_.._matchesClass'), type
				)
			from a, [Ontology.].ClassGroup g
			where a.ClassGroupURI = g.ClassGroupURI and g.IsVisible = 1
			order by g.SortOrder
			for xml path('prns_.._matchesClassGroup'), type
		) as nvarchar(max)),'_.._',':')

	-------------------------------------------------------
	-- Get RDF of search results objects
	-------------------------------------------------------

	declare @ObjectNodesRDF nvarchar(max)

	if @NumberOfConnections > 0
	begin
		/*
			-- Alternative methods that uses GetDataRDF to get the RDF
			declare @NodeListXML xml
			select @NodeListXML = (
					select (
							select NodeID "@ID"
							from #Node
							where SortOrder >= IsNull(@offset,0) and SortOrder < IsNull(IsNull(@offset,0)+@limit,SortOrder+1)
							order by SortOrder
							for xml path('Node'), type
							)
					for xml path('NodeList'), type
				)
			exec [RDF.].GetDataRDF @NodeListXML = @NodeListXML, @expand = 1, @showDetails = 0, @returnXML = 0, @dataStr = @ObjectNodesRDF OUTPUT
		*/
		create table #OutputNodes (
			NodeID bigint primary key,
			k int
		)
		insert into #OutputNodes (NodeID,k)
			select DISTINCT NodeID,0
			from #Node
			where SortOrder >= IsNull(@offset,0) and SortOrder < IsNull(IsNull(@offset,0)+@limit,SortOrder+1)
		declare @k int
		select @k = 0
		while @k < 10
		begin
			insert into #OutputNodes (NodeID,k)
				select distinct e.ExpandNodeID, @k+1
				from #OutputNodes o, [Search.Cache].[Private.NodeExpand] e
				where o.k = @k and o.NodeID = e.NodeID
					and e.ExpandNodeID not in (select NodeID from #OutputNodes)
			if @@ROWCOUNT = 0
				select @k = 10
			else
				select @k = @k + 1
		end
		select @ObjectNodesRDF = replace(replace(cast((
				select r.RDF + ''
				from #OutputNodes n, [Search.Cache].[Private.NodeRDF] r
				where n.NodeID = r.NodeID
				order by n.NodeID
				for xml path(''), type
			) as nvarchar(max)),'_TAGLT_','<'),'_TAGGT_','>')
	end


	-------------------------------------------------------
	-- Form search results RDF
	-------------------------------------------------------

	declare @results nvarchar(max)

	select @results = ''
			+'<rdf:Description rdf:nodeID="SearchResults">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Network" />'
			+'<rdfs:label>Search Results</rdfs:label>'
			+'<prns:numberOfConnections rdf:datatype="http://www.w3.org/2001/XMLSchema#int">'+cast(IsNull(@NumberOfConnections,0) as nvarchar(50))+'</prns:numberOfConnections>'
			+'<prns:offset rdf:datatype="http://www.w3.org/2001/XMLSchema#int"' + IsNull('>'+cast(@offset as nvarchar(50))+'</prns:offset>',' />')
			+'<prns:limit rdf:datatype="http://www.w3.org/2001/XMLSchema#int"' + IsNull('>'+cast(@limit as nvarchar(50))+'</prns:limit>',' />')
			+'<prns:maxWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#float"' + IsNull('>'+cast(@MaxWeight as nvarchar(50))+'</prns:maxWeight>',' />')
			+'<prns:minWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#float"' + IsNull('>'+cast(@MinWeight as nvarchar(50))+'</prns:minWeight>',' />')
			+'<vivo:overview rdf:parseType="Literal">'
			+IsNull(cast(@SearchOptions as nvarchar(max)),'')
			+'<SearchDetails>'+IsNull(cast(@SearchPhraseXML as nvarchar(max)),'')+'</SearchDetails>'
			+IsNull('<prns:matchesClassGroupsList>'+@MatchesClassGroups+'</prns:matchesClassGroupsList>','')
			+'</vivo:overview>'
			+IsNull((select replace(replace(cast((
					select '_TAGLT_prns:hasConnection rdf:nodeID="C'+cast(SortOrder as nvarchar(50))+'" /_TAGGT_'
					from #Node
					where SortOrder >= IsNull(@offset,0) and SortOrder < IsNull(IsNull(@offset,0)+@limit,SortOrder+1)
					order by SortOrder
					for xml path(''), type
				) as nvarchar(max)),'_TAGLT_','<'),'_TAGGT_','>')),'')
			+'</rdf:Description>'
			+IsNull((select replace(replace(cast((
					select ''
						+'_TAGLT_rdf:Description rdf:nodeID="C'+cast(x.SortOrder as nvarchar(50))+'"_TAGGT_'
						+'_TAGLT_prns:connectionWeight_TAGGT_'+cast(x.Weight as nvarchar(50))+'_TAGLT_/prns:connectionWeight_TAGGT_'
						+'_TAGLT_prns:sortOrder_TAGGT_'+cast(x.SortOrder as nvarchar(50))+'_TAGLT_/prns:sortOrder_TAGGT_'
						+'_TAGLT_rdf:object rdf:resource="'+replace(n.Value,'"','')+'"/_TAGGT_'
						+'_TAGLT_rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Connection" /_TAGGT_'
						+'_TAGLT_rdfs:label_TAGGT_'+(case when s.ShortLabel<>'' then ltrim(rtrim(s.ShortLabel)) else 'Untitled' end)+'_TAGLT_/rdfs:label_TAGGT_'
						+IsNull(+'_TAGLT_vivo:overview_TAGGT_'+s.ClassName+'_TAGLT_/vivo:overview_TAGGT_','')
						+'_TAGLT_/rdf:Description_TAGGT_'
					from #Node x, [RDF.].Node n, [Search.Cache].[Private.NodeSummary] s
					where x.SortOrder >= IsNull(@offset,0) and x.SortOrder < IsNull(IsNull(@offset,0)+@limit,x.SortOrder+1)
						and x.NodeID = n.NodeID
						and x.NodeID = s.NodeID
					order by x.SortOrder
					for xml path(''), type
				) as nvarchar(max)),'_TAGLT_','<'),'_TAGGT_','>')),'')
			+IsNull(@ObjectNodesRDF,'')

	declare @x as varchar(max)
	select @x = '<rdf:RDF'
	select @x = @x + ' xmlns:'+Prefix+'="'+URI+'"' 
		from [Ontology.].Namespace
	select @x = @x + ' >' + @results + '</rdf:RDF>'
	select cast(@x as xml) RDF


END
GO
PRINT N'Altering [Search.Cache].[History.UpdateTopSearchPhrase]...';


GO
ALTER PROCEDURE [Search.Cache].[History.UpdateTopSearchPhrase]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	CREATE TABLE #TopSearchPhrase (
		TimePeriod CHAR(1) NOT NULL,
		Phrase VARCHAR(100) NOT NULL,
		NumberOfQueries INT
	)

	-- Get top day, week, and month phrases
	
	INSERT INTO #TopSearchPhrase (TimePeriod, Phrase, NumberOfQueries)
		SELECT TOP 10 'd', Phrase, COUNT(*) n
			FROM [Search.].[History.Phrase]
			WHERE NumberOfConnections > 0
				AND LEN(Phrase) >= 4
				AND LEN(Phrase) <= 100
				AND IsBot = 0
				AND EndDate >= DATEADD(DAY,-1,GETDATE())
			GROUP BY Phrase
			HAVING MAX(NumberOfConnections) < 1000
			ORDER BY n DESC

	INSERT INTO #TopSearchPhrase (TimePeriod, Phrase, NumberOfQueries)
		SELECT TOP 10 'w', Phrase, COUNT(*) n
			FROM [Search.].[History.Phrase]
			WHERE NumberOfConnections > 0
				AND LEN(Phrase) >= 4
				AND LEN(Phrase) <= 100
				AND IsBot = 0
				AND EndDate >= DATEADD(WEEK,-1,GETDATE())
			GROUP BY Phrase
			HAVING MAX(NumberOfConnections) < 1000
			ORDER BY n DESC

	INSERT INTO #TopSearchPhrase (TimePeriod, Phrase, NumberOfQueries)
		SELECT TOP 10 'm', Phrase, COUNT(*) n
			FROM [Search.].[History.Phrase]
			WHERE NumberOfConnections > 0
				AND LEN(Phrase) >= 4
				AND LEN(Phrase) <= 100
				AND IsBot = 0
				AND EndDate >= DATEADD(MONTH,-1,GETDATE())
			GROUP BY Phrase
			HAVING MAX(NumberOfConnections) < 1000
			ORDER BY n DESC

	-- Add phrases to try to get to 10 phrases per time period

	DECLARE @n INT
	
	SELECT @n = 10 - (SELECT COUNT(*) FROM #TopSearchPhrase WHERE TimePeriod = 'd')
	IF @n > 0
		INSERT INTO #TopSearchPhrase (TimePeriod, Phrase, NumberOfQueries)
			SELECT TOP(@n) 'd', Phrase, NumberOfQueries
				FROM #TopSearchPhrase
				WHERE TimePeriod = 'w'
					AND Phrase NOT IN (SELECT Phrase FROM #TopSearchPhrase WHERE TimePeriod = 'd')
				ORDER BY NumberOfQueries DESC

	SELECT @n = 10 - (SELECT COUNT(*) FROM #TopSearchPhrase WHERE TimePeriod = 'd')
	IF @n > 0
		INSERT INTO #TopSearchPhrase (TimePeriod, Phrase, NumberOfQueries)
			SELECT TOP(@n) 'd', Phrase, NumberOfQueries
				FROM #TopSearchPhrase
				WHERE TimePeriod = 'm'
					AND Phrase NOT IN (SELECT Phrase FROM #TopSearchPhrase WHERE TimePeriod = 'd')
				ORDER BY NumberOfQueries DESC

	SELECT @n = 10 - (SELECT COUNT(*) FROM #TopSearchPhrase WHERE TimePeriod = 'w')
	IF @n > 0
		INSERT INTO #TopSearchPhrase (TimePeriod, Phrase, NumberOfQueries)
			SELECT TOP(@n) 'w', Phrase, NumberOfQueries
				FROM #TopSearchPhrase
				WHERE TimePeriod = 'm'
					AND Phrase NOT IN (SELECT Phrase FROM #TopSearchPhrase WHERE TimePeriod = 'w')
				ORDER BY NumberOfQueries DESC

	-- Update the cache table

	TRUNCATE TABLE [Search.Cache].[History.TopSearchPhrase]
	INSERT INTO [Search.Cache].[History.TopSearchPhrase] (TimePeriod, Phrase, NumberOfQueries)
		SELECT TimePeriod, Phrase, NumberOfQueries 
			FROM #TopSearchPhrase

	--DROP TABLE #TopSearchPhrase
	--SELECT * FROM [Search.Cache].[History.TopSearchPhrase]
	
END
GO
PRINT N'Altering [User.Session].[UpdateSession]...';


GO
ALTER PROCEDURE [User.Session].[UpdateSession]
	@SessionID UNIQUEIDENTIFIER, 
	@UserID INT=NULL, 
	@LastUsedDate DATETIME=NULL, 
	@LogoutDate DATETIME=NULL,
	@SessionPersonNodeID BIGINT = NULL OUTPUT,
	@SessionPersonURI VARCHAR(400) = NULL OUTPUT,
	@UserURI VARCHAR(400) = NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- See if there is a PersonID associated with this session	
	DECLARE @PersonID INT
	SELECT @PersonID = PersonID
		FROM [User.Session].[Session]
		WHERE SessionID = @SessionID
	IF @PersonID IS NULL AND @UserID IS NOT NULL
		SELECT @PersonID = PersonID
			FROM [User.Account].[User]
			WHERE UserID = @UserID

	-- Get the NodeID and URI of the PersonID
	IF @PersonID IS NOT NULL
	BEGIN
		SELECT @SessionPersonNodeID = m.NodeID, @SessionPersonURI = p.Value + CAST(m.NodeID AS VARCHAR(50))
			FROM [RDF.Stage].InternalNodeMap m, [Framework.].[Parameter] p
			WHERE m.InternalID = @PersonID
				AND m.InternalType = 'person'
				AND m.Class = 'http://xmlns.com/foaf/0.1/Person'
				AND p.ParameterID = 'baseURI'
	END

	-- Update the session data
    IF EXISTS (SELECT * FROM [User.Session].[Session] WHERE SessionID = @SessionID)
		UPDATE [User.Session].[Session]
			SET	UserID = IsNull(@UserID,UserID),
				UserNode = IsNull((SELECT NodeID FROM [User.Account].[User] WHERE UserID = @UserID AND @UserID IS NOT NULL),UserNode),
				PersonID = IsNull(@PersonID,PersonID),
				LastUsedDate = IsNull(@LastUsedDate,LastUsedDate),
				LogoutDate = IsNull(@LogoutDate,LogoutDate)
			WHERE SessionID = @SessionID

	IF @UserID IS NOT NULL
	BEGIN
		SELECT @UserURI = p.Value + CAST(m.NodeID AS VARCHAR(50))
			FROM [RDF.Stage].InternalNodeMap m, [Framework.].[Parameter] p
			WHERE m.InternalID = @UserID
				AND m.InternalType = 'User'
				AND m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
				AND p.ParameterID = 'baseURI'
	END

END
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessageGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonMessageGet]
 
    @PersonMessageID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonMessage].[PersonMessageID]
        , [ORCID.].[PersonMessage].[PersonID]
        , [ORCID.].[PersonMessage].[XML_Sent]
        , [ORCID.].[PersonMessage].[XML_Response]
        , [ORCID.].[PersonMessage].[ErrorMessage]
        , [ORCID.].[PersonMessage].[HttpResponseCode]
        , [ORCID.].[PersonMessage].[MessagePostSuccess]
        , [ORCID.].[PersonMessage].[RecordStatusID]
        , [ORCID.].[PersonMessage].[PermissionID]
        , [ORCID.].[PersonMessage].[RequestURL]
        , [ORCID.].[PersonMessage].[HeaderPost]
        , [ORCID.].[PersonMessage].[UserMessage]
        , [ORCID.].[PersonMessage].[PostDate]
    FROM
        [ORCID.].[PersonMessage]
    WHERE
        [ORCID.].[PersonMessage].[PersonMessageID] = @PersonMessageID
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessageGetByPersonID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonMessageGetByPersonID]
 
    @PersonID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonMessage].[PersonMessageID]
        , [ORCID.].[PersonMessage].[PersonID]
        , [ORCID.].[PersonMessage].[XML_Sent]
        , [ORCID.].[PersonMessage].[XML_Response]
        , [ORCID.].[PersonMessage].[ErrorMessage]
        , [ORCID.].[PersonMessage].[HttpResponseCode]
        , [ORCID.].[PersonMessage].[MessagePostSuccess]
        , [ORCID.].[PersonMessage].[RecordStatusID]
        , [ORCID.].[PersonMessage].[PermissionID]
        , [ORCID.].[PersonMessage].[RequestURL]
        , [ORCID.].[PersonMessage].[HeaderPost]
        , [ORCID.].[PersonMessage].[UserMessage]
        , [ORCID.].[PersonMessage].[PostDate]
    FROM
        [ORCID.].[PersonMessage]
    WHERE
        [ORCID.].[PersonMessage].[PersonID] = @PersonID
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessageGetByPersonIDAndRecordStatusID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonMessageGetByPersonIDAndRecordStatusID]
 
    @PersonID  INT 
    , @RecordStatusID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonMessage].[PersonMessageID]
        , [ORCID.].[PersonMessage].[PersonID]
        , [ORCID.].[PersonMessage].[XML_Sent]
        , [ORCID.].[PersonMessage].[XML_Response]
        , [ORCID.].[PersonMessage].[ErrorMessage]
        , [ORCID.].[PersonMessage].[HttpResponseCode]
        , [ORCID.].[PersonMessage].[MessagePostSuccess]
        , [ORCID.].[PersonMessage].[RecordStatusID]
        , [ORCID.].[PersonMessage].[PermissionID]
        , [ORCID.].[PersonMessage].[RequestURL]
        , [ORCID.].[PersonMessage].[HeaderPost]
        , [ORCID.].[PersonMessage].[UserMessage]
        , [ORCID.].[PersonMessage].[PostDate]
    FROM
        [ORCID.].[PersonMessage]
    WHERE
        [ORCID.].[PersonMessage].[PersonID] = @PersonID
        AND [ORCID.].[PersonMessage].[RecordStatusID] = @RecordStatusID
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessageGetByPersonIDAndRecordStatusIDAndPermissionID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonMessageGetByPersonIDAndRecordStatusIDAndPermissionID]
 
    @PersonID  INT 
    , @RecordStatusID  INT 
    , @PermissionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonMessage].[PersonMessageID]
        , [ORCID.].[PersonMessage].[PersonID]
        , [ORCID.].[PersonMessage].[XML_Sent]
        , [ORCID.].[PersonMessage].[XML_Response]
        , [ORCID.].[PersonMessage].[ErrorMessage]
        , [ORCID.].[PersonMessage].[HttpResponseCode]
        , [ORCID.].[PersonMessage].[MessagePostSuccess]
        , [ORCID.].[PersonMessage].[RecordStatusID]
        , [ORCID.].[PersonMessage].[PermissionID]
        , [ORCID.].[PersonMessage].[RequestURL]
        , [ORCID.].[PersonMessage].[HeaderPost]
        , [ORCID.].[PersonMessage].[UserMessage]
        , [ORCID.].[PersonMessage].[PostDate]
    FROM
        [ORCID.].[PersonMessage]
    WHERE
        [ORCID.].[PersonMessage].[PersonID] = @PersonID
        AND [ORCID.].[PersonMessage].[RecordStatusID] = @RecordStatusID
        AND [ORCID.].[PersonMessage].[PermissionID] = @PermissionID
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessagesGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonMessagesGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonMessage].[PersonMessageID]
        , [ORCID.].[PersonMessage].[PersonID]
        , [ORCID.].[PersonMessage].[XML_Sent]
        , [ORCID.].[PersonMessage].[XML_Response]
        , [ORCID.].[PersonMessage].[ErrorMessage]
        , [ORCID.].[PersonMessage].[HttpResponseCode]
        , [ORCID.].[PersonMessage].[MessagePostSuccess]
        , [ORCID.].[PersonMessage].[RecordStatusID]
        , [ORCID.].[PersonMessage].[PermissionID]
        , [ORCID.].[PersonMessage].[RequestURL]
        , [ORCID.].[PersonMessage].[HeaderPost]
        , [ORCID.].[PersonMessage].[UserMessage]
        , [ORCID.].[PersonMessage].[PostDate]
    FROM
        [ORCID.].[PersonMessage]
GO
PRINT N'Creating [ORCID.].[cg2_PersonOthernameAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonOthernameAdd]

    @PersonOthernameID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @OtherName  NVARCHAR(500) =NULL
    , @PersonMessageID  INT =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3733
 
  
        INSERT INTO [ORCID.].[PersonOthername]
        (
            [PersonID]
            , [OtherName]
            , [PersonMessageID]
        )
        (
            SELECT
            @PersonID
            , @OtherName
            , @PersonMessageID
        )
   
        SET @intReturnVal = @@error
        SET @PersonOthernameID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonOthername record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonOthernameDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonOthernameDelete]
 
    @PersonOthernameID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonOthername] WHERE         [ORCID.].[PersonOthername].[PersonOthernameID] = @PersonOthernameID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonOthername record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonOthernameEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonOthernameEdit]

    @PersonOthernameID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @OtherName  NVARCHAR(500) =NULL
    , @PersonMessageID  INT =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3733
 
  
        UPDATE [ORCID.].[PersonOthername]
        SET
            [PersonID] = @PersonID
            , [OtherName] = @OtherName
            , [PersonMessageID] = @PersonMessageID
        FROM
            [ORCID.].[PersonOthername]
        WHERE
        [ORCID.].[PersonOthername].[PersonOthernameID] = @PersonOthernameID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonOthername record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonOthernameGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonOthernameGet]
 
    @PersonOthernameID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonOthername].[PersonOthernameID]
        , [ORCID.].[PersonOthername].[PersonID]
        , [ORCID.].[PersonOthername].[OtherName]
        , [ORCID.].[PersonOthername].[PersonMessageID]
    FROM
        [ORCID.].[PersonOthername]
    WHERE
        [ORCID.].[PersonOthername].[PersonOthernameID] = @PersonOthernameID
GO
PRINT N'Creating [ORCID.].[cg2_PersonOthernamesGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonOthernamesGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonOthername].[PersonOthernameID]
        , [ORCID.].[PersonOthername].[PersonID]
        , [ORCID.].[PersonOthername].[OtherName]
        , [ORCID.].[PersonOthername].[PersonMessageID]
    FROM
        [ORCID.].[PersonOthername]
GO
PRINT N'Creating [ORCID.].[cg2_PersonsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[Person].[PersonID]
        , [ORCID.].[Person].[InternalUsername]
        , [ORCID.].[Person].[PersonStatusTypeID]
        , [ORCID.].[Person].[CreateUnlessOptOut]
        , [ORCID.].[Person].[ORCID]
        , [ORCID.].[Person].[ORCIDRecorded]
        , [ORCID.].[Person].[FirstName]
        , [ORCID.].[Person].[LastName]
        , [ORCID.].[Person].[PublishedName]
        , [ORCID.].[Person].[EmailDecisionID]
        , [ORCID.].[Person].[EmailAddress]
        , [ORCID.].[Person].[AlternateEmailDecisionID]
        , [ORCID.].[Person].[AgreementAcknowledged]
        , [ORCID.].[Person].[Biography]
        , [ORCID.].[Person].[BiographyDecisionID]
    FROM
        [ORCID.].[Person]
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokenAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonTokenAdd]

    @PersonTokenID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @PermissionID  INT 
    , @AccessToken  VARCHAR(50) 
    , @TokenExpiration  SMALLDATETIME 
    , @RefreshToken  VARCHAR(50) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3595
 
  
        INSERT INTO [ORCID.].[PersonToken]
        (
            [PersonID]
            , [PermissionID]
            , [AccessToken]
            , [TokenExpiration]
            , [RefreshToken]
        )
        (
            SELECT
            @PersonID
            , @PermissionID
            , @AccessToken
            , @TokenExpiration
            , @RefreshToken
        )
   
        SET @intReturnVal = @@error
        SET @PersonTokenID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonToken record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokenDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonTokenDelete]
 
    @PersonTokenID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonToken] WHERE         [ORCID.].[PersonToken].[PersonTokenID] = @PersonTokenID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonToken record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokenEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonTokenEdit]

    @PersonTokenID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @PermissionID  INT 
    , @AccessToken  VARCHAR(50) 
    , @TokenExpiration  SMALLDATETIME 
    , @RefreshToken  VARCHAR(50) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3595
 
  
        UPDATE [ORCID.].[PersonToken]
        SET
            [PersonID] = @PersonID
            , [PermissionID] = @PermissionID
            , [AccessToken] = @AccessToken
            , [TokenExpiration] = @TokenExpiration
            , [RefreshToken] = @RefreshToken
        FROM
            [ORCID.].[PersonToken]
        WHERE
        [ORCID.].[PersonToken].[PersonTokenID] = @PersonTokenID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonToken record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokenGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonTokenGet]
 
    @PersonTokenID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonToken].[PersonTokenID]
        , [ORCID.].[PersonToken].[PersonID]
        , [ORCID.].[PersonToken].[PermissionID]
        , [ORCID.].[PersonToken].[AccessToken]
        , [ORCID.].[PersonToken].[TokenExpiration]
        , [ORCID.].[PersonToken].[RefreshToken]
    FROM
        [ORCID.].[PersonToken]
    WHERE
        [ORCID.].[PersonToken].[PersonTokenID] = @PersonTokenID
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokenGetByPermissionID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonTokenGetByPermissionID]
 
    @PermissionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonToken].[PersonTokenID]
        , [ORCID.].[PersonToken].[PersonID]
        , [ORCID.].[PersonToken].[PermissionID]
        , [ORCID.].[PersonToken].[AccessToken]
        , [ORCID.].[PersonToken].[TokenExpiration]
        , [ORCID.].[PersonToken].[RefreshToken]
    FROM
        [ORCID.].[PersonToken]
    WHERE
        [ORCID.].[PersonToken].[PermissionID] = @PermissionID
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokenGetByPersonID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonTokenGetByPersonID]
 
    @PersonID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonToken].[PersonTokenID]
        , [ORCID.].[PersonToken].[PersonID]
        , [ORCID.].[PersonToken].[PermissionID]
        , [ORCID.].[PersonToken].[AccessToken]
        , [ORCID.].[PersonToken].[TokenExpiration]
        , [ORCID.].[PersonToken].[RefreshToken]
    FROM
        [ORCID.].[PersonToken]
    WHERE
        [ORCID.].[PersonToken].[PersonID] = @PersonID
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokenGetByPersonIDAndPermissionID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonTokenGetByPersonIDAndPermissionID]
 
    @PersonID  INT 
    , @PermissionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonToken].[PersonTokenID]
        , [ORCID.].[PersonToken].[PersonID]
        , [ORCID.].[PersonToken].[PermissionID]
        , [ORCID.].[PersonToken].[AccessToken]
        , [ORCID.].[PersonToken].[TokenExpiration]
        , [ORCID.].[PersonToken].[RefreshToken]
    FROM
        [ORCID.].[PersonToken]
    WHERE
        [ORCID.].[PersonToken].[PersonID] = @PersonID
        AND [ORCID.].[PersonToken].[PermissionID] = @PermissionID
GO
PRINT N'Creating [ORCID.].[cg2_PersonTokensGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonTokensGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonToken].[PersonTokenID]
        , [ORCID.].[PersonToken].[PersonID]
        , [ORCID.].[PersonToken].[PermissionID]
        , [ORCID.].[PersonToken].[AccessToken]
        , [ORCID.].[PersonToken].[TokenExpiration]
        , [ORCID.].[PersonToken].[RefreshToken]
    FROM
        [ORCID.].[PersonToken]
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonURLAdd]

    @PersonURLID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @PersonMessageID  INT =NULL
    , @URLName  VARCHAR(500) =NULL
    , @URL  VARCHAR(2000) 
    , @DecisionID  INT 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3621
 
  
        INSERT INTO [ORCID.].[PersonURL]
        (
            [PersonID]
            , [PersonMessageID]
            , [URLName]
            , [URL]
            , [DecisionID]
        )
        (
            SELECT
            @PersonID
            , @PersonMessageID
            , @URLName
            , @URL
            , @DecisionID
        )
   
        SET @intReturnVal = @@error
        SET @PersonURLID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonURL record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonURLDelete]
 
    @PersonURLID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonURL] WHERE         [ORCID.].[PersonURL].[PersonURLID] = @PersonURLID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonURL record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonURLEdit]

    @PersonURLID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @PersonMessageID  INT =NULL
    , @URLName  VARCHAR(500) =NULL
    , @URL  VARCHAR(2000) 
    , @DecisionID  INT 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3621
 
  
        UPDATE [ORCID.].[PersonURL]
        SET
            [PersonID] = @PersonID
            , [PersonMessageID] = @PersonMessageID
            , [URLName] = @URLName
            , [URL] = @URL
            , [DecisionID] = @DecisionID
        FROM
            [ORCID.].[PersonURL]
        WHERE
        [ORCID.].[PersonURL].[PersonURLID] = @PersonURLID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonURL record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonURLGet]
 
    @PersonURLID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonURL].[PersonURLID]
        , [ORCID.].[PersonURL].[PersonID]
        , [ORCID.].[PersonURL].[PersonMessageID]
        , [ORCID.].[PersonURL].[URLName]
        , [ORCID.].[PersonURL].[URL]
        , [ORCID.].[PersonURL].[DecisionID]
    FROM
        [ORCID.].[PersonURL]
    WHERE
        [ORCID.].[PersonURL].[PersonURLID] = @PersonURLID
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLGetByPersonID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonURLGetByPersonID]
 
    @PersonID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonURL].[PersonURLID]
        , [ORCID.].[PersonURL].[PersonID]
        , [ORCID.].[PersonURL].[PersonMessageID]
        , [ORCID.].[PersonURL].[URLName]
        , [ORCID.].[PersonURL].[URL]
        , [ORCID.].[PersonURL].[DecisionID]
    FROM
        [ORCID.].[PersonURL]
    WHERE
        [ORCID.].[PersonURL].[PersonID] = @PersonID
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLGetByPersonIDAndURL]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonURLGetByPersonIDAndURL]
 
    @PersonID  INT 
    , @URL  VARCHAR(2000) 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonURL].[PersonURLID]
        , [ORCID.].[PersonURL].[PersonID]
        , [ORCID.].[PersonURL].[PersonMessageID]
        , [ORCID.].[PersonURL].[URLName]
        , [ORCID.].[PersonURL].[URL]
        , [ORCID.].[PersonURL].[DecisionID]
    FROM
        [ORCID.].[PersonURL]
    WHERE
        [ORCID.].[PersonURL].[PersonID] = @PersonID
        AND [ORCID.].[PersonURL].[URL] = @URL
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLGetByPersonMessageID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonURLGetByPersonMessageID]
 
    @PersonMessageID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonURL].[PersonURLID]
        , [ORCID.].[PersonURL].[PersonID]
        , [ORCID.].[PersonURL].[PersonMessageID]
        , [ORCID.].[PersonURL].[URLName]
        , [ORCID.].[PersonURL].[URL]
        , [ORCID.].[PersonURL].[DecisionID]
    FROM
        [ORCID.].[PersonURL]
    WHERE
        [ORCID.].[PersonURL].[PersonMessageID] = @PersonMessageID
GO
PRINT N'Creating [ORCID.].[cg2_PersonURLsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonURLsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonURL].[PersonURLID]
        , [ORCID.].[PersonURL].[PersonID]
        , [ORCID.].[PersonURL].[PersonMessageID]
        , [ORCID.].[PersonURL].[URLName]
        , [ORCID.].[PersonURL].[URL]
        , [ORCID.].[PersonURL].[DecisionID]
    FROM
        [ORCID.].[PersonURL]
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonWorkAdd]

    @PersonWorkID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @PersonMessageID  INT =NULL
    , @DecisionID  INT 
    , @WorkTitle  VARCHAR(MAX) 
    , @ShortDescription  VARCHAR(MAX) =NULL
    , @WorkCitation  VARCHAR(MAX) =NULL
    , @WorkType  VARCHAR(500) =NULL
    , @URL  VARCHAR(1000) =NULL
    , @SubTitle  VARCHAR(MAX) =NULL
    , @WorkCitationType  VARCHAR(500) =NULL
    , @PubDate  SMALLDATETIME =NULL
    , @PublicationMediaType  VARCHAR(500) =NULL
    , @PubID  NVARCHAR(50) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3607
 
  
        INSERT INTO [ORCID.].[PersonWork]
        (
            [PersonID]
            , [PersonMessageID]
            , [DecisionID]
            , [WorkTitle]
            , [ShortDescription]
            , [WorkCitation]
            , [WorkType]
            , [URL]
            , [SubTitle]
            , [WorkCitationType]
            , [PubDate]
            , [PublicationMediaType]
            , [PubID]
        )
        (
            SELECT
            @PersonID
            , @PersonMessageID
            , @DecisionID
            , @WorkTitle
            , @ShortDescription
            , @WorkCitation
            , @WorkType
            , @URL
            , @SubTitle
            , @WorkCitationType
            , @PubDate
            , @PublicationMediaType
            , @PubID
        )
   
        SET @intReturnVal = @@error
        SET @PersonWorkID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonWork record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkDelete]
 
    @PersonWorkID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonWork] WHERE         [ORCID.].[PersonWork].[PersonWorkID] = @PersonWorkID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonWork record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonWorkEdit]

    @PersonWorkID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @PersonMessageID  INT =NULL
    , @DecisionID  INT 
    , @WorkTitle  VARCHAR(MAX) 
    , @ShortDescription  VARCHAR(MAX) =NULL
    , @WorkCitation  VARCHAR(MAX) =NULL
    , @WorkType  VARCHAR(500) =NULL
    , @URL  VARCHAR(1000) =NULL
    , @SubTitle  VARCHAR(MAX) =NULL
    , @WorkCitationType  VARCHAR(500) =NULL
    , @PubDate  SMALLDATETIME =NULL
    , @PublicationMediaType  VARCHAR(500) =NULL
    , @PubID  NVARCHAR(50) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3607
 
  
        UPDATE [ORCID.].[PersonWork]
        SET
            [PersonID] = @PersonID
            , [PersonMessageID] = @PersonMessageID
            , [DecisionID] = @DecisionID
            , [WorkTitle] = @WorkTitle
            , [ShortDescription] = @ShortDescription
            , [WorkCitation] = @WorkCitation
            , [WorkType] = @WorkType
            , [URL] = @URL
            , [SubTitle] = @SubTitle
            , [WorkCitationType] = @WorkCitationType
            , [PubDate] = @PubDate
            , [PublicationMediaType] = @PublicationMediaType
            , [PubID] = @PubID
        FROM
            [ORCID.].[PersonWork]
        WHERE
        [ORCID.].[PersonWork].[PersonWorkID] = @PersonWorkID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonWork record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkGet]
 
    @PersonWorkID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWork].[PersonWorkID]
        , [ORCID.].[PersonWork].[PersonID]
        , [ORCID.].[PersonWork].[PersonMessageID]
        , [ORCID.].[PersonWork].[DecisionID]
        , [ORCID.].[PersonWork].[WorkTitle]
        , [ORCID.].[PersonWork].[ShortDescription]
        , [ORCID.].[PersonWork].[WorkCitation]
        , [ORCID.].[PersonWork].[WorkType]
        , [ORCID.].[PersonWork].[URL]
        , [ORCID.].[PersonWork].[SubTitle]
        , [ORCID.].[PersonWork].[WorkCitationType]
        , [ORCID.].[PersonWork].[PubDate]
        , [ORCID.].[PersonWork].[PublicationMediaType]
        , [ORCID.].[PersonWork].[PubID]
    FROM
        [ORCID.].[PersonWork]
    WHERE
        [ORCID.].[PersonWork].[PersonWorkID] = @PersonWorkID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkGetByDecisionID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkGetByDecisionID]
 
    @DecisionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWork].[PersonWorkID]
        , [ORCID.].[PersonWork].[PersonID]
        , [ORCID.].[PersonWork].[PersonMessageID]
        , [ORCID.].[PersonWork].[DecisionID]
        , [ORCID.].[PersonWork].[WorkTitle]
        , [ORCID.].[PersonWork].[ShortDescription]
        , [ORCID.].[PersonWork].[WorkCitation]
        , [ORCID.].[PersonWork].[WorkType]
        , [ORCID.].[PersonWork].[URL]
        , [ORCID.].[PersonWork].[SubTitle]
        , [ORCID.].[PersonWork].[WorkCitationType]
        , [ORCID.].[PersonWork].[PubDate]
        , [ORCID.].[PersonWork].[PublicationMediaType]
        , [ORCID.].[PersonWork].[PubID]
    FROM
        [ORCID.].[PersonWork]
    WHERE
        [ORCID.].[PersonWork].[DecisionID] = @DecisionID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkGetByPersonID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkGetByPersonID]
 
    @PersonID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWork].[PersonWorkID]
        , [ORCID.].[PersonWork].[PersonID]
        , [ORCID.].[PersonWork].[PersonMessageID]
        , [ORCID.].[PersonWork].[DecisionID]
        , [ORCID.].[PersonWork].[WorkTitle]
        , [ORCID.].[PersonWork].[ShortDescription]
        , [ORCID.].[PersonWork].[WorkCitation]
        , [ORCID.].[PersonWork].[WorkType]
        , [ORCID.].[PersonWork].[URL]
        , [ORCID.].[PersonWork].[SubTitle]
        , [ORCID.].[PersonWork].[WorkCitationType]
        , [ORCID.].[PersonWork].[PubDate]
        , [ORCID.].[PersonWork].[PublicationMediaType]
        , [ORCID.].[PersonWork].[PubID]
    FROM
        [ORCID.].[PersonWork]
    WHERE
        [ORCID.].[PersonWork].[PersonID] = @PersonID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkGetByPersonIDAndPubID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkGetByPersonIDAndPubID]
 
    @PersonID  INT 
    , @PubID  NVARCHAR(50) 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWork].[PersonWorkID]
        , [ORCID.].[PersonWork].[PersonID]
        , [ORCID.].[PersonWork].[PersonMessageID]
        , [ORCID.].[PersonWork].[DecisionID]
        , [ORCID.].[PersonWork].[WorkTitle]
        , [ORCID.].[PersonWork].[ShortDescription]
        , [ORCID.].[PersonWork].[WorkCitation]
        , [ORCID.].[PersonWork].[WorkType]
        , [ORCID.].[PersonWork].[URL]
        , [ORCID.].[PersonWork].[SubTitle]
        , [ORCID.].[PersonWork].[WorkCitationType]
        , [ORCID.].[PersonWork].[PubDate]
        , [ORCID.].[PersonWork].[PublicationMediaType]
        , [ORCID.].[PersonWork].[PubID]
    FROM
        [ORCID.].[PersonWork]
    WHERE
        [ORCID.].[PersonWork].[PersonID] = @PersonID
        AND [ORCID.].[PersonWork].[PubID] = @PubID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkGetByPersonMessageID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkGetByPersonMessageID]
 
    @PersonMessageID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWork].[PersonWorkID]
        , [ORCID.].[PersonWork].[PersonID]
        , [ORCID.].[PersonWork].[PersonMessageID]
        , [ORCID.].[PersonWork].[DecisionID]
        , [ORCID.].[PersonWork].[WorkTitle]
        , [ORCID.].[PersonWork].[ShortDescription]
        , [ORCID.].[PersonWork].[WorkCitation]
        , [ORCID.].[PersonWork].[WorkType]
        , [ORCID.].[PersonWork].[URL]
        , [ORCID.].[PersonWork].[SubTitle]
        , [ORCID.].[PersonWork].[WorkCitationType]
        , [ORCID.].[PersonWork].[PubDate]
        , [ORCID.].[PersonWork].[PublicationMediaType]
        , [ORCID.].[PersonWork].[PubID]
    FROM
        [ORCID.].[PersonWork]
    WHERE
        [ORCID.].[PersonWork].[PersonMessageID] = @PersonMessageID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifierAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierAdd]

    @PersonWorkIdentifierID  INT =NULL OUTPUT 
    , @PersonWorkID  INT 
    , @WorkExternalTypeID  INT 
    , @Identifier  VARCHAR(250) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3615
 
  
        INSERT INTO [ORCID.].[PersonWorkIdentifier]
        (
            [PersonWorkID]
            , [WorkExternalTypeID]
            , [Identifier]
        )
        (
            SELECT
            @PersonWorkID
            , @WorkExternalTypeID
            , @Identifier
        )
   
        SET @intReturnVal = @@error
        SET @PersonWorkIdentifierID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonWorkIdentifier record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifierDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierDelete]
 
    @PersonWorkIdentifierID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonWorkIdentifier] WHERE         [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID] = @PersonWorkIdentifierID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonWorkIdentifier record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifierEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierEdit]

    @PersonWorkIdentifierID  INT =NULL OUTPUT 
    , @PersonWorkID  INT 
    , @WorkExternalTypeID  INT 
    , @Identifier  VARCHAR(250) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3615
 
  
        UPDATE [ORCID.].[PersonWorkIdentifier]
        SET
            [PersonWorkID] = @PersonWorkID
            , [WorkExternalTypeID] = @WorkExternalTypeID
            , [Identifier] = @Identifier
        FROM
            [ORCID.].[PersonWorkIdentifier]
        WHERE
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID] = @PersonWorkIdentifierID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonWorkIdentifier record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifierGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierGet]
 
    @PersonWorkIdentifierID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID]
        , [ORCID.].[PersonWorkIdentifier].[PersonWorkID]
        , [ORCID.].[PersonWorkIdentifier].[WorkExternalTypeID]
        , [ORCID.].[PersonWorkIdentifier].[Identifier]
    FROM
        [ORCID.].[PersonWorkIdentifier]
    WHERE
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID] = @PersonWorkIdentifierID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifierGetByPersonWorkID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierGetByPersonWorkID]
 
    @PersonWorkID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID]
        , [ORCID.].[PersonWorkIdentifier].[PersonWorkID]
        , [ORCID.].[PersonWorkIdentifier].[WorkExternalTypeID]
        , [ORCID.].[PersonWorkIdentifier].[Identifier]
    FROM
        [ORCID.].[PersonWorkIdentifier]
    WHERE
        [ORCID.].[PersonWorkIdentifier].[PersonWorkID] = @PersonWorkID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifierGetByPersonWorkIDAndWorkExternalTypeIDAndIdentifier]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierGetByPersonWorkIDAndWorkExternalTypeIDAndIdentifier]
 
    @PersonWorkID  INT 
    , @WorkExternalTypeID  INT 
    , @Identifier  VARCHAR(250) 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID]
        , [ORCID.].[PersonWorkIdentifier].[PersonWorkID]
        , [ORCID.].[PersonWorkIdentifier].[WorkExternalTypeID]
        , [ORCID.].[PersonWorkIdentifier].[Identifier]
    FROM
        [ORCID.].[PersonWorkIdentifier]
    WHERE
        [ORCID.].[PersonWorkIdentifier].[PersonWorkID] = @PersonWorkID
        AND [ORCID.].[PersonWorkIdentifier].[WorkExternalTypeID] = @WorkExternalTypeID
        AND [ORCID.].[PersonWorkIdentifier].[Identifier] = @Identifier
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifierGetByWorkExternalTypeID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifierGetByWorkExternalTypeID]
 
    @WorkExternalTypeID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID]
        , [ORCID.].[PersonWorkIdentifier].[PersonWorkID]
        , [ORCID.].[PersonWorkIdentifier].[WorkExternalTypeID]
        , [ORCID.].[PersonWorkIdentifier].[Identifier]
    FROM
        [ORCID.].[PersonWorkIdentifier]
    WHERE
        [ORCID.].[PersonWorkIdentifier].[WorkExternalTypeID] = @WorkExternalTypeID
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorkIdentifiersGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorkIdentifiersGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWorkIdentifier].[PersonWorkIdentifierID]
        , [ORCID.].[PersonWorkIdentifier].[PersonWorkID]
        , [ORCID.].[PersonWorkIdentifier].[WorkExternalTypeID]
        , [ORCID.].[PersonWorkIdentifier].[Identifier]
    FROM
        [ORCID.].[PersonWorkIdentifier]
GO
PRINT N'Creating [ORCID.].[cg2_PersonWorksGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonWorksGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonWork].[PersonWorkID]
        , [ORCID.].[PersonWork].[PersonID]
        , [ORCID.].[PersonWork].[PersonMessageID]
        , [ORCID.].[PersonWork].[DecisionID]
        , [ORCID.].[PersonWork].[WorkTitle]
        , [ORCID.].[PersonWork].[ShortDescription]
        , [ORCID.].[PersonWork].[WorkCitation]
        , [ORCID.].[PersonWork].[WorkType]
        , [ORCID.].[PersonWork].[URL]
        , [ORCID.].[PersonWork].[SubTitle]
        , [ORCID.].[PersonWork].[WorkCitationType]
        , [ORCID.].[PersonWork].[PubDate]
        , [ORCID.].[PersonWork].[PublicationMediaType]
        , [ORCID.].[PersonWork].[PubID]
    FROM
        [ORCID.].[PersonWork]
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTrailAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTrailAdd]

    @RecordLevelAuditTrailID  BIGINT =NULL OUTPUT 
    , @MetaTableID  INT 
    , @RowIdentifier  BIGINT 
    , @RecordLevelAuditTypeID  INT 
    , @CreatedDate  SMALLDATETIME 
    , @CreatedBy  VARCHAR(10) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
 
  
        INSERT INTO [ORCID.].[RecordLevelAuditTrail]
        (
            [MetaTableID]
            , [RowIdentifier]
            , [RecordLevelAuditTypeID]
            , [CreatedDate]
            , [CreatedBy]
        )
        (
            SELECT
            @MetaTableID
            , @RowIdentifier
            , @RecordLevelAuditTypeID
            , @CreatedDate
            , @CreatedBy
        )
   
        SET @intReturnVal = @@error
        SET @RecordLevelAuditTrailID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the RecordLevelAuditTrail record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTrailDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTrailDelete]
 
    @RecordLevelAuditTrailID  BIGINT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[RecordLevelAuditTrail] WHERE         [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTrailID] = @RecordLevelAuditTrailID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the RecordLevelAuditTrail record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTrailEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTrailEdit]

    @RecordLevelAuditTrailID  BIGINT =NULL OUTPUT 
    , @MetaTableID  INT 
    , @RowIdentifier  BIGINT 
    , @RecordLevelAuditTypeID  INT 
    , @CreatedDate  SMALLDATETIME 
    , @CreatedBy  VARCHAR(10) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
 
  
        UPDATE [ORCID.].[RecordLevelAuditTrail]
        SET
            [MetaTableID] = @MetaTableID
            , [RowIdentifier] = @RowIdentifier
            , [RecordLevelAuditTypeID] = @RecordLevelAuditTypeID
            , [CreatedDate] = @CreatedDate
            , [CreatedBy] = @CreatedBy
        FROM
            [ORCID.].[RecordLevelAuditTrail]
        WHERE
        [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTrailID] = @RecordLevelAuditTrailID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the RecordLevelAuditTrail record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTrailGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTrailGet]
 
    @RecordLevelAuditTrailID  BIGINT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTrailID]
        , [ORCID.].[RecordLevelAuditTrail].[MetaTableID]
        , [ORCID.].[RecordLevelAuditTrail].[RowIdentifier]
        , [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTypeID]
        , [ORCID.].[RecordLevelAuditTrail].[CreatedDate]
        , [ORCID.].[RecordLevelAuditTrail].[CreatedBy]
    FROM
        [ORCID.].[RecordLevelAuditTrail]
    WHERE
        [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTrailID] = @RecordLevelAuditTrailID
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTrailsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTrailsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTrailID]
        , [ORCID.].[RecordLevelAuditTrail].[MetaTableID]
        , [ORCID.].[RecordLevelAuditTrail].[RowIdentifier]
        , [ORCID.].[RecordLevelAuditTrail].[RecordLevelAuditTypeID]
        , [ORCID.].[RecordLevelAuditTrail].[CreatedDate]
        , [ORCID.].[RecordLevelAuditTrail].[CreatedBy]
    FROM
        [ORCID.].[RecordLevelAuditTrail]
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTypeAdd]...';


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
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTypeDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTypeDelete]
 
    @RecordLevelAuditTypeID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[RecordLevelAuditType] WHERE         [ORCID.].[RecordLevelAuditType].[RecordLevelAuditTypeID] = @RecordLevelAuditTypeID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the RecordLevelAuditType record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTypeEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTypeEdit]

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
 
  
        UPDATE [ORCID.].[RecordLevelAuditType]
        SET
            [AuditType] = @AuditType
        FROM
            [ORCID.].[RecordLevelAuditType]
        WHERE
        [ORCID.].[RecordLevelAuditType].[RecordLevelAuditTypeID] = @RecordLevelAuditTypeID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the RecordLevelAuditType record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTypeGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTypeGet]
 
    @RecordLevelAuditTypeID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[RecordLevelAuditType].[RecordLevelAuditTypeID]
        , [ORCID.].[RecordLevelAuditType].[AuditType]
    FROM
        [ORCID.].[RecordLevelAuditType]
    WHERE
        [ORCID.].[RecordLevelAuditType].[RecordLevelAuditTypeID] = @RecordLevelAuditTypeID
GO
PRINT N'Creating [ORCID.].[cg2_RecordLevelAuditTypesGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_RecordLevelAuditTypesGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[RecordLevelAuditType].[RecordLevelAuditTypeID]
        , [ORCID.].[RecordLevelAuditType].[AuditType]
    FROM
        [ORCID.].[RecordLevelAuditType]
GO
PRINT N'Creating [ORCID.].[cg2_REFDecisionAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_REFDecisionAdd]

    @DecisionID  INT =NULL OUTPUT 
    , @DecisionDescription  VARCHAR(150) 
    , @DecisionDescriptionLong  VARCHAR(500) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3730
 
  
        INSERT INTO [ORCID.].[REF_Decision]
        (
            [DecisionDescription]
            , [DecisionDescriptionLong]
        )
        (
            SELECT
            @DecisionDescription
            , @DecisionDescriptionLong
        )
   
        SET @intReturnVal = @@error
        SET @DecisionID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the REF_Decision record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_REFDecisionDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_REFDecisionDelete]
 
    @DecisionID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[REF_Decision] WHERE         [ORCID.].[REF_Decision].[DecisionID] = @DecisionID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the REF_Decision record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_REFDecisionEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_REFDecisionEdit]

    @DecisionID  INT =NULL OUTPUT 
    , @DecisionDescription  VARCHAR(150) 
    , @DecisionDescriptionLong  VARCHAR(500) 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3730
 
  
        UPDATE [ORCID.].[REF_Decision]
        SET
            [DecisionDescription] = @DecisionDescription
            , [DecisionDescriptionLong] = @DecisionDescriptionLong
        FROM
            [ORCID.].[REF_Decision]
        WHERE
        [ORCID.].[REF_Decision].[DecisionID] = @DecisionID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the REF_Decision record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_REFDecisionGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_REFDecisionGet]
 
    @DecisionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[REF_Decision].[DecisionID]
        , [ORCID.].[REF_Decision].[DecisionDescription]
        , [ORCID.].[REF_Decision].[DecisionDescriptionLong]
    FROM
        [ORCID.].[REF_Decision]
    WHERE
        [ORCID.].[REF_Decision].[DecisionID] = @DecisionID
GO
PRINT N'Creating [ORCID.].[cg2_REFDecisionsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_REFDecisionsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[REF_Decision].[DecisionID]
        , [ORCID.].[REF_Decision].[DecisionDescription]
        , [ORCID.].[REF_Decision].[DecisionDescriptionLong]
    FROM
        [ORCID.].[REF_Decision]
GO
PRINT N'Creating [ORCID.].[cg2_REFPermissionAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_REFPermissionAdd]

    @PermissionID  INT =NULL OUTPUT 
    , @PermissionScope  VARCHAR(100) 
    , @PermissionDescription  VARCHAR(500) 
    , @MethodAndRequest  VARCHAR(100) =NULL
    , @SuccessMessage  VARCHAR(1000) =NULL
    , @FailedMessage  VARCHAR(1000) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3722
 
  
        INSERT INTO [ORCID.].[REF_Permission]
        (
            [PermissionScope]
            , [PermissionDescription]
            , [MethodAndRequest]
            , [SuccessMessage]
            , [FailedMessage]
        )
        (
            SELECT
            @PermissionScope
            , @PermissionDescription
            , @MethodAndRequest
            , @SuccessMessage
            , @FailedMessage
        )
   
        SET @intReturnVal = @@error
        SET @PermissionID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the REF_Permission record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_REFPermissionDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_REFPermissionDelete]
 
    @PermissionID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[REF_Permission] WHERE         [ORCID.].[REF_Permission].[PermissionID] = @PermissionID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the REF_Permission record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_REFPermissionEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_REFPermissionEdit]

    @PermissionID  INT =NULL OUTPUT 
    , @PermissionScope  VARCHAR(100) 
    , @PermissionDescription  VARCHAR(500) 
    , @MethodAndRequest  VARCHAR(100) =NULL
    , @SuccessMessage  VARCHAR(1000) =NULL
    , @FailedMessage  VARCHAR(1000) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3722
 
  
        UPDATE [ORCID.].[REF_Permission]
        SET
            [PermissionScope] = @PermissionScope
            , [PermissionDescription] = @PermissionDescription
            , [MethodAndRequest] = @MethodAndRequest
            , [SuccessMessage] = @SuccessMessage
            , [FailedMessage] = @FailedMessage
        FROM
            [ORCID.].[REF_Permission]
        WHERE
        [ORCID.].[REF_Permission].[PermissionID] = @PermissionID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the REF_Permission record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_REFPermissionGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_REFPermissionGet]
 
    @PermissionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[REF_Permission].[PermissionID]
        , [ORCID.].[REF_Permission].[PermissionScope]
        , [ORCID.].[REF_Permission].[PermissionDescription]
        , [ORCID.].[REF_Permission].[MethodAndRequest]
        , [ORCID.].[REF_Permission].[SuccessMessage]
        , [ORCID.].[REF_Permission].[FailedMessage]
    FROM
        [ORCID.].[REF_Permission]
    WHERE
        [ORCID.].[REF_Permission].[PermissionID] = @PermissionID
GO
PRINT N'Creating [ORCID.].[cg2_REFPermissionGetByPermissionScope]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_REFPermissionGetByPermissionScope]
 
    @PermissionScope  VARCHAR(100) 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[REF_Permission].[PermissionID]
        , [ORCID.].[REF_Permission].[PermissionScope]
        , [ORCID.].[REF_Permission].[PermissionDescription]
        , [ORCID.].[REF_Permission].[MethodAndRequest]
        , [ORCID.].[REF_Permission].[SuccessMessage]
        , [ORCID.].[REF_Permission].[FailedMessage]
    FROM
        [ORCID.].[REF_Permission]
    WHERE
        [ORCID.].[REF_Permission].[PermissionScope] = @PermissionScope
GO
PRINT N'Creating [ORCID.].[cg2_REFPermissionsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_REFPermissionsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[REF_Permission].[PermissionID]
        , [ORCID.].[REF_Permission].[PermissionScope]
        , [ORCID.].[REF_Permission].[PermissionDescription]
        , [ORCID.].[REF_Permission].[MethodAndRequest]
        , [ORCID.].[REF_Permission].[SuccessMessage]
        , [ORCID.].[REF_Permission].[FailedMessage]
    FROM
        [ORCID.].[REF_Permission]
GO
PRINT N'Creating [ORCID.].[GetNarrative]...';


GO
  Create PROCEDURE [ORCID.].[GetNarrative]
	@Subject BIGINT -- = 147559
AS
BEGIN

	SELECT TOP (200) 
		[ORCID.].[DefaultORCIDDecisionIDMapping].DefaultORCIDDecisionID, 
		ObjectValue AS Overview
	FROM            
		[RDF.].vwTripleValue LEFT JOIN [ORCID.].[DefaultORCIDDecisionIDMapping] ON [RDF.].vwTripleValue.ViewSecurityGroup = [ORCID.].[DefaultORCIDDecisionIDMapping].SecurityGroupID
	WHERE        
		(Subject = @Subject) 
		AND (PredicateValue = N'http://vivoweb.org/ontology/core#overview')

END
GO
PRINT N'Creating [ORCID.].[GetPublications]...';


GO
Create PROCEDURE [ORCID.].[GetPublications]
	@Subject BIGINT -- = 147559
AS
BEGIN

	DECLARE @AuthorInAuthorship BIGINT -- = 94
	SELECT @AuthorInAuthorship = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship') 

	DECLARE @LinkedInformationResource BIGINT -- = 1535
	SELECT @LinkedInformationResource = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource') 

	DECLARE @InformationResourceReference BIGINT -- = 381
	SELECT @InformationResourceReference = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#informationResourceReference') 

	SELECT TOP (100) PERCENT 
		Triple_1.TripleID, 
		[RDF.].Triple.SortOrder, 
		[RDF.].Triple.ViewSecurityGroup, 
		[RDF.].Node.Value
	FROM            
		[RDF.].Triple 
		INNER JOIN [RDF.].Triple AS Triple_1 ON [RDF.].Triple.Object = Triple_1.Subject 
		INNER JOIN [RDF.].Triple AS Triple_2 ON Triple_1.Object = Triple_2.Subject 
		INNER JOIN [RDF.].Node ON Triple_2.Object = [RDF.].Node.NodeID
	WHERE        
		([RDF.].Triple.Subject = @Subject) 
		AND ([RDF.].Triple.Predicate = @AuthorInAuthorship) 
		AND (Triple_1.Predicate = @LinkedInformationResource) 
		AND  (Triple_2.Predicate = @InformationResourceReference)
	ORDER BY 
		[RDF.].Triple.SortOrder

END
GO
PRINT N'Creating [ORCID.].[PeopleWithoutAnORCID]...';


GO

CREATE PROCEDURE [ORCID.].[PeopleWithoutAnORCID]
 
AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Person].[PersonID]
        , [Profile.Data].[Person].[UserID]
        , [Profile.Data].[Person].[EmailAddr]
        , [Profile.Data].[Person].[FacultyRankID]
        , [Profile.Data].[Person].[InternalUsername]
		, [Profile.Data].[Person.FacultyRank].FacultyRank
		, [Profile.Data].[Person].LastName + ', ' + [Profile.Data].[Person].FirstName AS DisplayName
		, [Profile.Data].[Organization.Institution].InstitutionName
		, [Profile.Data].[Organization.Department].DepartmentName
		, [Profile.Data].[Organization.Division].DivisionName
		, OP.ORCID
    FROM
        [Profile.Data].[Person]
		LEFT JOIN [Profile.Data].[Person.FacultyRank] ON [Profile.Data].[Person].FacultyRankID = [Profile.Data].[Person.FacultyRank].FacultyRankID
		LEFT JOIN [ORCID.].Person OP ON [Profile.Data].[Person].InternalUsername = OP.InternalUsername
		INNER JOIN  [Profile.Data].[Person.Affiliation] 
			ON 
				[Profile.Data].[Person].PersonID = [Profile.Data].[Person.Affiliation].PersonID
				AND [Profile.Data].[Person.Affiliation].IsPrimary = 1
		LEFT JOIN   [Profile.Data].[Organization.Institution] ON [Profile.Data].[Person.Affiliation].InstitutionID = [Profile.Data].[Organization.Institution].InstitutionID
		LEFT JOIN   [Profile.Data].[Organization.Department] ON [Profile.Data].[Person.Affiliation].DepartmentID = [Profile.Data].[Organization.Department].DepartmentID
		LEFT JOIN   [Profile.Data].[Organization.Division] ON [Profile.Data].[Person.Affiliation].DivisionID = [Profile.Data].[Organization.Division].DivisionID
	WHERE 
		NOT ([Profile.Data].[Person].EmailAddr IS NULL)
		AND [Profile.Data].[Person].IsActive = 1
		AND [Profile.Data].[Person].Visible = 1
		AND OP.ORCID IS NULL
	ORDER BY
		[Profile.Data].[Organization.Institution].InstitutionName
		, [Profile.Data].[Organization.Department].DepartmentName
		, [Profile.Data].[Organization.Division].DivisionName
		, [Profile.Data].[Person].LastName 
		, [Profile.Data].[Person].FirstName
GO
PRINT N'Creating [ORCID.].[PeopleWithoutAnORCIDByName]...';


GO
CREATE PROCEDURE [ORCID.].[PeopleWithoutAnORCIDByName]

	@PartialName VARCHAR(100)
 
AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Person].[PersonID]
        , [Profile.Data].[Person].[UserID]
        , [Profile.Data].[Person].[EmailAddr]
        , [Profile.Data].[Person].[FacultyRankID]
        , [Profile.Data].[Person].[InternalUsername]
		, [Profile.Data].[Person.FacultyRank].FacultyRank
		, [Profile.Data].[Person].LastName + ', ' + [Profile.Data].[Person].FirstName AS DisplayName
		, [Profile.Data].[Organization.Institution].InstitutionName
		, [Profile.Data].[Organization.Department].DepartmentName
		, [Profile.Data].[Organization.Division].DivisionName
		, OP.ORCID
    FROM
        [Profile.Data].[Person]
		LEFT JOIN [Profile.Data].[Person.FacultyRank] ON [Profile.Data].[Person].FacultyRankID = [Profile.Data].[Person.FacultyRank].FacultyRankID
		LEFT JOIN [ORCID.].Person OP ON [Profile.Data].[Person].InternalUsername = OP.InternalUsername
		INNER JOIN  [Profile.Data].[Person.Affiliation] 
			ON 
				[Profile.Data].[Person].PersonID = [Profile.Data].[Person.Affiliation].PersonID
				AND [Profile.Data].[Person.Affiliation].IsPrimary = 1
		LEFT JOIN   [Profile.Data].[Organization.Institution] ON [Profile.Data].[Person.Affiliation].InstitutionID = [Profile.Data].[Organization.Institution].InstitutionID
		LEFT JOIN   [Profile.Data].[Organization.Department] ON [Profile.Data].[Person.Affiliation].DepartmentID = [Profile.Data].[Organization.Department].DepartmentID
		LEFT JOIN   [Profile.Data].[Organization.Division] ON [Profile.Data].[Person.Affiliation].DivisionID = [Profile.Data].[Organization.Division].DivisionID
	WHERE 
		NOT ([Profile.Data].[Person].EmailAddr IS NULL)
		AND [Profile.Data].[Person].IsActive = 1
		AND [Profile.Data].[Person].Visible = 1
		AND OP.ORCID IS NULL
		AND 
			(
				[Profile.Data].[Person].LastName + ', ' + [Profile.Data].[Person].FirstName  like '%' + @PartialName + '%'
				OR [Profile.Data].[Person].FirstName + ' ' + [Profile.Data].[Person].LastName  like '%' + @PartialName + '%'
			)
	ORDER BY
		[Profile.Data].[Organization.Institution].InstitutionName
		, [Profile.Data].[Organization.Department].DepartmentName
		, [Profile.Data].[Organization.Division].DivisionName
		, [Profile.Data].[Person].LastName 
		, [Profile.Data].[Person].FirstName
GO
PRINT N'Creating [ORCID.].[AffiliationsForORCID.GetList]...';


GO
create PROCEDURE [ORCID.].[AffiliationsForORCID.GetList]
	@ProfileDataPersonID bigint = NULL
AS
BEGIN
SELECT        TOP (100) PERCENT NULL AS PersonAffiliationID, [Profile.Data].[Person.Affiliation].PersonAffiliationID AS ProfilesID, 2 AS AffiliationTypeID, 
                         NULL AS PersonID, NULL AS PersonMessageID, NULL AS DecisionID, [Profile.Data].[Organization.Department].DepartmentName, 
                         [Profile.Data].[Person.Affiliation].Title AS RoleTitle, NULL AS StartDate, NULL AS EndDate, 
                         [Profile.Data].[Organization.Institution].InstitutionName AS OrganizationName, [Profile.Data].Person.City, 
                         [Profile.Data].Person.State, 'US' as Country, [ORCID.].[Organization.Institution.Disambiguation].DisambiguationID, 
                         [ORCID.].[Organization.Institution.Disambiguation].DisambiguationSource, [Profile.Data].[Person.Affiliation].SortOrder
FROM            [Profile.Data].Person INNER JOIN
                         [Profile.Data].[Person.Affiliation] ON [Profile.Data].Person.PersonID = [Profile.Data].[Person.Affiliation].PersonID INNER JOIN
                         [Profile.Data].[Organization.Institution] ON [Profile.Data].[Person.Affiliation].InstitutionID = [Profile.Data].[Organization.Institution].InstitutionID LEFT OUTER JOIN
                         [Profile.Data].[Organization.Division] ON [Profile.Data].[Person.Affiliation].DivisionID = [Profile.Data].[Organization.Division].DivisionID LEFT OUTER JOIN
                         [Profile.Data].[Organization.Department] ON [Profile.Data].[Person.Affiliation].DepartmentID = [Profile.Data].[Organization.Department].DepartmentID LEFT OUTER JOIN
						 [ORCID.].[Organization.Institution.Disambiguation] ON [Profile.Data].[Person.Affiliation].InstitutionID = [ORCID.].[Organization.Institution.Disambiguation].InstitutionID

WHERE        ([Profile.Data].Person.PersonID = @ProfileDataPersonID)
ORDER BY [Profile.Data].[Person.Affiliation].SortOrder
End
GO
PRINT N'Creating [ORCID.].[AuthorInAuthorshipForORCID.GetList]...';


GO
CREATE PROCEDURE [ORCID.].[AuthorInAuthorshipForORCID.GetList]
    @NodeID bigint = NULL,
    @SessionID uniqueidentifier = NULL
AS
BEGIN

    DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
    EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
    CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
    INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID


    declare @AuthorInAuthorship bigint
    select @AuthorInAuthorship = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship') 
    declare @LinkedInformationResource bigint
    select @LinkedInformationResource = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource') 


    select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
        p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
        year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.mpid prns_mpid, mpg.URL
    from [RDF.].[Triple] t
        inner join [RDF.].[Node] a
            on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
                and t.object = a.NodeID
                and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
                and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
        inner join [RDF.].[Node] i
            on t.object = i.NodeID
                and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
        inner join [RDF.Stage].[InternalNodeMap] m
            on i.NodeID = m.NodeID
        inner join [Profile.Data].[Publication.Entity.Authorship] e
            on m.InternalID = e.EntityID
        inner join [Profile.Data].[Publication.Entity.InformationResource] p
            on e.InformationResourceID = p.EntityID
        left join  [Profile.Data].[Publication.MyPub.General] mpg
            on p.MPID = mpg.MPID
    order by p.EntityDate desc

END
GO
PRINT N'Creating [ORCID.].[cg2_ErrorLogAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_ErrorLogAdd]

    @ErrorLogID  INT =NULL OUTPUT 
    , @InternalUsername  NVARCHAR(11) =NULL
    , @Exception  TEXT 
    , @OccurredOn  SMALLDATETIME 
    , @Processed  BIT 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3732
 
  
        INSERT INTO [ORCID.].[ErrorLog]
        (
            [InternalUsername]
            , [Exception]
            , [OccurredOn]
            , [Processed]
        )
        (
            SELECT
            @InternalUsername
            , @Exception
            , @OccurredOn
            , @Processed
        )
   
        SET @intReturnVal = @@error
        SET @ErrorLogID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the ErrorLog record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_ErrorLogDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_ErrorLogDelete]
 
    @ErrorLogID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[ErrorLog] WHERE         [ORCID.].[ErrorLog].[ErrorLogID] = @ErrorLogID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the ErrorLog record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_ErrorLogEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_ErrorLogEdit]

    @ErrorLogID  INT =NULL OUTPUT 
    , @InternalUsername  NVARCHAR(11) =NULL
    , @Exception  TEXT 
    , @OccurredOn  SMALLDATETIME 
    , @Processed  BIT 

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3732
 
  
        UPDATE [ORCID.].[ErrorLog]
        SET
            [InternalUsername] = @InternalUsername
            , [Exception] = @Exception
            , [OccurredOn] = @OccurredOn
            , [Processed] = @Processed
        FROM
            [ORCID.].[ErrorLog]
        WHERE
        [ORCID.].[ErrorLog].[ErrorLogID] = @ErrorLogID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the ErrorLog record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_ErrorLogGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_ErrorLogGet]
 
    @ErrorLogID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[ErrorLog].[ErrorLogID]
        , [ORCID.].[ErrorLog].[InternalUsername]
        , [ORCID.].[ErrorLog].[Exception]
        , [ORCID.].[ErrorLog].[OccurredOn]
        , [ORCID.].[ErrorLog].[Processed]
    FROM
        [ORCID.].[ErrorLog]
    WHERE
        [ORCID.].[ErrorLog].[ErrorLogID] = @ErrorLogID
GO
PRINT N'Creating [ORCID.].[cg2_ErrorLogsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_ErrorLogsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[ErrorLog].[ErrorLogID]
        , [ORCID.].[ErrorLog].[InternalUsername]
        , [ORCID.].[ErrorLog].[Exception]
        , [ORCID.].[ErrorLog].[OccurredOn]
        , [ORCID.].[ErrorLog].[Processed]
    FROM
        [ORCID.].[ErrorLog]
GO
PRINT N'Creating [ORCID.].[cg2_FieldLevelAuditTrailAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_FieldLevelAuditTrailAdd]

    @FieldLevelAuditTrailID  BIGINT =NULL OUTPUT 
    , @RecordLevelAuditTrailID  BIGINT 
    , @MetaFieldID  INT 
    , @ValueBefore  VARCHAR(50) =NULL
    , @ValueAfter  VARCHAR(50) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
 
  
        INSERT INTO [ORCID.].[FieldLevelAuditTrail]
        (
            [RecordLevelAuditTrailID]
            , [MetaFieldID]
            , [ValueBefore]
            , [ValueAfter]
        )
        (
            SELECT
            @RecordLevelAuditTrailID
            , @MetaFieldID
            , @ValueBefore
            , @ValueAfter
        )
   
        SET @intReturnVal = @@error
        SET @FieldLevelAuditTrailID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the FieldLevelAuditTrail record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_FieldLevelAuditTrailDelete]...';


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
PRINT N'Creating [ORCID.].[cg2_FieldLevelAuditTrailEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_FieldLevelAuditTrailEdit]

    @FieldLevelAuditTrailID  BIGINT =NULL OUTPUT 
    , @RecordLevelAuditTrailID  BIGINT 
    , @MetaFieldID  INT 
    , @ValueBefore  VARCHAR(50) =NULL
    , @ValueAfter  VARCHAR(50) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
 
  
        UPDATE [ORCID.].[FieldLevelAuditTrail]
        SET
            [RecordLevelAuditTrailID] = @RecordLevelAuditTrailID
            , [MetaFieldID] = @MetaFieldID
            , [ValueBefore] = @ValueBefore
            , [ValueAfter] = @ValueAfter
        FROM
            [ORCID.].[FieldLevelAuditTrail]
        WHERE
        [ORCID.].[FieldLevelAuditTrail].[FieldLevelAuditTrailID] = @FieldLevelAuditTrailID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the FieldLevelAuditTrail record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_FieldLevelAuditTrailGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_FieldLevelAuditTrailGet]
 
    @FieldLevelAuditTrailID  BIGINT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[FieldLevelAuditTrail].[FieldLevelAuditTrailID]
        , [ORCID.].[FieldLevelAuditTrail].[RecordLevelAuditTrailID]
        , [ORCID.].[FieldLevelAuditTrail].[MetaFieldID]
        , [ORCID.].[FieldLevelAuditTrail].[ValueBefore]
        , [ORCID.].[FieldLevelAuditTrail].[ValueAfter]
    FROM
        [ORCID.].[FieldLevelAuditTrail]
    WHERE
        [ORCID.].[FieldLevelAuditTrail].[FieldLevelAuditTrailID] = @FieldLevelAuditTrailID
GO
PRINT N'Creating [ORCID.].[cg2_FieldLevelAuditTrailsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_FieldLevelAuditTrailsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[FieldLevelAuditTrail].[FieldLevelAuditTrailID]
        , [ORCID.].[FieldLevelAuditTrail].[RecordLevelAuditTrailID]
        , [ORCID.].[FieldLevelAuditTrail].[MetaFieldID]
        , [ORCID.].[FieldLevelAuditTrail].[ValueBefore]
        , [ORCID.].[FieldLevelAuditTrail].[ValueAfter]
    FROM
        [ORCID.].[FieldLevelAuditTrail]
GO
PRINT N'Creating [ORCID.].[cg2_GroupEdit]...';


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
PRINT N'Creating [ORCID.].[cg2_GroupGet]...';


GO
CREATE PROCEDURE [ORCID.].[cg2_GroupGet]
 
    @SecurityGroupID  BIGINT 

AS
 
    SELECT TOP 100 PERCENT
        [RDF.Security].[Group].[SecurityGroupID]
        , [RDF.Security].[Group].[Label]
        , [RDF.Security].[Group].[HasSpecialViewAccess]
        , [RDF.Security].[Group].[HasSpecialEditAccess]
        , [RDF.Security].[Group].[Description]
        , [ORCID.].[DefaultORCIDDecisionIDMapping].[DefaultORCIDDecisionID]
    FROM
        [RDF.Security].[Group]
		join [ORCID.].[DefaultORCIDDecisionIDMapping]
		on [RDF.Security].[Group].SecurityGroupID = [ORCID.].[DefaultORCIDDecisionIDMapping].SecurityGroupID
    WHERE
        [RDF.Security].[Group].[SecurityGroupID] = @SecurityGroupID
GO
PRINT N'Creating [ORCID.].[cg2_GroupsGet]...';


GO
CREATE PROCEDURE [ORCID.].[cg2_GroupsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [RDF.Security].[Group].[SecurityGroupID]
        , [RDF.Security].[Group].[Label]
        , [RDF.Security].[Group].[HasSpecialViewAccess]
        , [RDF.Security].[Group].[HasSpecialEditAccess]
        , [RDF.Security].[Group].[Description]
        , [ORCID.].[DefaultORCIDDecisionIDMapping].[DefaultORCIDDecisionID]
    FROM
        [RDF.Security].[Group]
		join [ORCID.].[DefaultORCIDDecisionIDMapping]
		on [RDF.Security].[Group].SecurityGroupID = [ORCID.].[DefaultORCIDDecisionIDMapping].SecurityGroupID
GO
PRINT N'Creating [ORCID.].[cg2_OrganizationDepartmentsGet]...';


GO
CREATE PROCEDURE [ORCID.].[cg2_OrganizationDepartmentsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Organization.Department].[DepartmentID]
        , [Profile.Data].[Organization.Department].[DepartmentName]
        , [Profile.Data].[Organization.Department].[Visible]
    FROM
        [Profile.Data].[Organization.Department]
GO
PRINT N'Creating [ORCID.].[cg2_OrganizationDivisionsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_OrganizationDivisionsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Organization.Division].[DivisionID]
        , [Profile.Data].[Organization.Division].[DivisionName]
    FROM
        [Profile.Data].[Organization.Division]
GO
PRINT N'Creating [ORCID.].[cg2_OrganizationInstitutionGet]...';


GO
CREATE PROCEDURE [ORCID.].[cg2_OrganizationInstitutionGet]
 
    @InstitutionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Organization.Institution].[InstitutionID]
        , [Profile.Data].[Organization.Institution].[InstitutionName]
        , [Profile.Data].[Organization.Institution].[InstitutionAbbreviation]
  --      , [Profile.Data].[Organization.Institution].[City]
  --      , [Profile.Data].[Organization.Institution].[State]
  --      , [Profile.Data].[Organization.Institution].[Country]
  --      , [Profile.Data].[Organization.Institution].[RingGoldID]
    FROM
        [Profile.Data].[Organization.Institution]
    WHERE
        [Profile.Data].[Organization.Institution].[InstitutionID] = @InstitutionID
GO
PRINT N'Creating [ORCID.].[cg2_OrganizationInstitutionsGet]...';


GO
CREATE PROCEDURE [ORCID.].[cg2_OrganizationInstitutionsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Organization.Institution].[InstitutionID]
        , [Profile.Data].[Organization.Institution].[InstitutionName]
        , [Profile.Data].[Organization.Institution].[InstitutionAbbreviation]
    FROM
        [Profile.Data].[Organization.Institution]
GO
PRINT N'Creating [ORCID.].[cg2_PersonAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonAdd]

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
 
  
        INSERT INTO [ORCID.].[Person]
        (
            [InternalUsername]
            , [PersonStatusTypeID]
            , [CreateUnlessOptOut]
            , [ORCID]
            , [ORCIDRecorded]
            , [FirstName]
            , [LastName]
            , [PublishedName]
            , [EmailDecisionID]
            , [EmailAddress]
            , [AlternateEmailDecisionID]
            , [AgreementAcknowledged]
            , [Biography]
            , [BiographyDecisionID]
        )
        (
            SELECT
            @InternalUsername
            , @PersonStatusTypeID
            , @CreateUnlessOptOut
            , @ORCID
            , @ORCIDRecorded
            , @FirstName
            , @LastName
            , @PublishedName
            , @EmailDecisionID
            , @EmailAddress
            , @AlternateEmailDecisionID
            , @AgreementAcknowledged
            , @Biography
            , @BiographyDecisionID
        )
   
        SET @intReturnVal = @@error
        SET @PersonID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the Person record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationAdd]

    @PersonAffiliationID  INT =NULL OUTPUT 
    , @ProfilesID  INT 
    , @AffiliationTypeID  INT 
    , @PersonID  INT 
    , @PersonMessageID  INT =NULL
    , @DecisionID  INT 
    , @DepartmentName  VARCHAR(4000) =NULL
    , @RoleTitle  VARCHAR(200) =NULL
    , @StartDate  SMALLDATETIME =NULL
    , @EndDate  SMALLDATETIME =NULL
    , @OrganizationName  VARCHAR(4000) 
    , @OrganizationCity  VARCHAR(4000) =NULL
    , @OrganizationRegion  VARCHAR(2) =NULL
    , @OrganizationCountry  VARCHAR(2) =NULL
    , @DisambiguationID  VARCHAR(500) =NULL
    , @DisambiguationSource  VARCHAR(500) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 4467
 
  
        INSERT INTO [ORCID.].[PersonAffiliation]
        (
            [ProfilesID]
            , [AffiliationTypeID]
            , [PersonID]
            , [PersonMessageID]
            , [DecisionID]
            , [DepartmentName]
            , [RoleTitle]
            , [StartDate]
            , [EndDate]
            , [OrganizationName]
            , [OrganizationCity]
            , [OrganizationRegion]
            , [OrganizationCountry]
            , [DisambiguationID]
            , [DisambiguationSource]
        )
        (
            SELECT
            @ProfilesID
            , @AffiliationTypeID
            , @PersonID
            , @PersonMessageID
            , @DecisionID
            , @DepartmentName
            , @RoleTitle
            , @StartDate
            , @EndDate
            , @OrganizationName
            , @OrganizationCity
            , @OrganizationRegion
            , @OrganizationCountry
            , @DisambiguationID
            , @DisambiguationSource
        )
   
        SET @intReturnVal = @@error
        SET @PersonAffiliationID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonAffiliation record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationDelete]
 
    @PersonAffiliationID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonAffiliation] WHERE         [ORCID.].[PersonAffiliation].[PersonAffiliationID] = @PersonAffiliationID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonAffiliation record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationEdit]

    @PersonAffiliationID  INT =NULL OUTPUT 
    , @ProfilesID  INT 
    , @AffiliationTypeID  INT 
    , @PersonID  INT 
    , @PersonMessageID  INT =NULL
    , @DecisionID  INT 
    , @DepartmentName  VARCHAR(4000) =NULL
    , @RoleTitle  VARCHAR(200) =NULL
    , @StartDate  SMALLDATETIME =NULL
    , @EndDate  SMALLDATETIME =NULL
    , @OrganizationName  VARCHAR(4000) 
    , @OrganizationCity  VARCHAR(4000) =NULL
    , @OrganizationRegion  VARCHAR(2) =NULL
    , @OrganizationCountry  VARCHAR(2) =NULL
    , @DisambiguationID  VARCHAR(500) =NULL
    , @DisambiguationSource  VARCHAR(500) =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 4467
 
  
        UPDATE [ORCID.].[PersonAffiliation]
        SET
            [ProfilesID] = @ProfilesID
            , [AffiliationTypeID] = @AffiliationTypeID
            , [PersonID] = @PersonID
            , [PersonMessageID] = @PersonMessageID
            , [DecisionID] = @DecisionID
            , [DepartmentName] = @DepartmentName
            , [RoleTitle] = @RoleTitle
            , [StartDate] = @StartDate
            , [EndDate] = @EndDate
            , [OrganizationName] = @OrganizationName
            , [OrganizationCity] = @OrganizationCity
            , [OrganizationRegion] = @OrganizationRegion
            , [OrganizationCountry] = @OrganizationCountry
            , [DisambiguationID] = @DisambiguationID
            , [DisambiguationSource] = @DisambiguationSource
        FROM
            [ORCID.].[PersonAffiliation]
        WHERE
        [ORCID.].[PersonAffiliation].[PersonAffiliationID] = @PersonAffiliationID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonAffiliation record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationGet]
 
    @PersonAffiliationID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAffiliation].[PersonAffiliationID]
        , [ORCID.].[PersonAffiliation].[ProfilesID]
        , [ORCID.].[PersonAffiliation].[AffiliationTypeID]
        , [ORCID.].[PersonAffiliation].[PersonID]
        , [ORCID.].[PersonAffiliation].[PersonMessageID]
        , [ORCID.].[PersonAffiliation].[DecisionID]
        , [ORCID.].[PersonAffiliation].[DepartmentName]
        , [ORCID.].[PersonAffiliation].[RoleTitle]
        , [ORCID.].[PersonAffiliation].[StartDate]
        , [ORCID.].[PersonAffiliation].[EndDate]
        , [ORCID.].[PersonAffiliation].[OrganizationName]
        , [ORCID.].[PersonAffiliation].[OrganizationCity]
        , [ORCID.].[PersonAffiliation].[OrganizationRegion]
        , [ORCID.].[PersonAffiliation].[OrganizationCountry]
        , [ORCID.].[PersonAffiliation].[DisambiguationID]
        , [ORCID.].[PersonAffiliation].[DisambiguationSource]
    FROM
        [ORCID.].[PersonAffiliation]
    WHERE
        [ORCID.].[PersonAffiliation].[PersonAffiliationID] = @PersonAffiliationID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationGetByDecisionID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationGetByDecisionID]
 
    @DecisionID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAffiliation].[PersonAffiliationID]
        , [ORCID.].[PersonAffiliation].[ProfilesID]
        , [ORCID.].[PersonAffiliation].[AffiliationTypeID]
        , [ORCID.].[PersonAffiliation].[PersonID]
        , [ORCID.].[PersonAffiliation].[PersonMessageID]
        , [ORCID.].[PersonAffiliation].[DecisionID]
        , [ORCID.].[PersonAffiliation].[DepartmentName]
        , [ORCID.].[PersonAffiliation].[RoleTitle]
        , [ORCID.].[PersonAffiliation].[StartDate]
        , [ORCID.].[PersonAffiliation].[EndDate]
        , [ORCID.].[PersonAffiliation].[OrganizationName]
        , [ORCID.].[PersonAffiliation].[OrganizationCity]
        , [ORCID.].[PersonAffiliation].[OrganizationRegion]
        , [ORCID.].[PersonAffiliation].[OrganizationCountry]
        , [ORCID.].[PersonAffiliation].[DisambiguationID]
        , [ORCID.].[PersonAffiliation].[DisambiguationSource]
    FROM
        [ORCID.].[PersonAffiliation]
    WHERE
        [ORCID.].[PersonAffiliation].[DecisionID] = @DecisionID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationGetByPersonID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationGetByPersonID]
 
    @PersonID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAffiliation].[PersonAffiliationID]
        , [ORCID.].[PersonAffiliation].[ProfilesID]
        , [ORCID.].[PersonAffiliation].[AffiliationTypeID]
        , [ORCID.].[PersonAffiliation].[PersonID]
        , [ORCID.].[PersonAffiliation].[PersonMessageID]
        , [ORCID.].[PersonAffiliation].[DecisionID]
        , [ORCID.].[PersonAffiliation].[DepartmentName]
        , [ORCID.].[PersonAffiliation].[RoleTitle]
        , [ORCID.].[PersonAffiliation].[StartDate]
        , [ORCID.].[PersonAffiliation].[EndDate]
        , [ORCID.].[PersonAffiliation].[OrganizationName]
        , [ORCID.].[PersonAffiliation].[OrganizationCity]
        , [ORCID.].[PersonAffiliation].[OrganizationRegion]
        , [ORCID.].[PersonAffiliation].[OrganizationCountry]
        , [ORCID.].[PersonAffiliation].[DisambiguationID]
        , [ORCID.].[PersonAffiliation].[DisambiguationSource]
    FROM
        [ORCID.].[PersonAffiliation]
    WHERE
        [ORCID.].[PersonAffiliation].[PersonID] = @PersonID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationGetByPersonMessageID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationGetByPersonMessageID]
 
    @PersonMessageID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAffiliation].[PersonAffiliationID]
        , [ORCID.].[PersonAffiliation].[ProfilesID]
        , [ORCID.].[PersonAffiliation].[AffiliationTypeID]
        , [ORCID.].[PersonAffiliation].[PersonID]
        , [ORCID.].[PersonAffiliation].[PersonMessageID]
        , [ORCID.].[PersonAffiliation].[DecisionID]
        , [ORCID.].[PersonAffiliation].[DepartmentName]
        , [ORCID.].[PersonAffiliation].[RoleTitle]
        , [ORCID.].[PersonAffiliation].[StartDate]
        , [ORCID.].[PersonAffiliation].[EndDate]
        , [ORCID.].[PersonAffiliation].[OrganizationName]
        , [ORCID.].[PersonAffiliation].[OrganizationCity]
        , [ORCID.].[PersonAffiliation].[OrganizationRegion]
        , [ORCID.].[PersonAffiliation].[OrganizationCountry]
        , [ORCID.].[PersonAffiliation].[DisambiguationID]
        , [ORCID.].[PersonAffiliation].[DisambiguationSource]
    FROM
        [ORCID.].[PersonAffiliation]
    WHERE
        [ORCID.].[PersonAffiliation].[PersonMessageID] = @PersonMessageID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationGetByProfilesIDAndAffiliationTypeID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationGetByProfilesIDAndAffiliationTypeID]
 
    @ProfilesID  INT 
    , @AffiliationTypeID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAffiliation].[PersonAffiliationID]
        , [ORCID.].[PersonAffiliation].[ProfilesID]
        , [ORCID.].[PersonAffiliation].[AffiliationTypeID]
        , [ORCID.].[PersonAffiliation].[PersonID]
        , [ORCID.].[PersonAffiliation].[PersonMessageID]
        , [ORCID.].[PersonAffiliation].[DecisionID]
        , [ORCID.].[PersonAffiliation].[DepartmentName]
        , [ORCID.].[PersonAffiliation].[RoleTitle]
        , [ORCID.].[PersonAffiliation].[StartDate]
        , [ORCID.].[PersonAffiliation].[EndDate]
        , [ORCID.].[PersonAffiliation].[OrganizationName]
        , [ORCID.].[PersonAffiliation].[OrganizationCity]
        , [ORCID.].[PersonAffiliation].[OrganizationRegion]
        , [ORCID.].[PersonAffiliation].[OrganizationCountry]
        , [ORCID.].[PersonAffiliation].[DisambiguationID]
        , [ORCID.].[PersonAffiliation].[DisambiguationSource]
    FROM
        [ORCID.].[PersonAffiliation]
    WHERE
        [ORCID.].[PersonAffiliation].[ProfilesID] = @ProfilesID
        AND [ORCID.].[PersonAffiliation].[AffiliationTypeID] = @AffiliationTypeID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAffiliationsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAffiliationsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAffiliation].[PersonAffiliationID]
        , [ORCID.].[PersonAffiliation].[ProfilesID]
        , [ORCID.].[PersonAffiliation].[AffiliationTypeID]
        , [ORCID.].[PersonAffiliation].[PersonID]
        , [ORCID.].[PersonAffiliation].[PersonMessageID]
        , [ORCID.].[PersonAffiliation].[DecisionID]
        , [ORCID.].[PersonAffiliation].[DepartmentName]
        , [ORCID.].[PersonAffiliation].[RoleTitle]
        , [ORCID.].[PersonAffiliation].[StartDate]
        , [ORCID.].[PersonAffiliation].[EndDate]
        , [ORCID.].[PersonAffiliation].[OrganizationName]
        , [ORCID.].[PersonAffiliation].[OrganizationCity]
        , [ORCID.].[PersonAffiliation].[OrganizationRegion]
        , [ORCID.].[PersonAffiliation].[OrganizationCountry]
        , [ORCID.].[PersonAffiliation].[DisambiguationID]
        , [ORCID.].[PersonAffiliation].[DisambiguationSource]
    FROM
        [ORCID.].[PersonAffiliation]
GO
PRINT N'Creating [ORCID.].[cg2_PersonAlternateEmailAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailAdd]

    @PersonAlternateEmailID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @EmailAddress  VARCHAR(200) 
    , @PersonMessageID  INT =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3579
 
  
        INSERT INTO [ORCID.].[PersonAlternateEmail]
        (
            [PersonID]
            , [EmailAddress]
            , [PersonMessageID]
        )
        (
            SELECT
            @PersonID
            , @EmailAddress
            , @PersonMessageID
        )
   
        SET @intReturnVal = @@error
        SET @PersonAlternateEmailID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonAlternateEmail record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonAlternateEmailDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailDelete]
 
    @PersonAlternateEmailID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonAlternateEmail] WHERE         [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID] = @PersonAlternateEmailID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonAlternateEmail record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonAlternateEmailEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailEdit]

    @PersonAlternateEmailID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @EmailAddress  VARCHAR(200) 
    , @PersonMessageID  INT =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3579
 
  
        UPDATE [ORCID.].[PersonAlternateEmail]
        SET
            [PersonID] = @PersonID
            , [EmailAddress] = @EmailAddress
            , [PersonMessageID] = @PersonMessageID
        FROM
            [ORCID.].[PersonAlternateEmail]
        WHERE
        [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID] = @PersonAlternateEmailID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonAlternateEmail record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonAlternateEmailGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailGet]
 
    @PersonAlternateEmailID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID]
        , [ORCID.].[PersonAlternateEmail].[PersonID]
        , [ORCID.].[PersonAlternateEmail].[EmailAddress]
        , [ORCID.].[PersonAlternateEmail].[PersonMessageID]
    FROM
        [ORCID.].[PersonAlternateEmail]
    WHERE
        [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID] = @PersonAlternateEmailID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAlternateEmailGetByPersonID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailGetByPersonID]
 
    @PersonID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID]
        , [ORCID.].[PersonAlternateEmail].[PersonID]
        , [ORCID.].[PersonAlternateEmail].[EmailAddress]
        , [ORCID.].[PersonAlternateEmail].[PersonMessageID]
    FROM
        [ORCID.].[PersonAlternateEmail]
    WHERE
        [ORCID.].[PersonAlternateEmail].[PersonID] = @PersonID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAlternateEmailGetByPersonMessageID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailGetByPersonMessageID]
 
    @PersonMessageID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID]
        , [ORCID.].[PersonAlternateEmail].[PersonID]
        , [ORCID.].[PersonAlternateEmail].[EmailAddress]
        , [ORCID.].[PersonAlternateEmail].[PersonMessageID]
    FROM
        [ORCID.].[PersonAlternateEmail]
    WHERE
        [ORCID.].[PersonAlternateEmail].[PersonMessageID] = @PersonMessageID
GO
PRINT N'Creating [ORCID.].[cg2_PersonAlternateEmailsGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonAlternateEmailsGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[PersonAlternateEmail].[PersonAlternateEmailID]
        , [ORCID.].[PersonAlternateEmail].[PersonID]
        , [ORCID.].[PersonAlternateEmail].[EmailAddress]
        , [ORCID.].[PersonAlternateEmail].[PersonMessageID]
    FROM
        [ORCID.].[PersonAlternateEmail]
GO
PRINT N'Creating [ORCID.].[cg2_PersonDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonDelete]
 
    @PersonID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[Person] WHERE         [ORCID.].[Person].[PersonID] = @PersonID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the Person record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonEdit]...';


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
PRINT N'Creating [ORCID.].[cg2_PersonFacultyRankGet]...';


GO
CREATE PROCEDURE [ORCID.].[cg2_PersonFacultyRankGet]
 
    @FacultyRankID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Person.FacultyRank].[FacultyRankID]
        , [Profile.Data].[Person.FacultyRank].[FacultyRank]
        , [Profile.Data].[Person.FacultyRank].[FacultyRankSort]
        , [Profile.Data].[Person.FacultyRank].[Visible]
    FROM
        [Profile.Data].[Person.FacultyRank]
    WHERE
        [Profile.Data].[Person.FacultyRank].[FacultyRankID] = @FacultyRankID
GO
PRINT N'Creating [ORCID.].[cg2_PersonFacultyRanksGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonFacultyRanksGet]
 
AS
 
    SELECT TOP 100 PERCENT
        [Profile.Data].[Person.FacultyRank].[FacultyRankID]
        , [Profile.Data].[Person.FacultyRank].[FacultyRank]
        , [Profile.Data].[Person.FacultyRank].[FacultyRankSort]
        , [Profile.Data].[Person.FacultyRank].[Visible]
    FROM
        [Profile.Data].[Person.FacultyRank]
GO
PRINT N'Creating [ORCID.].[cg2_PersonGet]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonGet]
 
    @PersonID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[Person].[PersonID]
        , [ORCID.].[Person].[InternalUsername]
        , [ORCID.].[Person].[PersonStatusTypeID]
        , [ORCID.].[Person].[CreateUnlessOptOut]
        , [ORCID.].[Person].[ORCID]
        , [ORCID.].[Person].[ORCIDRecorded]
        , [ORCID.].[Person].[FirstName]
        , [ORCID.].[Person].[LastName]
        , [ORCID.].[Person].[PublishedName]
        , [ORCID.].[Person].[EmailDecisionID]
        , [ORCID.].[Person].[EmailAddress]
        , [ORCID.].[Person].[AlternateEmailDecisionID]
        , [ORCID.].[Person].[AgreementAcknowledged]
        , [ORCID.].[Person].[Biography]
        , [ORCID.].[Person].[BiographyDecisionID]
    FROM
        [ORCID.].[Person]
    WHERE
        [ORCID.].[Person].[PersonID] = @PersonID
GO
PRINT N'Creating [ORCID.].[cg2_PersonGetByCreateUnlessOptOut]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonGetByCreateUnlessOptOut]
 
    @CreateUnlessOptOut  BIT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[Person].[PersonID]
        , [ORCID.].[Person].[InternalUsername]
        , [ORCID.].[Person].[PersonStatusTypeID]
        , [ORCID.].[Person].[CreateUnlessOptOut]
        , [ORCID.].[Person].[ORCID]
        , [ORCID.].[Person].[ORCIDRecorded]
        , [ORCID.].[Person].[FirstName]
        , [ORCID.].[Person].[LastName]
        , [ORCID.].[Person].[PublishedName]
        , [ORCID.].[Person].[EmailDecisionID]
        , [ORCID.].[Person].[EmailAddress]
        , [ORCID.].[Person].[AlternateEmailDecisionID]
        , [ORCID.].[Person].[AgreementAcknowledged]
        , [ORCID.].[Person].[Biography]
        , [ORCID.].[Person].[BiographyDecisionID]
    FROM
        [ORCID.].[Person]
    WHERE
        [ORCID.].[Person].[CreateUnlessOptOut] = @CreateUnlessOptOut
GO
PRINT N'Creating [ORCID.].[cg2_PersonGetByInternalUsername]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonGetByInternalUsername]
 
    @InternalUsername  NVARCHAR(100) 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[Person].[PersonID]
        , [ORCID.].[Person].[InternalUsername]
        , [ORCID.].[Person].[PersonStatusTypeID]
        , [ORCID.].[Person].[CreateUnlessOptOut]
        , [ORCID.].[Person].[ORCID]
        , [ORCID.].[Person].[ORCIDRecorded]
        , [ORCID.].[Person].[FirstName]
        , [ORCID.].[Person].[LastName]
        , [ORCID.].[Person].[PublishedName]
        , [ORCID.].[Person].[EmailDecisionID]
        , [ORCID.].[Person].[EmailAddress]
        , [ORCID.].[Person].[AlternateEmailDecisionID]
        , [ORCID.].[Person].[AgreementAcknowledged]
        , [ORCID.].[Person].[Biography]
        , [ORCID.].[Person].[BiographyDecisionID]
    FROM
        [ORCID.].[Person]
    WHERE
        [ORCID.].[Person].[InternalUsername] = @InternalUsername
GO
PRINT N'Creating [ORCID.].[cg2_PersonGetByORCID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonGetByORCID]
 
    @ORCID  VARCHAR(50) 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[Person].[PersonID]
        , [ORCID.].[Person].[InternalUsername]
        , [ORCID.].[Person].[PersonStatusTypeID]
        , [ORCID.].[Person].[CreateUnlessOptOut]
        , [ORCID.].[Person].[ORCID]
        , [ORCID.].[Person].[ORCIDRecorded]
        , [ORCID.].[Person].[FirstName]
        , [ORCID.].[Person].[LastName]
        , [ORCID.].[Person].[PublishedName]
        , [ORCID.].[Person].[EmailDecisionID]
        , [ORCID.].[Person].[EmailAddress]
        , [ORCID.].[Person].[AlternateEmailDecisionID]
        , [ORCID.].[Person].[AgreementAcknowledged]
        , [ORCID.].[Person].[Biography]
        , [ORCID.].[Person].[BiographyDecisionID]
    FROM
        [ORCID.].[Person]
    WHERE
        [ORCID.].[Person].[ORCID] = @ORCID
GO
PRINT N'Creating [ORCID.].[cg2_PersonGetByPersonStatusTypeID]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonGetByPersonStatusTypeID]
 
    @PersonStatusTypeID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[Person].[PersonID]
        , [ORCID.].[Person].[InternalUsername]
        , [ORCID.].[Person].[PersonStatusTypeID]
        , [ORCID.].[Person].[CreateUnlessOptOut]
        , [ORCID.].[Person].[ORCID]
        , [ORCID.].[Person].[ORCIDRecorded]
        , [ORCID.].[Person].[FirstName]
        , [ORCID.].[Person].[LastName]
        , [ORCID.].[Person].[PublishedName]
        , [ORCID.].[Person].[EmailDecisionID]
        , [ORCID.].[Person].[EmailAddress]
        , [ORCID.].[Person].[AlternateEmailDecisionID]
        , [ORCID.].[Person].[AgreementAcknowledged]
        , [ORCID.].[Person].[Biography]
        , [ORCID.].[Person].[BiographyDecisionID]
    FROM
        [ORCID.].[Person]
    WHERE
        [ORCID.].[Person].[PersonStatusTypeID] = @PersonStatusTypeID
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessageAdd]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonMessageAdd]

    @PersonMessageID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @XML_Sent  VARCHAR(MAX) =NULL
    , @XML_Response  VARCHAR(MAX) =NULL
    , @ErrorMessage  VARCHAR(1000) =NULL
    , @HttpResponseCode  VARCHAR(50) =NULL
    , @MessagePostSuccess  BIT =NULL
    , @RecordStatusID  INT =NULL
    , @PermissionID  INT =NULL
    , @RequestURL  VARCHAR(1000) =NULL
    , @HeaderPost  VARCHAR(1000) =NULL
    , @UserMessage  VARCHAR(2000) =NULL
    , @PostDate  SMALLDATETIME =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3575
 
  
        INSERT INTO [ORCID.].[PersonMessage]
        (
            [PersonID]
            , [XML_Sent]
            , [XML_Response]
            , [ErrorMessage]
            , [HttpResponseCode]
            , [MessagePostSuccess]
            , [RecordStatusID]
            , [PermissionID]
            , [RequestURL]
            , [HeaderPost]
            , [UserMessage]
            , [PostDate]
        )
        (
            SELECT
            @PersonID
            , @XML_Sent
            , @XML_Response
            , @ErrorMessage
            , @HttpResponseCode
            , @MessagePostSuccess
            , @RecordStatusID
            , @PermissionID
            , @RequestURL
            , @HeaderPost
            , @UserMessage
            , @PostDate
        )
   
        SET @intReturnVal = @@error
        SET @PersonMessageID = @@IDENTITY
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while adding the PersonMessage record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessageDelete]...';


GO

CREATE PROCEDURE [ORCID.].[cg2_PersonMessageDelete]
 
    @PersonMessageID  INT 

 
AS
 
    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
 
 
        DELETE FROM [ORCID.].[PersonMessage] WHERE         [ORCID.].[PersonMessage].[PersonMessageID] = @PersonMessageID

 
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while deleting the PersonMessage record.', 11, 11); 
            RETURN @intReturnVal 
        END
    RETURN @intReturnVal
GO
PRINT N'Creating [ORCID.].[cg2_PersonMessageEdit]...';


GO

 
CREATE PROCEDURE [ORCID.].[cg2_PersonMessageEdit]

    @PersonMessageID  INT =NULL OUTPUT 
    , @PersonID  INT 
    , @XML_Sent  VARCHAR(MAX) =NULL
    , @XML_Response  VARCHAR(MAX) =NULL
    , @ErrorMessage  VARCHAR(1000) =NULL
    , @HttpResponseCode  VARCHAR(50) =NULL
    , @MessagePostSuccess  BIT =NULL
    , @RecordStatusID  INT =NULL
    , @PermissionID  INT =NULL
    , @RequestURL  VARCHAR(1000) =NULL
    , @HeaderPost  VARCHAR(1000) =NULL
    , @UserMessage  VARCHAR(2000) =NULL
    , @PostDate  SMALLDATETIME =NULL

AS


    DECLARE @intReturnVal INT 
    SET @intReturnVal = 0
    DECLARE @strReturn  Varchar(200) 
    SET @intReturnVal = 0
    DECLARE @intRecordLevelAuditTrailID INT 
    DECLARE @intFieldLevelAuditTrailID INT 
    DECLARE @intTableID INT 
    SET @intTableID = 3575
 
  
        UPDATE [ORCID.].[PersonMessage]
        SET
            [PersonID] = @PersonID
            , [XML_Sent] = @XML_Sent
            , [XML_Response] = @XML_Response
            , [ErrorMessage] = @ErrorMessage
            , [HttpResponseCode] = @HttpResponseCode
            , [MessagePostSuccess] = @MessagePostSuccess
            , [RecordStatusID] = @RecordStatusID
            , [PermissionID] = @PermissionID
            , [RequestURL] = @RequestURL
            , [HeaderPost] = @HeaderPost
            , [UserMessage] = @UserMessage
            , [PostDate] = @PostDate
        FROM
            [ORCID.].[PersonMessage]
        WHERE
        [ORCID.].[PersonMessage].[PersonMessageID] = @PersonMessageID

        
        SET @intReturnVal = @@error
        IF @intReturnVal <> 0
        BEGIN
            RAISERROR (N'An error occurred while editing the PersonMessage record.', 11, 11); 
            RETURN @intReturnVal 
        END
GO
PRINT N'Creating [Profile.Data].[EagleI.UpdateEagleITables]...';


GO
CREATE PROCEDURE [Profile.Data].[EagleI.UpdateEagleITables]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select right(ProfilesURI,charindex('/',reverse(ProfilesURI))-1) NodeID, *
		into #e
		from (
			select
				r.x.value('profiles-uri[1]','varchar(1000)') ProfilesURI,
				r.x.value('eagle-i-uri[1]','varchar(1000)') EagleiURI,
				cast(r.x.query('html-fragment[1]/*') as nvarchar(max)) HTML
			from [Profile.Data].[EagleI.ImportXML] e cross apply e.x.nodes('//eagle-i-mappings/eagle-i-mapping') as r(x)
		) t


	select e.*, m.InternalID as PersonID
		into #EagleI
		from #e e
			inner join [RDF.Stage].[InternalNodeMap] m
			on e.NodeID = m.NodeID and m.Class = 'http://xmlns.com/foaf/0.1/Person' and m.InternalType = 'Person'
		where e.NodeID is not null and IsNumeric(e.NodeID) = 1

	truncate table [Profile.Data].[EagleI.HTML]

	insert into [Profile.Data].[EagleI.HTML] (NodeID, PersonID, EagleIURI, HTML)
		select NodeID, PersonID, EagleIURI, HTML from #EagleI

END
GO
PRINT N'Creating [RDF.SemWeb].[UpdateHash2Base64]...';


GO
CREATE PROCEDURE [RDF.SemWeb].[UpdateHash2Base64]
	@FullUpdate BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF @FullUpdate = 1
		TRUNCATE TABLE [RDF.SemWeb].[Hash2Base64]
		
	DECLARE @StartNodeID BIGINT
	SELECT @StartNodeID = ISNULL((SELECT MAX(NodeID) FROM [RDF.SemWeb].[Hash2Base64]),-1)

	INSERT INTO [RDF.SemWeb].[Hash2Base64] (NodeID, SemWebHash)
		SELECT NodeID, [RDF.SemWeb].[fnHash2Base64](ValueHash) SemWebHash
			FROM [RDF.].Node
			WHERE NodeID > @StartNodeID

END
GO
PRINT N'Creating [User.Session].[DeleteOldSessionRDF]...';


GO
CREATE PROCEDURE [User.Session].[DeleteOldSessionRDF]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	-- Get a list of nodes for sessions last used more than 7 days ago
	CREATE TABLE #s (
		NodeID BIGINT PRIMARY KEY
	)
	INSERT INTO #s (NodeID)
		SELECT DISTINCT NodeID
			FROM (
				SELECT TOP 1000000 NodeID
					FROM [User.Session].[Session] WITH (NOLOCK)
					WHERE NodeID IS NOT NULL
						AND NodeID IN (SELECT NodeID FROM [RDF.].[Node] WITH (NOLOCK))
						AND DateDiff(dd,LastUsedDate,GetDate()) >= 7
			) t

	-- Get a list of the triples associated with those nodes
	CREATE TABLE #t (
		TripleID BIGINT PRIMARY KEY
	)
	INSERT INTO #t (TripleID)
		SELECT t.TripleID
			FROM [RDF.].[Triple] t WITH (NOLOCK), #s s
			WHERE t.subject = s.NodeID

	-- Delete the triples
	DELETE t
		FROM [RDF.].[Triple] t, #t s
		WHERE t.TripleID = s.TripleID

	-- Turn off real-time indexing
	--ALTER FULLTEXT INDEX ON [RDF.].Node SET CHANGE_TRACKING OFF 
	
	-- Delete the nodes
	DELETE n
		FROM [RDF.].[Node] n, #s s
		WHERE n.NodeID = s.NodeID

	-- Turn on real-time indexing
	--ALTER FULLTEXT INDEX ON [RDF.].Node SET CHANGE_TRACKING AUTO;
	-- Kick off population FT Catalog and index
	--ALTER FULLTEXT INDEX ON [RDF.].Node START FULL POPULATION 


	/*

	SELECT *
		FROM [User.Session].[Session] WITH (NOLOCK)
		WHERE NodeID IS NOT NULL
			AND NodeID IN (SELECT NodeID FROM [RDF.].[Node] WITH (NOLOCK))
			AND DateDiff(hh,LastUsedDate,GetDate()) >= 24
			--AND ((LogoutDate IS NOT NULL) OR (DateDiff(hh,LastUsedDate,GetDate()) >= 24))

	SELECT *
		FROM [RDF.].[Triple] t, #s s
		WHERE t.subject = s.NodeID

	SELECT *
		FROM [RDF.].[Node] n, #s s
		WHERE n.NodeID = s.NodeID

	*/

END
GO
PRINT N'Altering [Framework.].[ChangeBaseURI]...';


GO
ALTER procedure [Framework.].[ChangeBaseURI]
	@oldBaseURI varchar(1000),
	@newBaseURI varchar(1000)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
    /* 
 
	EXAMPLE:
 
	exec [Framework.].[ChangeBaseURI]	@oldBaseURI = 'http://connects.catalyst.harvard.edu/profiles/profile/',
						@newBaseURI = 'http://dev.connects.catalyst.harvard.edu/profiles/profile/'
 
	*/
 
	UPDATE [Framework.].[Parameter]
		SET Value = @newBaseURI
		WHERE ParameterID = 'baseURI'
 
	UPDATE [RDF.].[Node]
		SET Value = @newBaseURI + substring(value,len(@oldBaseURI)+1,len(value)),
			ValueHash = [RDF.].[fnValueHash](Language,DataType,@newBaseURI + substring(value,len(@oldBaseURI)+1,len(value)))
		WHERE Value LIKE @oldBaseURI + '%'
 
	UPDATE m
		SET m.ValueHash = n.ValueHash
		FROM [RDF.Stage].InternalNodeMap m, [RDF.].[Node] n
		WHERE m.NodeID = n.NodeID
 
	EXEC [Search.Cache].[Public.UpdateCache]

	EXEC [Search.Cache].[Private.UpdateCache]

END
GO
PRINT N'Altering [Search.Cache].[Public.GetConnection]...';


GO
ALTER PROCEDURE [Search.Cache].[Public.GetConnection]
	@SearchOptions XML,
	@NodeID BIGINT = NULL,
	@NodeURI VARCHAR(400) = NULL,
	@SessionID UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- start timer
	declare @d datetime
	select @d = GetDate()

	-- get the NodeID
	IF (@NodeID IS NULL) AND (@NodeURI IS NOT NULL)
		SELECT @NodeID = [RDF.].fnURI2NodeID(@NodeURI)
	IF @NodeID IS NULL
		RETURN
	SELECT @NodeURI = Value
		FROM [RDF.].Node
		WHERE NodeID = @NodeID

	-- get the search string
	declare @SearchString varchar(500)
	declare @DoExpandedSearch bit
	select	@SearchString = @SearchOptions.value('SearchOptions[1]/MatchOptions[1]/SearchString[1]','varchar(500)'),
			@DoExpandedSearch = (case when @SearchOptions.value('SearchOptions[1]/MatchOptions[1]/SearchString[1]/@ExactMatch','varchar(50)') = 'true' then 0 else 1 end)

	if @SearchString is null
		RETURN

	-- set constants
	declare @baseURI nvarchar(400)
	declare @typeID bigint
	declare @labelID bigint
	select @baseURI = value from [Framework.].Parameter where ParameterID = 'baseURI'
	select @typeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
	select @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')

	-------------------------------------------------------
	-- Parse search string and convert to fulltext query
	-------------------------------------------------------
	
	declare @NumberOfPhrases INT
	declare @CombinedSearchString VARCHAR(8000)
	declare @SearchPhraseXML XML
	declare @SearchPhraseFormsXML XML
	declare @ParseProcessTime INT

		
	EXEC [Search.].[ParseSearchString]	@SearchString = @SearchString,
										@NumberOfPhrases = @NumberOfPhrases OUTPUT,
										@CombinedSearchString = @CombinedSearchString OUTPUT,
										@SearchPhraseXML = @SearchPhraseXML OUTPUT,
										@SearchPhraseFormsXML = @SearchPhraseFormsXML OUTPUT,
										@ProcessTime = @ParseProcessTime OUTPUT

	declare @PhraseList table (PhraseID int, Phrase varchar(max), ThesaurusMatch bit, Forms varchar(max))
	insert into @PhraseList (PhraseID, Phrase, ThesaurusMatch, Forms)
	select	x.value('@ID','INT'),
			x.value('.','VARCHAR(MAX)'),
			x.value('@ThesaurusMatch','BIT'),
			x.value('@Forms','VARCHAR(MAX)')
		from @SearchPhraseFormsXML.nodes('//SearchPhrase') as p(x)


	-------------------------------------------------------
	-- Find matching nodes connected to NodeID
	-------------------------------------------------------

	-- Get nodes that match separate phrases
	create table #PhraseNodeMap (
		PhraseID int not null,
		NodeID bigint not null,
		MatchedByNodeID bigint not null,
		Distance int,
		Paths int,
		MapWeight float,
		TextWeight float,
		Weight float
	)
	if (@DoExpandedSearch = 1)
	begin
		declare @PhraseSearchString varchar(8000)
		declare @loop int
		select @loop = 1
		while @loop <= @NumberOfPhrases
		begin
			select @PhraseSearchString = Forms
				from @PhraseList
				where PhraseID = @loop
			insert into #PhraseNodeMap (PhraseID, NodeID, MatchedByNodeID, Distance, Paths, MapWeight, TextWeight, Weight)
				select @loop, s.NodeID, s.MatchedByNodeID, s.Distance, s.Paths, s.Weight, m.Weight,
						(case when s.Weight*m.Weight > 0.999999 then 0.999999 else s.Weight*m.Weight end) Weight
					from [Search.Cache].[Public.NodeMap] s, (
						select [Key] NodeID, [Rank]*0.000999+0.001 Weight
							from Containstable ([RDF.].[vwLiteral], value, @PhraseSearchString) n
					) m
					where s.MatchedByNodeID = m.NodeID and s.NodeID = @NodeID
			select @loop = @loop + 1
		end
	end
	else
	begin
		insert into #PhraseNodeMap (PhraseID, NodeID, MatchedByNodeID, Distance, Paths, MapWeight, TextWeight, Weight)
			select 1, s.NodeID, s.MatchedByNodeID, s.Distance, s.Paths, s.Weight, m.Weight,
					(case when s.Weight*m.Weight > 0.999999 then 0.999999 else s.Weight*m.Weight end) Weight
				from [Search.Cache].[Public.NodeMap] s, (
					select [Key] NodeID, [Rank]*0.000999+0.001 Weight
						from Containstable ([RDF.].[vwLiteral], value, @CombinedSearchString) n
				) m
				where s.MatchedByNodeID = m.NodeID and s.NodeID = @NodeID
	end

	-------------------------------------------------------
	-- Get details on the matches
	-------------------------------------------------------
	
	SELECT *
		INTO #m
		FROM (
			SELECT 1 DirectMatch, NodeID, NodeID MiddleNodeID, MatchedByNodeID, 
					COUNT(DISTINCT PhraseID) Phrases, 1-exp(sum(log(1-Weight))) Weight
				FROM #PhraseNodeMap
				WHERE Distance = 1
				GROUP BY NodeID, MatchedByNodeID
			UNION ALL
			SELECT 0 DirectMatch, d.NodeID, y.NodeID MiddleNodeID, d.MatchedByNodeID,
					COUNT(DISTINCT d.PhraseID) Phrases, 1-exp(sum(log(1-d.Weight))) Weight
				FROM #PhraseNodeMap d
					INNER JOIN [Search.Cache].[Public.NodeMap] x
						ON x.NodeID = d.NodeID
							AND x.Distance = d.Distance - 1
					INNER JOIN [Search.Cache].[Public.NodeMap] y
						ON y.NodeID = x.MatchedByNodeID
							AND y.MatchedByNodeID = d.MatchedByNodeID
							AND y.Distance = 1
				WHERE d.Distance > 1
				GROUP BY d.NodeID, d.MatchedByNodeID, y.NodeID
		) t

	SELECT *
		INTO #w
		FROM (
			SELECT DISTINCT m.DirectMatch, m.NodeID, m.MiddleNodeID, m.MatchedByNodeID, m.Phrases, m.Weight,
				p._PropertyLabel PropertyLabel, p._PropertyNode PropertyNode
			FROM #m m
				INNER JOIN [Search.Cache].[Public.NodeClass] c
					ON c.NodeID = m.MiddleNodeID
				INNER JOIN [Ontology.].[ClassProperty] p
					ON p._ClassNode = c.Class
						AND p._NetworkPropertyNode IS NULL
						AND p.SearchWeight > 0
				INNER JOIN [RDF.].Triple t
					ON t.subject = m.MiddleNodeID
						AND t.predicate = p._PropertyNode
						AND t.object = m.MatchedByNodeID
		) t

	SELECT w.DirectMatch, w.Phrases, w.Weight,
			n.NodeID, n.Value URI, c.ShortLabel Label, c.ClassName, 
			w.PropertyLabel Predicate, 
			w.MatchedByNodeID, o.value Value
		INTO #MatchDetails
		FROM #w w
			INNER JOIN [RDF.].Node n
				ON n.NodeID = w.MiddleNodeID
			INNER JOIN [Search.Cache].[Public.NodeSummary] c
				ON c.NodeID = w.MiddleNodeID
			INNER JOIN [RDF.].Node o
				ON o.NodeID = w.MatchedByNodeID

	UPDATE #MatchDetails
		SET Weight = (CASE WHEN Weight > 0.999999 THEN 999999 WHEN Weight < 0.000001 THEN 0.000001 ELSE Weight END)

	-------------------------------------------------------
	-- Build ConnectionDetailsXML
	-------------------------------------------------------

	DECLARE @ConnectionDetailsXML XML
	
	;WITH a AS (
		SELECT DirectMatch, NodeID, URI, Label, ClassName, 
				COUNT(*) NumberOfProperties, 1-exp(sum(log(1-Weight))) Weight,
				(
					SELECT	p.Predicate "Name",
							p.Phrases "NumberOfPhrases",
							p.Weight "Weight",
							p.Value "Value",
							(
								SELECT r.Phrase "MatchedPhrase"
								FROM #PhraseNodeMap q, @PhraseList r
								WHERE q.MatchedByNodeID = p.MatchedByNodeID
									AND r.PhraseID = q.PhraseID
								ORDER BY r.PhraseID
								FOR XML PATH(''), TYPE
							) "MatchedPhraseList"
						FROM #MatchDetails p
						WHERE p.DirectMatch = m.DirectMatch
							AND p.NodeID = m.NodeID
						ORDER BY p.Predicate
						FOR XML PATH('Property'), TYPE
				) PropertyList
			FROM #MatchDetails m
			GROUP BY DirectMatch, NodeID, URI, Label, ClassName
	)
	SELECT @ConnectionDetailsXML = (
		SELECT	(
					SELECT	NodeID "NodeID",
							URI "URI",
							Label "Label",
							ClassName "ClassName",
							NumberOfProperties "NumberOfProperties",
							Weight "Weight",
							PropertyList "PropertyList"
					FROM a
					WHERE DirectMatch = 1
					FOR XML PATH('Match'), TYPE
				) "DirectMatchList",
				(
					SELECT	NodeID "NodeID",
							URI "URI",
							Label "Label",
							ClassName "ClassName",
							NumberOfProperties "NumberOfProperties",
							Weight "Weight",
							PropertyList "PropertyList"
					FROM a
					WHERE DirectMatch = 0
					FOR XML PATH('Match'), TYPE
				) "IndirectMatchList"				
		FOR XML PATH(''), TYPE
	)
	
	--SELECT @ConnectionDetailsXML ConnectionDetails
	--SELECT * FROM #PhraseNodeMap

	-------------------------------------------------------
	-- Get RDF of the NodeID
	-------------------------------------------------------

	DECLARE @ObjectNodeRDF NVARCHAR(MAX)
	
	EXEC [RDF.].GetDataRDF	@subject = @NodeID,
							@showDetails = 0,
							@expand = 0,
							@SessionID = @SessionID,
							@returnXML = 0,
							@dataStr = @ObjectNodeRDF OUTPUT


	-------------------------------------------------------
	-- Form search results details RDF
	-------------------------------------------------------

	DECLARE @results NVARCHAR(MAX)

	SELECT @results = ''
			+'<rdf:Description rdf:nodeID="SearchResultsDetails">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Connection" />'
			+'<prns:connectionInNetwork rdf:NodeID="SearchResults" />'
			--+'<prns:connectionWeight>0.37744</prns:connectionWeight>'
			+'<prns:hasConnectionDetails rdf:NodeID="ConnectionDetails" />'
			+'<rdf:object rdf:resource="'+@NodeURI+'" />'
			+'<rdfs:label>Search Results Details</rdfs:label>'
			+'</rdf:Description>'
			+'<rdf:Description rdf:nodeID="SearchResults">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Network" />'
			+'<rdfs:label>Search Results</rdfs:label>'
			+'<vivo:overview rdf:parseType="Literal">'
			+CAST(@SearchOptions AS NVARCHAR(MAX))
			+IsNull('<SearchDetails>'+CAST(@SearchPhraseXML AS NVARCHAR(MAX))+'</SearchDetails>','')
			+'</vivo:overview>'
			+'<prns:hasConnection rdf:nodeID="SearchResultsDetails" />'
			+'</rdf:Description>'
			+IsNull(@ObjectNodeRDF,'')
			+'<rdf:Description rdf:NodeID="ConnectionDetails">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#ConnectionDetails" />'
			+'<vivo:overview rdf:parseType="Literal">'
			+CAST(@ConnectionDetailsXML AS NVARCHAR(MAX))
			+'</vivo:overview>'
			+'</rdf:Description> '

	declare @x as varchar(max)
	select @x = '<rdf:RDF'
	select @x = @x + ' xmlns:'+Prefix+'="'+URI+'"' 
		from [Ontology.].Namespace
	select @x = @x + ' >' + @results + '</rdf:RDF>'
	select cast(@x as xml) RDF

/*


	EXEC [Search.].[GetNodes] @SearchOptions = '
	<SearchOptions>
		<MatchOptions>
			<SearchString ExactMatch="false">options for "lung cancer" treatment</SearchString>
			<ClassURI>http://xmlns.com/foaf/0.1/Person</ClassURI>
		</MatchOptions>
		<OutputOptions>
			<Offset>0</Offset>
			<Limit>5</Limit>
		</OutputOptions>	
	</SearchOptions>
	'

	EXEC [Search.].[GetConnection] @SearchOptions = '
	<SearchOptions>
		<MatchOptions>
			<SearchString ExactMatch="false">options for "lung cancer" treatment</SearchString>
			<ClassURI>http://xmlns.com/foaf/0.1/Person</ClassURI>
		</MatchOptions>
		<OutputOptions>
			<Offset>0</Offset>
			<Limit>5</Limit>
		</OutputOptions>	
	</SearchOptions>
	', @NodeURI = 'http://localhost:55956/profile/1069731'


*/

END
GO
PRINT N'Altering [Search.Cache].[Private.GetConnection]...';


GO
ALTER PROCEDURE [Search.Cache].[Private.GetConnection]
	@SearchOptions XML,
	@NodeID BIGINT = NULL,
	@NodeURI VARCHAR(400) = NULL,
	@SessionID UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- start timer
	declare @d datetime
	select @d = GetDate()

	-- get the NodeID
	IF (@NodeID IS NULL) AND (@NodeURI IS NOT NULL)
		SELECT @NodeID = [RDF.].fnURI2NodeID(@NodeURI)
	IF @NodeID IS NULL
		RETURN
	SELECT @NodeURI = Value
		FROM [RDF.].Node
		WHERE NodeID = @NodeID

	-- get the search string
	declare @SearchString varchar(500)
	declare @DoExpandedSearch bit
	select	@SearchString = @SearchOptions.value('SearchOptions[1]/MatchOptions[1]/SearchString[1]','varchar(500)'),
			@DoExpandedSearch = (case when @SearchOptions.value('SearchOptions[1]/MatchOptions[1]/SearchString[1]/@ExactMatch','varchar(50)') = 'true' then 0 else 1 end)

	if @SearchString is null
		RETURN

	-- set constants
	declare @baseURI nvarchar(400)
	declare @typeID bigint
	declare @labelID bigint
	select @baseURI = value from [Framework.].Parameter where ParameterID = 'baseURI'
	select @typeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
	select @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')

	-------------------------------------------------------
	-- Parse search string and convert to fulltext query
	-------------------------------------------------------
	
	declare @NumberOfPhrases INT
	declare @CombinedSearchString VARCHAR(8000)
	declare @SearchPhraseXML XML
	declare @SearchPhraseFormsXML XML
	declare @ParseProcessTime INT

		
	EXEC [Search.].[ParseSearchString]	@SearchString = @SearchString,
										@NumberOfPhrases = @NumberOfPhrases OUTPUT,
										@CombinedSearchString = @CombinedSearchString OUTPUT,
										@SearchPhraseXML = @SearchPhraseXML OUTPUT,
										@SearchPhraseFormsXML = @SearchPhraseFormsXML OUTPUT,
										@ProcessTime = @ParseProcessTime OUTPUT

	declare @PhraseList table (PhraseID int, Phrase varchar(max), ThesaurusMatch bit, Forms varchar(max))
	insert into @PhraseList (PhraseID, Phrase, ThesaurusMatch, Forms)
	select	x.value('@ID','INT'),
			x.value('.','VARCHAR(MAX)'),
			x.value('@ThesaurusMatch','BIT'),
			x.value('@Forms','VARCHAR(MAX)')
		from @SearchPhraseFormsXML.nodes('//SearchPhrase') as p(x)


	-------------------------------------------------------
	-- Find matching nodes connected to NodeID
	-------------------------------------------------------


	-- Get nodes that match separate phrases
	create table #PhraseNodeMap (
		PhraseID int not null,
		NodeID bigint not null,
		MatchedByNodeID bigint not null,
		Distance int,
		Paths int,
		MapWeight float,
		TextWeight float,
		Weight float
	)
	if (@DoExpandedSearch = 1)
	begin
		declare @PhraseSearchString varchar(8000)
		declare @loop int
		select @loop = 1
		while @loop <= @NumberOfPhrases
		begin
			select @PhraseSearchString = Forms
				from @PhraseList
				where PhraseID = @loop
			insert into #PhraseNodeMap (PhraseID, NodeID, MatchedByNodeID, Distance, Paths, MapWeight, TextWeight, Weight)
				select @loop, s.NodeID, s.MatchedByNodeID, s.Distance, s.Paths, s.Weight, m.Weight,
						(case when s.Weight*m.Weight > 0.999999 then 0.999999 else s.Weight*m.Weight end) Weight
					from [Search.Cache].[Private.NodeMap] s, (
						select [Key] NodeID, [Rank]*0.000999+0.001 Weight
							from Containstable ([RDF.].[vwLiteral], value, @PhraseSearchString) n
					) m
					where s.MatchedByNodeID = m.NodeID and s.NodeID = @NodeID
			select @loop = @loop + 1
		end
	end
	else
	begin
		insert into #PhraseNodeMap (PhraseID, NodeID, MatchedByNodeID, Distance, Paths, MapWeight, TextWeight, Weight)
			select 1, s.NodeID, s.MatchedByNodeID, s.Distance, s.Paths, s.Weight, m.Weight,
					(case when s.Weight*m.Weight > 0.999999 then 0.999999 else s.Weight*m.Weight end) Weight
				from [Search.Cache].[Private.NodeMap] s, (
					select [Key] NodeID, [Rank]*0.000999+0.001 Weight
						from Containstable ([RDF.].[vwLiteral], value, @CombinedSearchString) n
				) m
				where s.MatchedByNodeID = m.NodeID and s.NodeID = @NodeID
	end


	-------------------------------------------------------
	-- Get details on the matches
	-------------------------------------------------------
	
	SELECT *
		INTO #m
		FROM (
			SELECT 1 DirectMatch, NodeID, NodeID MiddleNodeID, MatchedByNodeID, 
					COUNT(DISTINCT PhraseID) Phrases, 1-exp(sum(log(1-Weight))) Weight
				FROM #PhraseNodeMap
				WHERE Distance = 1
				GROUP BY NodeID, MatchedByNodeID
			UNION ALL
			SELECT 0 DirectMatch, d.NodeID, y.NodeID MiddleNodeID, d.MatchedByNodeID,
					COUNT(DISTINCT d.PhraseID) Phrases, 1-exp(sum(log(1-d.Weight))) Weight
				FROM #PhraseNodeMap d
					INNER JOIN [Search.Cache].[Private.NodeMap] x
						ON x.NodeID = d.NodeID
							AND x.Distance = d.Distance - 1
					INNER JOIN [Search.Cache].[Private.NodeMap] y
						ON y.NodeID = x.MatchedByNodeID
							AND y.MatchedByNodeID = d.MatchedByNodeID
							AND y.Distance = 1
				WHERE d.Distance > 1
				GROUP BY d.NodeID, d.MatchedByNodeID, y.NodeID
		) t

	SELECT *
		INTO #w
		FROM (
			SELECT DISTINCT m.DirectMatch, m.NodeID, m.MiddleNodeID, m.MatchedByNodeID, m.Phrases, m.Weight,
				p._PropertyLabel PropertyLabel, p._PropertyNode PropertyNode
			FROM #m m
				INNER JOIN [Search.Cache].[Private.NodeClass] c
					ON c.NodeID = m.MiddleNodeID
				INNER JOIN [Ontology.].[ClassProperty] p
					ON p._ClassNode = c.Class
						AND p._NetworkPropertyNode IS NULL
						AND p.SearchWeight > 0
				INNER JOIN [RDF.].Triple t
					ON t.subject = m.MiddleNodeID
						AND t.predicate = p._PropertyNode
						AND t.object = m.MatchedByNodeID
		) t

	SELECT w.DirectMatch, w.Phrases, w.Weight,
			n.NodeID, n.Value URI, c.ShortLabel Label, c.ClassName, 
			w.PropertyLabel Predicate, 
			w.MatchedByNodeID, o.value Value
		INTO #MatchDetails
		FROM #w w
			INNER JOIN [RDF.].Node n
				ON n.NodeID = w.MiddleNodeID
			INNER JOIN [Search.Cache].[Private.NodeSummary] c
				ON c.NodeID = w.MiddleNodeID
			INNER JOIN [RDF.].Node o
				ON o.NodeID = w.MatchedByNodeID

	UPDATE #MatchDetails
		SET Weight = (CASE WHEN Weight > 0.999999 THEN 999999 WHEN Weight < 0.000001 THEN 0.000001 ELSE Weight END)

	-------------------------------------------------------
	-- Build ConnectionDetailsXML
	-------------------------------------------------------

	DECLARE @ConnectionDetailsXML XML
	
	;WITH a AS (
		SELECT DirectMatch, NodeID, URI, Label, ClassName, 
				COUNT(*) NumberOfProperties, 1-exp(sum(log(1-Weight))) Weight,
				(
					SELECT	p.Predicate "Name",
							p.Phrases "NumberOfPhrases",
							p.Weight "Weight",
							p.Value "Value",
							(
								SELECT r.Phrase "MatchedPhrase"
								FROM #PhraseNodeMap q, @PhraseList r
								WHERE q.MatchedByNodeID = p.MatchedByNodeID
									AND r.PhraseID = q.PhraseID
								ORDER BY r.PhraseID
								FOR XML PATH(''), TYPE
							) "MatchedPhraseList"
						FROM #MatchDetails p
						WHERE p.DirectMatch = m.DirectMatch
							AND p.NodeID = m.NodeID
						ORDER BY p.Predicate
						FOR XML PATH('Property'), TYPE
				) PropertyList
			FROM #MatchDetails m
			GROUP BY DirectMatch, NodeID, URI, Label, ClassName
	)
	SELECT @ConnectionDetailsXML = (
		SELECT	(
					SELECT	NodeID "NodeID",
							URI "URI",
							Label "Label",
							ClassName "ClassName",
							NumberOfProperties "NumberOfProperties",
							Weight "Weight",
							PropertyList "PropertyList"
					FROM a
					WHERE DirectMatch = 1
					FOR XML PATH('Match'), TYPE
				) "DirectMatchList",
				(
					SELECT	NodeID "NodeID",
							URI "URI",
							Label "Label",
							ClassName "ClassName",
							NumberOfProperties "NumberOfProperties",
							Weight "Weight",
							PropertyList "PropertyList"
					FROM a
					WHERE DirectMatch = 0
					FOR XML PATH('Match'), TYPE
				) "IndirectMatchList"				
		FOR XML PATH(''), TYPE
	)
	
	--SELECT @ConnectionDetailsXML ConnectionDetails
	--SELECT * FROM #PhraseNodeMap


	-------------------------------------------------------
	-- Get RDF of the NodeID
	-------------------------------------------------------

	DECLARE @ObjectNodeRDF NVARCHAR(MAX)
	
	EXEC [RDF.].GetDataRDF	@subject = @NodeID,
							@showDetails = 0,
							@expand = 0,
							@SessionID = @SessionID,
							@returnXML = 0,
							@dataStr = @ObjectNodeRDF OUTPUT


	-------------------------------------------------------
	-- Form search results details RDF
	-------------------------------------------------------

	DECLARE @results NVARCHAR(MAX)

	SELECT @results = ''
			+'<rdf:Description rdf:nodeID="SearchResultsDetails">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Connection" />'
			+'<prns:connectionInNetwork rdf:NodeID="SearchResults" />'
			--+'<prns:connectionWeight>0.37744</prns:connectionWeight>'
			+'<prns:hasConnectionDetails rdf:NodeID="ConnectionDetails" />'
			+'<rdf:object rdf:resource="'+@NodeURI+'" />'
			+'<rdfs:label>Search Results Details</rdfs:label>'
			+'</rdf:Description>'
			+'<rdf:Description rdf:nodeID="SearchResults">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#Network" />'
			+'<rdfs:label>Search Results</rdfs:label>'
			+'<vivo:overview rdf:parseType="Literal">'
			+CAST(@SearchOptions AS NVARCHAR(MAX))
			+IsNull('<SearchDetails>'+CAST(@SearchPhraseXML AS NVARCHAR(MAX))+'</SearchDetails>','')
			+'</vivo:overview>'
			+'<prns:hasConnection rdf:nodeID="SearchResultsDetails" />'
			+'</rdf:Description>'
			+IsNull(@ObjectNodeRDF,'')
			+'<rdf:Description rdf:NodeID="ConnectionDetails">'
			+'<rdf:type rdf:resource="http://profiles.catalyst.harvard.edu/ontology/prns#ConnectionDetails" />'
			+'<vivo:overview rdf:parseType="Literal">'
			+CAST(@ConnectionDetailsXML AS NVARCHAR(MAX))
			+'</vivo:overview>'
			+'</rdf:Description> '

	declare @x as varchar(max)
	select @x = '<rdf:RDF'
	select @x = @x + ' xmlns:'+Prefix+'="'+URI+'"' 
		from [Ontology.].Namespace
	select @x = @x + ' >' + @results + '</rdf:RDF>'
	select cast(@x as xml) RDF


END
GO
PRINT N'Altering [Search.].[LookupNodes]...';


GO
ALTER PROCEDURE [Search.].[LookupNodes]
	@SearchOptions XML,
	@SessionID UNIQUEIDENTIFIER = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/********************************************************************
	
	This procedure provides secure, real-time search for editing and
	administrative functions. It gets called in the same way as the
	main GetNodes search procedure, but it has several differences:
	
	1) All nodes, including non-public nodes, are searched. The
		user's SessionID determines which non-public nodes are
		returned.
	2) No cache tables are used. Changes to Nodes and Triples are
		immediately available to this procedure. Though, there could
		be a delay caused by the time it takes fulltext search indexes
		to be updated.
	3) Only node labels (not the full content of a profile) are 
		searched. As a result, fewer nodes are matched by a search
		string.
	4) There are fewer search options. In particular, class group,
		search filters, and sort options are not supported.
	5) Data is returned as XML, not RDF.
	
	Below are examples:

	-- Return all people named "Smith"
	EXEC [Search.].[LookupNodes] @SearchOptions = '
		<SearchOptions>
			<MatchOptions>
				<SearchString>Smith</SearchString>
				<ClassURI>http://xmlns.com/foaf/0.1/Person</ClassURI>
			</MatchOptions>
			<OutputOptions>
				<Offset>0</Offset>
				<Limit>5</Limit>
			</OutputOptions>	
		</SearchOptions>
		'

	-- Return publications about "lung cancer"
	EXEC [Search.].[LookupNodes] @SearchOptions = '
		<SearchOptions>
			<MatchOptions>
				<SearchString>lung cancer</SearchString>
				<ClassURI>http://purl.org/ontology/bibo/AcademicArticle</ClassURI>
			</MatchOptions>
			<OutputOptions>
				<Offset>5</Offset>
				<Limit>10</Limit>
			</OutputOptions>	
		</SearchOptions>
		'

	-- Return all departments
	EXEC [Search.].[LookupNodes] @SearchOptions = '
		<SearchOptions>
			<MatchOptions>
				<ClassURI>http://vivoweb.org/ontology/core#Department</ClassURI>
			</MatchOptions>
			<OutputOptions>
				<Offset>0</Offset>
				<Limit>25</Limit>
			</OutputOptions>	
		</SearchOptions>
		'

	********************************************************************/

	-- start timer
	declare @d datetime
	select @d = GetDate()

	-- declare variables
	declare @MatchOptions xml
	declare @OutputOptions xml
	declare @SearchString varchar(500)
	declare @ClassURI varchar(400)
	declare @offset bigint
	declare @limit bigint
	declare @baseURI nvarchar(400)
	declare @typeID bigint
	declare @labelID bigint
	declare @classID bigint
	declare @CombinedSearchString VARCHAR(8000)

	-- set constants
	select @baseURI = value from [Framework.].Parameter where ParameterID = 'baseURI'
	select @typeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
	select @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')

	-- parse input
	select	@MatchOptions = @SearchOptions.query('SearchOptions[1]/MatchOptions[1]'),
			@OutputOptions = @SearchOptions.query('SearchOptions[1]/OutputOptions[1]')
	select	@SearchString = @MatchOptions.value('MatchOptions[1]/SearchString[1]','varchar(500)'),
			@ClassURI = @MatchOptions.value('MatchOptions[1]/ClassURI[1]','varchar(400)'),
			@offset = @OutputOptions.value('OutputOptions[1]/Offset[1]','bigint'),
			@limit = @OutputOptions.value('OutputOptions[1]/Limit[1]','bigint')
	if @ClassURI is not null
		select @classID = [RDF.].fnURI2NodeID(@ClassURI)
	if @SearchString is not null
		EXEC [Search.].[ParseSearchString]	@SearchString = @SearchString,
											@CombinedSearchString = @CombinedSearchString OUTPUT

	-- get security information
	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID


	-- get a list of possible classes
	create table #c (ClassNode bigint primary key, TreeDepth int, ClassName varchar(400))
	insert into #c (ClassNode, TreeDepth, ClassName)
		select _ClassNode, _TreeDepth, _ClassName
		from [Ontology.].ClassTreeDepth
		where _ClassNode = IsNull(@classID,_ClassNode)

	
	-- CASE 1: A search string was provided
	IF IsNull(@CombinedSearchString,'') <> ''
	BEGIN
		;with a as (
			select NodeID, Label, ClassName, URI, ConnectionWeight,
					row_number() over (order by Label, NodeID) SortOrder
				from (
					select (case when len(m.Value)>500 then left(m.Value,497)+'...' else m.Value end) Label, 
						n.NodeID, n.value URI, c.ClassName ClassName, x.[Rank]*0.001 ConnectionWeight,
						row_number() over (partition by n.NodeID order by c.TreeDepth desc) k
					from Containstable ([RDF.].[vwLiteral], value, @CombinedSearchString) x
						inner join [RDF.].Node m -- text node
							on x.[Key] = m.NodeID
								and ((m.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (m.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (m.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
						inner join [RDF.].Triple t -- match label
							on t.object = m.NodeID
								and t.predicate = @labelID
								and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
						inner join [RDF.].Node n -- match node
							on n.NodeID = t.subject
								and ((n.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (n.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (n.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
						inner join [RDF.].Triple v -- class
							on v.subject = n.NodeID
								and v.predicate = @typeID
								and ((v.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (v.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (v.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
						inner join #c c -- class name
							on c.ClassNode = v.object
				) t
				where k = 1
		)
		select (
				select	@SearchString "SearchString",
						@ClassURI "ClassURI",
						@offset "offset",
						@limit "limit",
						(select count(*) from a) "NumberOfConnections",
						(
							select	SortOrder "Connection/@SortOrder",
									NodeID "Connection/@NodeID",
									ClassName "Connection/@ClassName", 
									URI "Connection/@URI",
									ConnectionWeight "Connection/@ConnectionWeight",
									Label "Connection"
							from a
							where SortOrder >= (IsNull(@offset,0) + 1) AND SortOrder <= (IsNull(@offset,0) + IsNull(@limit,SortOrder))
							order by SortOrder
							for xml path(''), type
						) "Network"
					for xml path('SearchResults'), type
			) SearchResults
	END


	-- CASE 2: A Class, but no search string, was provided
	IF (IsNull(@CombinedSearchString,'') = '') AND (@classID IS NOT NULL)
	BEGIN
		;with a as (
			select NodeID, Label, ClassName, URI, 1 ConnectionWeight,
					row_number() over (order by Label, NodeID) SortOrder
				from (
					select (case when len(m.Value)>500 then left(m.Value,497)+'...' else m.Value end) Label, 
						n.NodeID, n.value URI, c.ClassName ClassName,
						row_number() over (partition by n.NodeID order by m.NodeID desc) k
					from #c c
						inner join [RDF.].Triple v -- class
							on v.object = c.ClassNode
								and v.predicate = @typeID
								and ((v.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (v.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (v.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
						inner join [RDF.].Node n -- match node
							on n.NodeID = v.subject
								and ((n.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (n.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (n.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
						inner join [RDF.].Triple t -- match label
							on t.subject = n.NodeID
								and t.predicate = @labelID
								and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
						inner join [RDF.].Node m -- text node
							on m.NodeID = t.object
								and ((m.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (m.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (m.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				) t
				where k = 1
		)
		select (
				select	@SearchString "SearchString",
						@ClassURI "ClassURI",
						@offset "offset",
						@limit "limit",
						(select count(*) from a) "NumberOfConnections",
						(
							select	SortOrder "Connection/@SortOrder",
									NodeID "Connection/@NodeID",
									ClassName "Connection/@ClassName", 
									URI "Connection/@URI",
									ConnectionWeight "Connection/@ConnectionWeight",
									Label "Connection"
							from a
							where SortOrder >= (IsNull(@offset,0) + 1) AND SortOrder <= (IsNull(@offset,0) + IsNull(@limit,SortOrder))
							order by SortOrder
							for xml path(''), type
						) "Network"
					for xml path('SearchResults'), type
			) SearchResults	
	END


END
GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.ParsePubMedXML]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.ParsePubMedXML]';


GO
PRINT N'Refreshing [Profile.Cache].[Publication.PubMed.UpdateAuthorPosition]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Cache].[Publication.PubMed.UpdateAuthorPosition]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.AddOneAuthorPosition]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.AddOneAuthorPosition]';


GO
PRINT N'Refreshing [Profile.Import].[Beta.LoadData]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Import].[Beta.LoadData]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.AddPubMedXML]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.AddPubMedXML]';


GO
PRINT N'Refreshing [Edit.Module].[CustomEditAwardOrHonor.StoreItem]...';


GO
EXECUTE sp_refreshsqlmodule N'[Edit.Module].[CustomEditAwardOrHonor.StoreItem]';


GO
PRINT N'Refreshing [Profile.Data].[Person.AddPhoto]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Person.AddPhoto]';


GO
PRINT N'Refreshing [Search.Cache].[Private.UpdateCache]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.Cache].[Private.UpdateCache]';


GO
PRINT N'Refreshing [Search.Cache].[Public.UpdateCache]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.Cache].[Public.UpdateCache]';


GO
PRINT N'Refreshing [Search.].[GetConnection]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.].[GetConnection]';


GO
PRINT N'Refreshing [Search.].[GetNodes]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.].[GetNodes]';


GO
PRINT N'Checking existing data against newly created constraints';



GO
ALTER TABLE [ORCID.].[RecordLevelAuditTrail] WITH CHECK CHECK CONSTRAINT [FK_RecordLevelAuditTrail_RecordLevelAuditType];

ALTER TABLE [ORCID.].[Person] WITH CHECK CHECK CONSTRAINT [fk_Person_AlternateEmailDecisionID];

ALTER TABLE [ORCID.].[Person] WITH CHECK CHECK CONSTRAINT [fk_Person_BiographyDecisionID];

ALTER TABLE [ORCID.].[Person] WITH CHECK CHECK CONSTRAINT [fk_Person_EmailDecisionID];

ALTER TABLE [ORCID.].[Person] WITH CHECK CHECK CONSTRAINT [fk_Person_personstatustypeid];

ALTER TABLE [ORCID.].[PersonMessage] WITH CHECK CHECK CONSTRAINT [FK_PersonMessage_Person];

ALTER TABLE [ORCID.].[PersonMessage] WITH CHECK CHECK CONSTRAINT [FK_PersonMessage_RecordStatusID];

ALTER TABLE [ORCID.].[PersonMessage] WITH CHECK CHECK CONSTRAINT [FK_PersonMessage_REF_Permission];

ALTER TABLE [ORCID.].[FieldLevelAuditTrail] WITH CHECK CHECK CONSTRAINT [FK_FieldLevelAuditTrail_RecordLevelAuditTrail];

ALTER TABLE [ORCID.].[PersonAffiliation] WITH CHECK CHECK CONSTRAINT [FK_PersonAffiliation_Person];

ALTER TABLE [ORCID.].[PersonAffiliation] WITH CHECK CHECK CONSTRAINT [FK_PersonAffiliation_PersonMessage];

ALTER TABLE [ORCID.].[PersonAffiliation] WITH CHECK CHECK CONSTRAINT [FK_PersonAffiliation_REF_Decision];

ALTER TABLE [ORCID.].[PersonAlternateEmail] WITH CHECK CHECK CONSTRAINT [fk_PersonAlternateEmail_Personid];

ALTER TABLE [ORCID.].[PersonAlternateEmail] WITH CHECK CHECK CONSTRAINT [fk_PersonAlternateEmail_PersonMessageid];

ALTER TABLE [ORCID.].[PersonOthername] WITH CHECK CHECK CONSTRAINT [fk_PersonOthername_Personid];

ALTER TABLE [ORCID.].[PersonOthername] WITH CHECK CHECK CONSTRAINT [fk_PersonOthername_PersonMessageid];

ALTER TABLE [ORCID.].[PersonToken] WITH CHECK CHECK CONSTRAINT [FK_PersonToken_Permissions];

ALTER TABLE [ORCID.].[PersonToken] WITH CHECK CHECK CONSTRAINT [FK_PersonToken_Person];

ALTER TABLE [ORCID.].[PersonURL] WITH CHECK CHECK CONSTRAINT [FK_Person_PersonURL];

ALTER TABLE [ORCID.].[PersonURL] WITH CHECK CHECK CONSTRAINT [FK_PersonMessage_PersonURL];

ALTER TABLE [ORCID.].[PersonURL] WITH CHECK CHECK CONSTRAINT [FK_REFDecision_PersonURL];

ALTER TABLE [ORCID.].[PersonWork] WITH CHECK CHECK CONSTRAINT [FK_PersonWork_Person];

ALTER TABLE [ORCID.].[PersonWork] WITH CHECK CHECK CONSTRAINT [FK_PersonWork_PersonMessage];

ALTER TABLE [ORCID.].[PersonWork] WITH CHECK CHECK CONSTRAINT [FK_PersonWork_REF_Decision];

ALTER TABLE [ORCID.].[PersonWorkIdentifier] WITH CHECK CHECK CONSTRAINT [FK_PersonWorkIdentifier_PersonWork];

ALTER TABLE [ORCID.].[PersonWorkIdentifier] WITH CHECK CHECK CONSTRAINT [FK_PersonWorkIdentifier_WorkExternalTypeID];

GO



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
		DECLARE @InternalType nvarchar(100) -- lookup from import.twitter
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
		DECLARE @Enabled bit
		
		SELECT @InternalType = n.value FROM [rdf.].[Triple] t JOIN [rdf.].Node n ON t.[Object] = n.NodeID 
			WHERE t.[Subject] = [RDF.].fnURI2NodeID('http://orng.info/ontology/orng#Application')
			and t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
		SELECT @Name = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
			FROM [ORNG.].[Apps] WHERE AppID = @AppID 
		SELECT @URL = url FROM [ORNG.].[Apps] WHERE AppID = @AppID
		SELECT @Enabled = Enabled FROM [ORNG.].[Apps] WHERE AppID = @AppID
			
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
		IF (@Enabled = 1)
		BEGIN								
			UPDATE [Ontology.].[ClassProperty] set EditExistingSecurityGroup = -20, IsDetail = 0, IncludeDescription = 0,
					CustomEdit = 1, CustomEditModule = @CustomEditModule,
					CustomDisplay = 1, CustomDisplayModule = @CustomDisplayModule,
					EditSecurityGroup = -20, EditPermissionsSecurityGroup = -20, -- was -20's
					EditAddNewSecurityGroup = -20, EditAddExistingSecurityGroup = -20, EditDeleteSecurityGroup = -20 
				WHERE property = @ClassPropertyName;
		END
		ELSE IF (@Enabled = 0)
		BEGIN								
			UPDATE [Ontology.].[ClassProperty] set EditExistingSecurityGroup = -50, IsDetail = 0, IncludeDescription = 0,
					CustomEdit = 1, CustomEditModule = @CustomEditModule,
					CustomDisplay = 1, CustomDisplayModule = @CustomDisplayModule,
					EditSecurityGroup = -50, EditPermissionsSecurityGroup = -50, -- was -20's
					EditAddNewSecurityGroup = -50, EditAddExistingSecurityGroup = -50, EditDeleteSecurityGroup = -50,
					ViewSecurityGroup = -50
				WHERE property = @ClassPropertyName;
		END
END
GO
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
	DECLARE @InternalType nvarchar(100) -- lookup from import.twitter
	DECLARE @InternalID nvarchar(100) -- lookpup personid and add appID
	DECLARE @PersonID INT
	DECLARE @PersonName nvarchar(255)
	DECLARE @Label nvarchar(255)
	DECLARE @LabelID BIGINT
	DECLARE @AppName NVARCHAR(100)
	DECLARE @ApplicationNodeID BIGINT
	DECLARE @PredicateURI nvarchar(255) --this could be passed in for some situations
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
GO
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
GO

PRINT N'Schema Update complete.';


GO
