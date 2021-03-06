/*
Run this script on:

        Profiles 2.5.1    -  This database will be modified

to synchronize it with:

        Profiles 2.6

You are recommended to back up your database before running this script

Details of which objects have changed can be found in the release notes.
If you have made changes to existing tables or stored procedures in profiles, you may need to merge changes individually. 

*/



GO
PRINT N'Dropping [ORNG.].[DF_orng_app_registry_createdDT]...';


GO
ALTER TABLE [ORNG.].[AppRegistry] DROP CONSTRAINT [DF_orng_app_registry_createdDT];


GO
PRINT N'Dropping on [ORNG.].[Apps].[RequiresRegistration]...';

DECLARE @ObjectName NVARCHAR(100)
SELECT @ObjectName = OBJECT_NAME([default_object_id]) FROM SYS.COLUMNS
WHERE [object_id] = OBJECT_ID('[ORNG.].[Apps]') AND [name] = 'RequiresRegistration';
EXEC('ALTER TABLE [ORNG.].[Apps] DROP CONSTRAINT ' + @ObjectName)



GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_authors_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Author] DROP CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_pubtypes_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.PubType] DROP CONSTRAINT [FK_pm_pubs_pubtypes_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_keywords_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Keyword] DROP CONSTRAINT [FK_pm_pubs_keywords_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_accessions_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Accession] DROP CONSTRAINT [FK_pm_pubs_accessions_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_databanks_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Databank] DROP CONSTRAINT [FK_pm_pubs_databanks_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_chemicals_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Chemical] DROP CONSTRAINT [FK_pm_pubs_chemicals_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_mesh_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Mesh] DROP CONSTRAINT [FK_pm_pubs_mesh_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_investigators_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Investigator] DROP CONSTRAINT [FK_pm_pubs_investigators_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_pm_pubs_grants_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Grant] DROP CONSTRAINT [FK_pm_pubs_grants_pm_pubs_general];


GO
PRINT N'Dropping [Profile.Data].[FK_publications_include_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.Person.Include] DROP CONSTRAINT [FK_publications_include_pm_pubs_general];


GO
PRINT N'Dropping [ORNG.].[IsRegistered]...';


GO
DROP PROCEDURE [ORNG.].[IsRegistered];


GO
PRINT N'Dropping [ORNG.].[AppRegistry]...';


GO
DROP TABLE [ORNG.].[AppRegistry];


GO
PRINT N'Altering [ORNG.].[Apps]...';


GO
ALTER TABLE [ORNG.].[Apps] DROP COLUMN [RequiresRegistration], COLUMN [UnavailableMessage];


GO
PRINT N'Starting rebuilding table [Profile.Data].[Publication.Entity.InformationResource]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [Profile.Data].[tmp_ms_xx_Publication.Entity.InformationResource] (
    [EntityID]   INT            IDENTITY (1, 1) NOT NULL,
    [PMID]       INT            NULL,
    [PMCID]      NVARCHAR (55)  NULL,
    [MPID]       NVARCHAR (50)  NULL,
    [EntityName] VARCHAR (4000) NULL,
    [EntityDate] DATETIME       NULL,
    [Reference]  VARCHAR (MAX)  NULL,
    [Source]     VARCHAR (25)   NULL,
    [URL]        VARCHAR (2000) NULL,
    [PubYear]    INT            NULL,
    [YearWeight] FLOAT (53)     NULL,
    [SummaryXML] XML            NULL,
    [IsActive]   BIT            NULL,
    CONSTRAINT [tmp_ms_xx_constraint_PK__Publication.Enti__6892926B] PRIMARY KEY CLUSTERED ([EntityID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [Profile.Data].[Publication.Entity.InformationResource])
    BEGIN
        SET IDENTITY_INSERT [Profile.Data].[tmp_ms_xx_Publication.Entity.InformationResource] ON;
        INSERT INTO [Profile.Data].[tmp_ms_xx_Publication.Entity.InformationResource] ([EntityID], [PMID], [MPID], [EntityName], [EntityDate], [Reference], [Source], [URL], [PubYear], [YearWeight], [SummaryXML], [IsActive])
        SELECT   [EntityID],
                 [PMID],
                 [MPID],
                 [EntityName],
                 [EntityDate],
                 [Reference],
                 [Source],
                 [URL],
                 [PubYear],
                 [YearWeight],
                 [SummaryXML],
                 [IsActive]
        FROM     [Profile.Data].[Publication.Entity.InformationResource]
        ORDER BY [EntityID] ASC;
        SET IDENTITY_INSERT [Profile.Data].[tmp_ms_xx_Publication.Entity.InformationResource] OFF;
    END

DROP TABLE [Profile.Data].[Publication.Entity.InformationResource];

EXECUTE sp_rename N'[Profile.Data].[tmp_ms_xx_Publication.Entity.InformationResource]', N'Publication.Entity.InformationResource';

EXECUTE sp_rename N'[Profile.Data].[tmp_ms_xx_constraint_PK__Publication.Enti__6892926B]', N'PK__Publication.Enti__6892926B', N'OBJECT';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [Profile.Data].[Publication.Entity.InformationResource].[idx_mpid]...';


GO
CREATE NONCLUSTERED INDEX [idx_mpid]
    ON [Profile.Data].[Publication.Entity.InformationResource]([MPID] ASC);


GO
PRINT N'Creating [Profile.Data].[Publication.Entity.InformationResource].[idx_pmid]...';


GO
CREATE NONCLUSTERED INDEX [idx_pmid]
    ON [Profile.Data].[Publication.Entity.InformationResource]([PMID] ASC);


GO
PRINT N'Creating [Profile.Data].[Publication.Entity.InformationResource].[idx_PublicationEntityInformationResourceIsActive]...';


GO
CREATE NONCLUSTERED INDEX [idx_PublicationEntityInformationResourceIsActive]
    ON [Profile.Data].[Publication.Entity.InformationResource]([IsActive] ASC)
    INCLUDE([EntityID], [PubYear], [PMID], [EntityDate], [Reference]);


GO
PRINT N'Creating [Profile.Data].[Publication.Entity.InformationResource].[missing_index_73031]...';


GO
CREATE NONCLUSTERED INDEX [missing_index_73031]
    ON [Profile.Data].[Publication.Entity.InformationResource]([IsActive] ASC)
    INCLUDE([EntityID], [PubYear], [PMID], [EntityDate], [Reference]);


GO
PRINT N'Starting rebuilding table [Profile.Data].[Publication.PubMed.General]...';


GO
BEGIN TRANSACTION;

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

SET XACT_ABORT ON;

CREATE TABLE [Profile.Data].[tmp_ms_xx_Publication.PubMed.General] (
    [PMID]                 INT            NOT NULL,
    [PMCID]                NVARCHAR (55)  NULL,
    [Owner]                VARCHAR (50)   NULL,
    [Status]               VARCHAR (50)   NULL,
    [PubModel]             VARCHAR (50)   NULL,
    [Volume]               VARCHAR (255)  NULL,
    [Issue]                VARCHAR (255)  NULL,
    [MedlineDate]          VARCHAR (255)  NULL,
    [JournalYear]          VARCHAR (50)   NULL,
    [JournalMonth]         VARCHAR (50)   NULL,
    [JournalDay]           VARCHAR (50)   NULL,
    [JournalTitle]         VARCHAR (1000) NULL,
    [ISOAbbreviation]      VARCHAR (100)  NULL,
    [MedlineTA]            VARCHAR (1000) NULL,
    [ArticleTitle]         VARCHAR (4000) NULL,
    [MedlinePgn]           VARCHAR (255)  NULL,
    [AbstractText]         TEXT           NULL,
    [ArticleDateType]      VARCHAR (50)   NULL,
    [ArticleYear]          VARCHAR (10)   NULL,
    [ArticleMonth]         VARCHAR (10)   NULL,
    [ArticleDay]           VARCHAR (10)   NULL,
    [Affiliation]          VARCHAR (4000) NULL,
    [AuthorListCompleteYN] VARCHAR (1)    NULL,
    [GrantListCompleteYN]  VARCHAR (1)    NULL,
    [PubDate]              DATETIME       NULL,
    [Authors]              VARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([PMID] ASC)
);

IF EXISTS (SELECT TOP 1 1 
           FROM   [Profile.Data].[Publication.PubMed.General])
    BEGIN
        INSERT INTO [Profile.Data].[tmp_ms_xx_Publication.PubMed.General] ([PMID], [Owner], [Status], [PubModel], [Volume], [Issue], [MedlineDate], [JournalYear], [JournalMonth], [JournalDay], [JournalTitle], [ISOAbbreviation], [MedlineTA], [ArticleTitle], [MedlinePgn], [AbstractText], [ArticleDateType], [ArticleYear], [ArticleMonth], [ArticleDay], [Affiliation], [AuthorListCompleteYN], [GrantListCompleteYN], [PubDate], [Authors])
        SELECT   [PMID],
                 [Owner],
                 [Status],
                 [PubModel],
                 [Volume],
                 [Issue],
                 [MedlineDate],
                 [JournalYear],
                 [JournalMonth],
                 [JournalDay],
                 [JournalTitle],
                 [ISOAbbreviation],
                 [MedlineTA],
                 [ArticleTitle],
                 [MedlinePgn],
                 [AbstractText],
                 [ArticleDateType],
                 [ArticleYear],
                 [ArticleMonth],
                 [ArticleDay],
                 [Affiliation],
                 [AuthorListCompleteYN],
                 [GrantListCompleteYN],
                 [PubDate],
                 [Authors]
        FROM     [Profile.Data].[Publication.PubMed.General]
        ORDER BY [PMID] ASC;
    END

DROP TABLE [Profile.Data].[Publication.PubMed.General];

EXECUTE sp_rename N'[Profile.Data].[tmp_ms_xx_Publication.PubMed.General]', N'Publication.PubMed.General';

COMMIT TRANSACTION;

SET TRANSACTION ISOLATION LEVEL READ COMMITTED;


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_authors_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Author] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_pubtypes_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.PubType] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_pubtypes_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_keywords_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Keyword] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_keywords_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_accessions_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Accession] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_accessions_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_databanks_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Databank] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_databanks_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_chemicals_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Chemical] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_chemicals_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_mesh_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Mesh] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_mesh_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_investigators_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Investigator] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_investigators_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_pm_pubs_grants_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Grant] WITH NOCHECK
    ADD CONSTRAINT [FK_pm_pubs_grants_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Creating [Profile.Data].[FK_publications_include_pm_pubs_general]...';


GO
ALTER TABLE [Profile.Data].[Publication.Person.Include] WITH NOCHECK
    ADD CONSTRAINT [FK_publications_include_pm_pubs_general] FOREIGN KEY ([PMID]) REFERENCES [Profile.Data].[Publication.PubMed.General] ([PMID]);


GO
PRINT N'Refreshing [Profile.Data].[fnPublication.Person.GetPublications]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[fnPublication.Person.GetPublications]';


GO
PRINT N'Refreshing [ORNG.].[vwAppPersonData]...';


GO
EXECUTE sp_refreshsqlmodule N'[ORNG.].[vwAppPersonData]';


GO
PRINT N'Refreshing [Profile.Data].[vwPublication.Entity.InformationResource]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[vwPublication.Entity.InformationResource]';


GO
PRINT N'Refreshing [Profile.Data].[vwPublication.Entity.Concept]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[vwPublication.Entity.Concept]';


GO
PRINT N'Refreshing [Profile.Data].[vwPublication.Entity.Concept.MajorTopicList]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[vwPublication.Entity.Concept.MajorTopicList]';


GO
PRINT N'Refreshing [Profile.Data].[vwPublication.Entity.Concept.MinorTopicList]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[vwPublication.Entity.Concept.MinorTopicList]';


GO
PRINT N'Refreshing [Profile.Data].[vwPublication.Entity.General]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[vwPublication.Entity.General]';


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
SELECT	Row_Number() OVER (ORDER BY (SELECT 1)),
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
SELECT  Row_Number() OVER (ORDER BY (SELECT 1)),
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
            EditSecurityGroup
          )
  SELECT    Row_Number() OVER (ORDER BY (SELECT 1)),
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
			R.x.value('EditSecurityGroup[1]','varchar(max)')
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
             [_PropertyGroupLabel]
           ) 
	SELECT	R.x.value('PropertyGroupURI[1]','varchar(max)'),
			R.x.value('SortOrder[1]','varchar(max)'),
			R.x.value('_PropertyGroupLabel[1]','varchar(max)')
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
	          [_TagName] ,
	          [_PropertyLabel]
	        ) 
	SELECT	R.x.value('PropertyGroupURI[1]','varchar(max)'),
			R.x.value('PropertyURI[1]','varchar(max)'),
			R.x.value('SortOrder[1]','varchar(max)'),
			(case when CAST(R.x.query('CustomDisplayModule[1]/*') AS NVARCHAR(MAX))<>'' then R.x.query('CustomDisplayModule[1]/*') else NULL end),
			(case when CAST(R.x.query('CustomEditModule[1]/*') AS NVARCHAR(MAX))<>'' then R.x.query('CustomEditModule[1]/*') else NULL end),
			R.x.value('_TagName[1]','varchar(max)'),
			R.x.value('_PropertyLabel[1]','varchar(max)')
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
  SELECT  Row_Number() OVER (ORDER BY (SELECT 1)),
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

   ---------------------------------------------------------------
-- [ORNG.]
---------------------------------------------------------------
	INSERT INTO [ORNG.].[Apps]
		(
			[AppID],
			[Name],
			[Url],
			[PersonFilterID],
			[OAuthSecret],
			[Enabled]
		)
   SELECT	R.x.value('AppID[1]','varchar(max)'),
			R.x.value('Name[1]','varchar(max)'),
			R.x.value('URL[1]','varchar(max)'),
			R.x.value('PersonFilterID[1]','varchar(max)'),
			R.x.value('OAuthSecret[1]','varchar(max)'),
			R.x.value('Enabled[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORNG.].[Apps]'']')
                      x
          ) t
  CROSS APPLY x.nodes('//Row') AS R ( x )

  	INSERT INTO [ORNG.].[AppViews]
		(
			[AppID],
			[Page],
			[View],
			[ChromeID],
			[Visibility],
			[DisplayOrder],
			[OptParams]
		)
   SELECT	R.x.value('AppID[1]','varchar(max)'),
			R.x.value('Page[1]','varchar(max)'),
			R.x.value('View[1]','varchar(max)'),
			R.x.value('ChromeID[1]','varchar(max)'),
			R.x.value('Visibility[1]','varchar(max)'),
			R.x.value('DisplayOrder[1]','varchar(max)'),
			R.x.value('OptParams[1]','varchar(max)')
	 FROM    (SELECT
                      @x.query
                      ('Import[1]/Table[@Name=''[ORNG.].[AppViews]'']')
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
									select	JobGroup 'JobGroup',
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
									select	Class 'Class',
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
									select  DataMapGroup 'DataMapGroup',
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
											EditSecurityGroup 'EditSecurityGroup'
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
											_PropertyGroupLabel '_PropertyGroupLabel'
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
											_TagName '_TagName',
											_PropertyLabel '_PropertyLabel'
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
									select	type 'type',
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
					),
					--------------------------------------------------------
					-- [ORNG.]
					--------------------------------------------------------					
					(
						select '[ORNG.].[Apps]' 'Table/@Name',
						(
							SELECT	AppID 'AppID',
									Name 'Name',
									Url 'URL',
									PersonFilterID 'PersonFilterID',
									OAuthSecret 'OAuthSecret',
									[Enabled] 'Enabled'
								from [ORNG.].[Apps]
									for xml path('Row'), type
						) 'Table'  
						for xml path(''), type
					),
					(
						select '[ORNG.].[AppViews]' 'Table/@Name',
						(
							SELECT	[AppID] 'AppID',
									[Page] 'Page',
									[View] 'View',
									[ChromeID] 'ChromeID',
									[Visibility] 'Visibility',
									[DisplayOrder] 'DisplayOrder',
									[OptParams] 'OptParams'
								from [ORNG.].[AppViews]
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
GO
PRINT N'Altering [Profile.Data].[Publication.Entity.UpdateEntityOnePerson]...';


GO
ALTER PROCEDURE [Profile.Data].[Publication.Entity.UpdateEntityOnePerson]
	@PersonID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update InformationResource entities
	-- *******************************************************************
	-- *******************************************************************
 
 
	----------------------------------------------------------------------
	-- Get a list of current publications
	----------------------------------------------------------------------
 
	CREATE TABLE #Publications
	(
		PMID INT NULL ,
		MPID NVARCHAR(50) NULL ,
		PMCID NVARCHAR(55) NULL,
		EntityDate DATETIME NULL ,
		Reference VARCHAR(MAX) NULL ,
		Source VARCHAR(25) NULL ,
		URL VARCHAR(1000) NULL ,
		Title VARCHAR(4000) NULL
	)
 
	-- Add PMIDs to the publications temp table
	INSERT  INTO #Publications
            ( PMID ,
			  PMCID,
              EntityDate ,
              Reference ,
              Source ,
              URL ,
              Title
            )
            SELECT -- Get Pub Med pubs
                    PG.PMID ,
					PG.PMCID,
                    EntityDate = PG.PubDate,
                    Reference = REPLACE([Profile.Cache].[fnPublication.Pubmed.General2Reference](PG.PMID,
                                                              PG.ArticleDay,
                                                              PG.ArticleMonth,
                                                              PG.ArticleYear,
                                                              PG.ArticleTitle,
                                                              PG.Authors,
                                                              PG.AuthorListCompleteYN,
                                                              PG.Issue,
                                                              PG.JournalDay,
                                                              PG.JournalMonth,
                                                              PG.JournalYear,
                                                              PG.MedlineDate,
                                                              PG.MedlinePgn,
                                                              PG.MedlineTA,
                                                              PG.Volume, 0),
                                        CHAR(11), '') ,
                    Source = 'PubMed',
                    URL = 'http://www.ncbi.nlm.nih.gov/pubmed/' + CAST(ISNULL(PG.pmid, '') AS VARCHAR(20)),
                    Title = left((case when IsNull(PG.ArticleTitle,'') <> '' then PG.ArticleTitle else 'Untitled Publication' end),4000)
            FROM    [Profile.Data].[Publication.PubMed.General] PG
			WHERE	PG.PMID IN (
						SELECT PMID 
						FROM [Profile.Data].[Publication.Person.Include]
						WHERE PMID IS NOT NULL AND PersonID = @PersonID
					)
					AND PG.PMID NOT IN (
						SELECT PMID
						FROM [Profile.Data].[Publication.Entity.InformationResource]
						WHERE PMID IS NOT NULL
					)
 
	-- Add MPIDs to the publications temp table
	INSERT  INTO #Publications
            ( MPID ,
              EntityDate ,
			  Reference ,
			  Source ,
              URL ,
              Title
            )
            SELECT  MPID ,
                    EntityDate ,
 
 
                     Reference = REPLACE(authors
										+ (CASE WHEN IsNull(article,'') <> '' THEN article + '. ' ELSE '' END)
										+ (CASE WHEN IsNull(pub,'') <> '' THEN pub + '. ' ELSE '' END)
										+ y
                                        + CASE WHEN y <> ''
                                                    AND vip <> '' THEN '; '
                                               ELSE ''
                                          END + vip
                                        + CASE WHEN y <> ''
                                                    OR vip <> '' THEN '.'
                                               ELSE ''
                                          END, CHAR(11), '') ,
                    Source = 'Custom' ,
                    URL = url,
                    Title = left((case when IsNull(article,'')<>'' then article when IsNull(pub,'')<>'' then pub else 'Untitled Publication' end),4000)
            FROM    ( SELECT    MPID ,
                                EntityDate ,
                                url ,
                                authors = CASE WHEN authors = '' THEN ''
                                               WHEN RIGHT(authors, 1) = '.'
                                               THEN LEFT(authors,
                                                         LEN(authors) - 1)
                                               ELSE authors
                                          END ,
                                article = CASE WHEN article = '' THEN ''
                                               WHEN RIGHT(article, 1) = '.'
                                               THEN LEFT(article,
                                                         LEN(article) - 1)
                                               ELSE article
                                          END ,
                                pub = CASE WHEN pub = '' THEN ''
                                           WHEN RIGHT(pub, 1) = '.'
                                           THEN LEFT(pub, LEN(pub) - 1)
                                           ELSE pub
                                      END ,
                                y ,
                                vip
                      FROM      ( SELECT    MPG.mpid ,
                                            EntityDate = MPG.publicationdt ,
                                            authors = CASE WHEN RTRIM(LTRIM(COALESCE(MPG.authors,
                                                              ''))) = ''
                                                           THEN ''
                                                           WHEN RIGHT(COALESCE(MPG.authors,
                                                              ''), 1) = '.'
                                                            THEN  COALESCE(MPG.authors,
                                                              '') + ' '
                                                           ELSE COALESCE(MPG.authors,
                                                              '') + '. '
                                                      END ,
                                            url = CASE WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                            AND LEFT(COALESCE(MPG.url,
                                                              ''), 4) = 'http'
                                                       THEN MPG.url
                                                       WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                       THEN 'http://' + MPG.url
                                                       ELSE ''
                                                  END ,
                                            article = LTRIM(RTRIM(COALESCE(MPG.articletitle,
                                                              ''))) ,
                                            pub = LTRIM(RTRIM(COALESCE(MPG.pubtitle,
                                                              ''))) ,
                                            y = CASE WHEN MPG.publicationdt > '1/1/1901'
                                                     THEN CONVERT(VARCHAR(50), YEAR(MPG.publicationdt))
                                                     ELSE ''
                                                END ,
                                            vip = COALESCE(MPG.volnum, '')
                                            + CASE WHEN COALESCE(MPG.issuepub,
                                                              '') <> ''
                                                   THEN '(' + MPG.issuepub
                                                        + ')'
                                                   ELSE ''
                                              END
                                            + CASE WHEN ( COALESCE(MPG.paginationpub,
                                                              '') <> '' )
                                                        AND ( COALESCE(MPG.volnum,
                                                              '')
                                                              + COALESCE(MPG.issuepub,
                                                              '') <> '' )
                                                   THEN ':'
                                                   ELSE ''
                                              END + COALESCE(MPG.paginationpub,
                                                             '')
                                  FROM      [Profile.Data].[Publication.MyPub.General] MPG
                                  INNER JOIN [Profile.Data].[Publication.Person.Include] PL ON MPG.mpid = PL.mpid
                                                           AND PL.mpid NOT LIKE 'DASH%'
                                                           AND PL.mpid NOT LIKE 'ISI%'
                                                           AND PL.pmid IS NULL
                                                           AND PL.PersonID = @PersonID
									WHERE MPG.MPID NOT IN (
										SELECT MPID
										FROM [Profile.Data].[Publication.Entity.InformationResource]
										WHERE (MPID IS NOT NULL)
									)
                                ) T0
                    ) T0
 
	CREATE NONCLUSTERED INDEX idx_pmid on #publications(pmid)
	CREATE NONCLUSTERED INDEX idx_mpid on #publications(mpid)

	----------------------------------------------------------------------
	-- Update the Publication.Entity.InformationResource table
	----------------------------------------------------------------------
 
	-- Insert new publications
	INSERT INTO [Profile.Data].[Publication.Entity.InformationResource] (
			PMID,
			PMCID,
			MPID,
			EntityName,
			EntityDate,
			Reference,
			Source,
			URL,
			IsActive
		)
		SELECT 	PMID,
				PMCID,
				MPID,
				Title,
				EntityDate,
				Reference,
				Source,
				URL,
				1 IsActive
		FROM #publications
	-- Assign an EntityName, PubYear, and YearWeight
	UPDATE e
		SET --e.EntityName = 'Publication ' + CAST(e.EntityID as VARCHAR(50)),
			e.PubYear = year(e.EntityDate),
			e.YearWeight = (case when e.EntityDate is null then 0.5
							when year(e.EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,e.EntityDate,GetDate()) as float)/365.25/10)
							end)
		FROM [Profile.Data].[Publication.Entity.InformationResource] e,
			#publications p
		WHERE ((e.PMID = p.PMID) OR (e.MPID = p.MPID))
 
	-- *******************************************************************
	-- *******************************************************************
	-- Update Authorship entities
	-- *******************************************************************
	-- *******************************************************************
 
 	----------------------------------------------------------------------
	-- Get a list of current Authorship records
	----------------------------------------------------------------------

	CREATE TABLE #Authorship
	(
		EntityDate DATETIME NULL ,
		authorRank INT NULL,
		numberOfAuthors INT NULL,
		authorNameAsListed VARCHAR(255) NULL,
		AuthorWeight FLOAT NULL,
		AuthorPosition VARCHAR(1) NULL,
		PubYear INT NULL ,
		YearWeight FLOAT NULL ,
		PersonID INT NULL ,
		InformationResourceID INT NULL,
		PMID INT NULL,
		IsActive BIT
	)
 
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, e.PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE (e.PMID = i.PMID) and (e.PMID is not null) and (i.PersonID = @PersonID)
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, null PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE (e.MPID = i.MPID) and (e.MPID is not null) and (e.PMID is null) and (i.PersonID = @PersonID)
	CREATE NONCLUSTERED INDEX idx_person_pmid ON #Authorship(PersonID, PMID)
	CREATE NONCLUSTERED INDEX idx_person_pub ON #Authorship(PersonID, InformationResourceID)
 
	UPDATE a
		SET	a.authorRank=p.authorRank,
			a.numberOfAuthors=p.numberOfAuthors,
			a.authorNameAsListed=p.authorNameAsListed, 
			a.AuthorWeight=p.AuthorWeight, 
			a.AuthorPosition=p.AuthorPosition,
			a.PubYear=p.PubYear,
			a.YearWeight=p.YearWeight
		FROM #Authorship a, [Profile.Cache].[Publication.PubMed.AuthorPosition]  p
		WHERE a.PersonID = p.PersonID and a.PMID = p.PMID and a.PMID is not null
	UPDATE #authorship
		SET authorWeight = 0.5
		WHERE authorWeight IS NULL
	UPDATE #authorship
		SET authorPosition = 'U'
		WHERE authorPosition IS NULL
	UPDATE #authorship
		SET PubYear = year(EntityDate)
		WHERE PubYear IS NULL
	UPDATE #authorship
		SET	YearWeight = (case when EntityDate is null then 0.5
							when year(EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
							end)
		WHERE YearWeight IS NULL

	----------------------------------------------------------------------
	-- Update the Publication.Authorship table
	----------------------------------------------------------------------
 
	-- Set IsActive = 0 for Authorships that no longer exist
	UPDATE [Profile.Data].[Publication.Entity.Authorship]
		SET IsActive = 0
		WHERE PersonID = @PersonID
			AND InformationResourceID NOT IN (SELECT InformationResourceID FROM #authorship)
	-- Set IsActive = 1 for current Authorships and update data
	UPDATE e
		SET e.EntityDate = a.EntityDate,
			e.authorRank = a.authorRank,
			e.numberOfAuthors = a.numberOfAuthors,
			e.authorNameAsListed = a.authorNameAsListed,
			e.authorWeight = a.authorWeight,
			e.authorPosition = a.authorPosition,
			e.PubYear = a.PubYear,
			e.YearWeight = a.YearWeight,
			e.IsActive = 1
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.PersonID = e.PersonID and a.InformationResourceID = e.InformationResourceID
	-- Insert new Authorships
	INSERT INTO [Profile.Data].[Publication.Entity.Authorship] (
			EntityDate,
			authorRank,
			numberOfAuthors,
			authorNameAsListed,
			authorWeight,
			authorPosition,
			PubYear,
			YearWeight,
			PersonID,
			InformationResourceID,
			IsActive
		)
		SELECT 	EntityDate,
				authorRank,
				numberOfAuthors,
				authorNameAsListed,
				authorWeight,
				authorPosition,
				PubYear,
				YearWeight,
				PersonID,
				InformationResourceID,
				IsActive
		FROM #authorship a
		WHERE NOT EXISTS (
			SELECT *
			FROM [Profile.Data].[Publication.Entity.Authorship] e
			WHERE a.PersonID = e.PersonID and a.InformationResourceID = e.InformationResourceID
		)
	-- Assign an EntityName
	UPDATE [Profile.Data].[Publication.Entity.Authorship]
		SET EntityName = 'Authorship ' + CAST(EntityID as VARCHAR(50))
		WHERE PersonID = @PersonID AND EntityName is null


	-- *******************************************************************
	-- *******************************************************************
	-- Update RDF
	-- *******************************************************************
	-- *******************************************************************



	--------------------------------------------------------------
	-- Version 3 : Create stub RDF
	--------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND NetworkProperty IS NULL
					AND Property IS NULL
			UNION ALL
			SELECT *, '''' + CAST(@PersonID AS VARCHAR(50)) + '''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://xmlns.com/foaf/0.1/Person' 
					AND property = 'http://vivoweb.org/ontology/core#authorInAuthorship'
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END

	--select * from [Ontology.].DataMap


/*

	--------------------------------------------------------------
	-- Version 1 : Create all RDF using ProcessDataMap
	--------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND IsNull(property,'') <> 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND IsNull(property,'') NOT IN ('http://vivoweb.org/ontology/core#linkedAuthor','http://vivoweb.org/ontology/core#linkedInformationResource')
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND property = 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''' + CAST(@PersonID AS VARCHAR(50)) + '''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://xmlns.com/foaf/0.1/Person' 
					AND property = 'http://vivoweb.org/ontology/core#authorInAuthorship'
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		--print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END

*/


/*

	---------------------------------------------------------------------------------
	-- Version 2 : Create new entities using ProcessDataMap, and triples manually
	---------------------------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND IsNull(property,'') <> 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND IsNull(property,'') NOT IN ('http://vivoweb.org/ontology/core#linkedAuthor','http://vivoweb.org/ontology/core#linkedInformationResource')
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	--select * from #sql
	--return

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		--print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END


	CREATE TABLE #a (
		PersonID INT,
		AuthorshipID INT,
		InformationResourceID INT,
		IsActive BIT,
		PersonNodeID BIGINT,
		AuthorshipNodeID BIGINT,
		InformationResourceNodeID BIGINT,
		AuthorInAuthorshipTripleID BIGINT,
		LinkedAuthorTripleID BIGINT,
		LinkedInformationResourceTripleID BIGINT,
		InformationResourceInAuthorshipTripleID BIGINT,
		AuthorRank INT,
		EntityDate DATETIME,
		TripleWeight FLOAT,
		AuthorRecord INT
	)
	-- Get authorship records
	INSERT INTO #a (PersonID, AuthorshipID, InformationResourceID, IsActive, AuthorRank, EntityDate, TripleWeight, AuthorRecord)
		SELECT PersonID, EntityID, InformationResourceID, IsActive, 
				AuthorRank, EntityDate, IsNull(authorweight * yearweight,0),
				0
			FROM [Profile.Data].[Publication.Entity.Authorship]
			WHERE PersonID = @PersonID
		UNION ALL
		SELECT PersonID, EntityID, InformationResourceID, IsActive, 
				AuthorRank, EntityDate, IsNull(authorweight * yearweight,0),
				1
			FROM [Profile.Data].[Publication.Entity.Authorship]
			WHERE PersonID <> @PersonID 
				AND IsActive = 1
				AND InformationResourceID IN (
					SELECT InformationResourceID
					FROM [Profile.Data].[Publication.Entity.Authorship]
					WHERE PersonID = @PersonID
				)
	-- Get entity IDs
	UPDATE a
		SET a.PersonNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://xmlns.com/foaf/0.1/Person'
			AND m.InternalType = 'Person'
			AND m.InternalID = CAST(a.PersonID AS VARCHAR(50))
	UPDATE a
		SET a.AuthorshipNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://vivoweb.org/ontology/core#Authorship'
			AND m.InternalType = 'Authorship'
			AND m.InternalID = CAST(a.AuthorshipID AS VARCHAR(50))
	UPDATE a
		SET a.InformationResourceNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://vivoweb.org/ontology/core#InformationResource'
			AND m.InternalType = 'InformationResource'
			AND m.InternalID = CAST(a.InformationResourceID AS VARCHAR(50))
	-- Get triple IDs
	UPDATE a
		SET a.AuthorInAuthorshipTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.PersonNodeID IS NOT NULL AND a.AuthorshipNodeID IS NOT NULL
			AND t.subject = a.PersonNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship')
			AND t.object = a.AuthorshipNodeID
	UPDATE a
		SET a.LinkedAuthorTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.PersonNodeID IS NOT NULL AND a.AuthorshipNodeID IS NOT NULL
			AND t.subject = a.AuthorshipNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedAuthor')
			AND t.object = a.PersonNodeID
	UPDATE a
		SET a.LinkedInformationResourceTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.AuthorshipNodeID IS NOT NULL AND a.InformationResourceID IS NOT NULL
			AND t.subject = a.AuthorshipNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource')
			AND t.object = a.InformationResourceNodeID
	UPDATE a
		SET a.InformationResourceInAuthorshipTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.AuthorshipNodeID IS NOT NULL AND a.InformationResourceID IS NOT NULL
			AND t.subject = a.InformationResourceNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#informationResourceInAuthorship')
			AND t.object = a.AuthorshipNodeID
	
	--select * from #a
	--return
	--select * from [ontology.].datamap



	SELECT a.IsActive, a.subject, m._PropertyNode predicate, a.object, 
			a.TripleWeight, 0 ObjectType, a.SortOrder,
			IsNull(s.ViewSecurityGroup, m.ViewSecurityGroup) ViewSecurityGroup,
			a.TripleID, t.SortOrder ExistingSortOrder, X
		INTO #b
		FROM (
				SELECT AuthorshipNodeID subject, InformationResourceNodeID object, TripleWeight, 
						'http://vivoweb.org/ontology/core#Authorship' Class,
						'http://vivoweb.org/ontology/core#linkedInformationResource' Property,
						1 SortOrder,
						IsActive,
						LinkedInformationResourceTripleID TripleID,
						1 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
				UNION ALL
				SELECT AuthorshipNodeID subject, PersonNodeID object, 1 TripleWeight,
						'http://vivoweb.org/ontology/core#Authorship' Class,
						'http://vivoweb.org/ontology/core#linkedAuthor' Property,
						1 SortOrder,
						IsActive,
						LinkedAuthorTripleID TripleID,
						2 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
				UNION ALL
				SELECT InformationResourceNodeID subject, AuthorshipNodeID object, TripleWeight, 
						'http://vivoweb.org/ontology/core#InformationResource' Class,
						'http://vivoweb.org/ontology/core#informationResourceInAuthorship' Property,
						row_number() over (partition by InformationResourceNodeID, IsActive order by AuthorRank, t.SortOrder, AuthorshipNodeID) SortOrder,
						IsActive,
						InformationResourceInAuthorshipTripleID TripleID,
						3 X
					FROM #a a
						LEFT OUTER JOIN [RDF.].[Triple] t
						ON a.InformationResourceInAuthorshipTripleID = t.TripleID
					--WHERE IsActive = 1
				UNION ALL
				SELECT PersonNodeID subject, AuthorshipNodeID object, 1 TripleWeight, 
						'http://xmlns.com/foaf/0.1/Person' Class,
						'http://vivoweb.org/ontology/core#authorInAuthorship' Property,
						row_number() over (partition by PersonNodeID, IsActive order by EntityDate desc) SortOrder,
						IsActive,
						AuthorInAuthorshipTripleID TripleID,
						4 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
			) a
			INNER JOIN [Ontology.].[DataMap] m
				ON m.Class = a.Class AND m.NetworkProperty IS NULL AND m.Property = a.Property
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON a.TripleID = t.TripleID
			LEFT OUTER JOIN [RDF.Security].[NodeProperty] s
				ON s.NodeID = a.subject
					AND s.Property = m._PropertyNode

	--SELECT * FROM #b ORDER BY X, subject, property, IsActive, sortorder

	-- Delete
	DELETE
		FROM [RDF.].Triple
		WHERE TripleID IN (
			SELECT TripleID
			FROM #b
			WHERE IsActive = 0 AND TripleID IS NOT NULL
		)
	--select @@ROWCOUNT

	-- Update
	UPDATE t
		SET t.SortOrder = b.SortOrder
		FROM [RDF.].Triple t
			INNER JOIN #b b
			ON t.TripleID = b.TripleID
				AND b.IsActive = 1 
				AND b.TripleID IS NOT NULL
				AND b.SortOrder <> b.ExistingSortOrder
	--select @@ROWCOUNT

	-- Insert
	INSERT INTO [RDF.].Triple (Subject,Predicate,Object,TripleHash,Weight,Reitification,ObjectType,SortOrder,ViewSecurityGroup,Graph)
		SELECT Subject,Predicate,Object,
				[RDF.].fnTripleHash(Subject,Predicate,Object),
				TripleWeight,NULL,0,SortOrder,ViewSecurityGroup,1
			FROM #b
			WHERE IsActive = 1 AND TripleID IS NULL
	--select @@ROWCOUNT

*/


END
GO
PRINT N'Altering [Profile.Data].[Publication.Entity.UpdateEntity]...';


GO
ALTER PROCEDURE [Profile.Data].[Publication.Entity.UpdateEntity]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update InformationResource entities
	-- *******************************************************************
	-- *******************************************************************
 
 
	----------------------------------------------------------------------
	-- Get a list of current publications
	----------------------------------------------------------------------

	CREATE TABLE #Publications
	(
		PMID INT NULL ,
		MPID NVARCHAR(50) NULL ,
		PMCID NVARCHAR(55) NULL,
		EntityDate DATETIME NULL ,
		Reference VARCHAR(MAX) NULL ,
		Source VARCHAR(25) NULL ,
		URL VARCHAR(1000) NULL ,
		Title VARCHAR(4000) NULL ,
		EntityID INT NULL
	)
 
	-- Add PMIDs to the publications temp table
	INSERT  INTO #Publications
            ( PMID ,
			  PMCID,
              EntityDate ,
              Reference ,
              Source ,
              URL ,
              Title
            )
            SELECT -- Get Pub Med pubs
                    PG.PMID ,
					PG.PMCID,
                    EntityDate = PG.PubDate,
                    Reference = REPLACE([Profile.Cache].[fnPublication.Pubmed.General2Reference](PG.PMID,
                                                              PG.ArticleDay,
                                                              PG.ArticleMonth,
                                                              PG.ArticleYear,
                                                              PG.ArticleTitle,
                                                              PG.Authors,
                                                              PG.AuthorListCompleteYN,
                                                              PG.Issue,
                                                              PG.JournalDay,
                                                              PG.JournalMonth,
                                                              PG.JournalYear,
                                                              PG.MedlineDate,
                                                              PG.MedlinePgn,
                                                              PG.MedlineTA,
                                                              PG.Volume, 0),
                                        CHAR(11), '') ,
                    Source = 'PubMed',
                    URL = 'http://www.ncbi.nlm.nih.gov/pubmed/' + CAST(ISNULL(PG.pmid, '') AS VARCHAR(20)),
                    Title = left((case when IsNull(PG.ArticleTitle,'') <> '' then PG.ArticleTitle else 'Untitled Publication' end),4000)
            FROM    [Profile.Data].[Publication.PubMed.General] PG
			WHERE	PG.PMID IN (
						SELECT PMID 
						FROM [Profile.Data].[Publication.Person.Include]
						WHERE PMID IS NOT NULL )
 
	-- Add MPIDs to the publications temp table
	INSERT  INTO #Publications
            ( MPID ,
              EntityDate ,
			  Reference ,
			  Source ,
              URL ,
              Title
            )
            SELECT  MPID ,
                    EntityDate ,
                    Reference = REPLACE(authors
										+ (CASE WHEN IsNull(article,'') <> '' THEN article + '. ' ELSE '' END)
										+ (CASE WHEN IsNull(pub,'') <> '' THEN pub + '. ' ELSE '' END)
										+ y
                                        + CASE WHEN y <> ''
                                                    AND vip <> '' THEN '; '
                                               ELSE ''
                                          END + vip
                                        + CASE WHEN y <> ''
                                                    OR vip <> '' THEN '.'
                                               ELSE ''
                                          END, CHAR(11), '') ,
                    Source = 'Custom' ,
                    URL = url,
                    Title = left((case when IsNull(article,'')<>'' then article when IsNull(pub,'')<>'' then pub else 'Untitled Publication' end),4000)
            FROM    ( SELECT    MPID ,
                                EntityDate ,
                                url ,
                                authors = CASE WHEN authors = '' THEN ''
                                               WHEN RIGHT(authors, 1) = '.'
                                               THEN LEFT(authors,
                                                         LEN(authors) - 1)
                                               ELSE authors
                                          END ,
                                article = CASE WHEN article = '' THEN ''
                                               WHEN RIGHT(article, 1) = '.'
                                               THEN LEFT(article,
                                                         LEN(article) - 1)
                                               ELSE article
                                          END ,
                                pub = CASE WHEN pub = '' THEN ''
                                           WHEN RIGHT(pub, 1) = '.'
                                           THEN LEFT(pub, LEN(pub) - 1)
                                           ELSE pub
                                      END ,
                                y ,
                                vip
                      FROM      ( SELECT    MPG.mpid ,
                                            EntityDate = MPG.publicationdt ,
                                            authors = CASE WHEN RTRIM(LTRIM(COALESCE(MPG.authors,
                                                              ''))) = ''
                                                           THEN ''
                                                           WHEN RIGHT(COALESCE(MPG.authors,
                                                              ''), 1) = '.'
                                                            THEN  COALESCE(MPG.authors,
                                                              '') + ' '
                                                           ELSE COALESCE(MPG.authors,
                                                              '') + '. '
                                                      END ,
                                            url = CASE WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                            AND LEFT(COALESCE(MPG.url,
                                                              ''), 4) = 'http'
                                                       THEN MPG.url
                                                       WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                       THEN 'http://' + MPG.url
                                                       ELSE ''
                                                  END ,
                                            article = LTRIM(RTRIM(COALESCE(MPG.articletitle,
                                                              ''))) ,
                                            pub = LTRIM(RTRIM(COALESCE(MPG.pubtitle,
                                                              ''))) ,
                                            y = CASE WHEN MPG.publicationdt > '1/1/1901'
                                                     THEN CONVERT(VARCHAR(50), YEAR(MPG.publicationdt))
                                                     ELSE ''
                                                END ,
                                            vip = COALESCE(MPG.volnum, '')
                                            + CASE WHEN COALESCE(MPG.issuepub,
                                                              '') <> ''
                                                   THEN '(' + MPG.issuepub
                                                        + ')'
                                                   ELSE ''
                                              END
                                            + CASE WHEN ( COALESCE(MPG.paginationpub,
                                                              '') <> '' )
                                                        AND ( COALESCE(MPG.volnum,
                                                              '')
                                                              + COALESCE(MPG.issuepub,
                                                              '') <> '' )
                                                   THEN ':'
                                                   ELSE ''
                                              END + COALESCE(MPG.paginationpub,
                                                             '')
                                  FROM      [Profile.Data].[Publication.MyPub.General] MPG
                                  INNER JOIN [Profile.Data].[Publication.Person.Include] PL ON MPG.mpid = PL.mpid
                                                           AND PL.mpid NOT LIKE 'DASH%'
                                                           AND PL.mpid NOT LIKE 'ISI%'
                                                           AND PL.pmid IS NULL
                                ) T0
                    ) T0
 
	CREATE NONCLUSTERED INDEX idx_pmid on #publications(pmid)
	CREATE NONCLUSTERED INDEX idx_mpid on #publications(mpid)

	----------------------------------------------------------------------
	-- Update the Publication.Entity.InformationResource table
	----------------------------------------------------------------------

	-- Determine which publications already exist
	UPDATE p
		SET p.EntityID = e.EntityID
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.PMID = e.PMID and p.PMID is not null
	UPDATE p
		SET p.EntityID = e.EntityID
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.MPID = e.MPID and p.MPID is not null
	CREATE NONCLUSTERED INDEX idx_entityid on #publications(EntityID)

	-- Deactivate old publications
	UPDATE e
		SET e.IsActive = 0
		FROM [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE e.EntityID NOT IN (SELECT EntityID FROM #publications)

	-- Update the data for existing publications
	UPDATE e
		SET e.EntityDate = p.EntityDate,
			e.pmcid = p.pmcid,
			e.Reference = p.Reference,
			e.Source = p.Source,
			e.URL = p.URL,
			e.EntityName = p.Title,
			e.IsActive = 1
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.EntityID = e.EntityID and p.EntityID is not null

	-- Insert new publications
	INSERT INTO [Profile.Data].[Publication.Entity.InformationResource] (
			PMID,
			PMCID,
			MPID,
			EntityName,
			EntityDate,
			Reference,
			Source,
			URL,
			IsActive,
			PubYear,
			YearWeight
		)
		SELECT 	PMID,
				PMCID,
				MPID,
				Title,
				EntityDate,
				Reference,
				Source,
				URL,
				1 IsActive,
				PubYear = year(EntityDate),
				YearWeight = (case when EntityDate is null then 0.5
								when year(EntityDate) <= 1901 then 0.5
								else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
								end)
		FROM #publications
		WHERE EntityID IS NULL

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update Authorship entities
	-- *******************************************************************
	-- *******************************************************************
 
 	----------------------------------------------------------------------
	-- Get a list of current Authorship records
	----------------------------------------------------------------------

	CREATE TABLE #Authorship
	(
		EntityDate DATETIME NULL ,
		authorRank INT NULL,
		numberOfAuthors INT NULL,
		authorNameAsListed VARCHAR(255) NULL,
		AuthorWeight FLOAT NULL,
		AuthorPosition VARCHAR(1) NULL,
		PubYear INT NULL ,
		YearWeight FLOAT NULL ,
		PersonID INT NULL ,
		InformationResourceID INT NULL,
		PMID INT NULL,
		IsActive BIT,
		EntityID INT
	)
 
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, e.PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE e.PMID = i.PMID and e.PMID is not null
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, null PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE (e.MPID = i.MPID) and (e.MPID is not null) and (e.PMID is null)
	CREATE NONCLUSTERED INDEX idx_person_pmid ON #Authorship(PersonID, PMID)
	CREATE NONCLUSTERED INDEX idx_person_pub ON #Authorship(PersonID, InformationResourceID)

	UPDATE a
		SET	a.authorRank=p.authorRank,
			a.numberOfAuthors=p.numberOfAuthors,
			a.authorNameAsListed=p.authorNameAsListed, 
			a.AuthorWeight=p.AuthorWeight, 
			a.AuthorPosition=p.AuthorPosition,
			a.PubYear=p.PubYear,
			a.YearWeight=p.YearWeight
		FROM #Authorship a, [Profile.Cache].[Publication.PubMed.AuthorPosition]  p
		WHERE a.PersonID = p.PersonID and a.PMID = p.PMID and a.PMID is not null
	UPDATE #authorship
		SET authorWeight = 0.5
		WHERE authorWeight IS NULL
	UPDATE #authorship
		SET authorPosition = 'U'
		WHERE authorPosition IS NULL
	UPDATE #authorship
		SET PubYear = year(EntityDate)
		WHERE PubYear IS NULL
	UPDATE #authorship
		SET	YearWeight = (case when EntityDate is null then 0.5
							when year(EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
							end)
		WHERE YearWeight IS NULL

	----------------------------------------------------------------------
	-- Update the Publication.Authorship table
	----------------------------------------------------------------------

	-- Determine which authorships already exist
	UPDATE a
		SET a.EntityID = e.EntityID
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.PersonID = e.PersonID and a.InformationResourceID = e.InformationResourceID
 	CREATE NONCLUSTERED INDEX idx_entityid on #authorship(EntityID)

	-- Deactivate old authorships
	UPDATE a
		SET a.IsActive = 0
		FROM [Profile.Data].[Publication.Entity.Authorship] a
		WHERE a.EntityID NOT IN (SELECT EntityID FROM #authorship)

	-- Update the data for existing authorships
	UPDATE e
		SET e.EntityDate = a.EntityDate,
			e.authorRank = a.authorRank,
			e.numberOfAuthors = a.numberOfAuthors,
			e.authorNameAsListed = a.authorNameAsListed,
			e.authorWeight = a.authorWeight,
			e.authorPosition = a.authorPosition,
			e.PubYear = a.PubYear,
			e.YearWeight = a.YearWeight,
			e.IsActive = 1
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.EntityID = e.EntityID and a.EntityID is not null

	-- Insert new Authorships
	INSERT INTO [Profile.Data].[Publication.Entity.Authorship] (
			EntityDate,
			authorRank,
			numberOfAuthors,
			authorNameAsListed,
			authorWeight,
			authorPosition,
			PubYear,
			YearWeight,
			PersonID,
			InformationResourceID,
			IsActive
		)
		SELECT 	EntityDate,
				authorRank,
				numberOfAuthors,
				authorNameAsListed,
				authorWeight,
				authorPosition,
				PubYear,
				YearWeight,
				PersonID,
				InformationResourceID,
				IsActive
		FROM #authorship a
		WHERE EntityID IS NULL

	-- Assign an EntityName
	UPDATE [Profile.Data].[Publication.Entity.Authorship]
		SET EntityName = 'Authorship ' + CAST(EntityID as VARCHAR(50))
		WHERE EntityName is null
 
END
GO
PRINT N'Altering [Profile.Module].[CustomViewAuthorInAuthorship.GetList]...';


GO
ALTER PROCEDURE [Profile.Module].[CustomViewAuthorInAuthorship.GetList]
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
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage
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
	order by p.EntityDate desc

/*
	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.mpid prns_mpid
	from [RDF.].[Triple] t
		inner join [RDF.].[Triple] v
			on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
			and t.object = v.subject and v.predicate = @LinkedInformationResource
			and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			and ((v.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (v.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (v.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] a
			on t.object = a.NodeID
			and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on v.object = i.NodeID
			and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on m.InternalID = p.EntityID
	order by p.EntityDate desc
*/

END
GO
PRINT N'Altering [Profile.Data].[Publication.Pubmed.ParsePubMedXML]...';


GO
ALTER procedure [Profile.Data].[Publication.Pubmed.ParsePubMedXML]
	@pmid int
AS
BEGIN
	SET NOCOUNT ON;


	UPDATE [Profile.Data].[Publication.PubMed.AllXML] set ParseDT = GetDate() where pmid = @pmid


	delete from [Profile.Data].[Publication.PubMed.Author] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Investigator] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.PubType] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Chemical] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Databank] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Accession] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Keyword] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Grant] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Mesh] where pmid = @pmid
	
	-- Update pm_pubs_general if record exists, else insert new record
	IF EXISTS (SELECT 1 FROM [Profile.Data].[Publication.PubMed.General] WHERE pmid = @pmid) 
		BEGIN 
		
			UPDATE g
			   SET 	Owner= nref.value('@Owner[1]','varchar(max)') ,
							Status = nref.value('@Status[1]','varchar(max)') ,
							PubModel=nref.value('Article[1]/@PubModel','varchar(max)') ,
							Volume	 = nref.value('Article[1]/Journal[1]/JournalIssue[1]/Volume[1]','varchar(max)') ,
							Issue = nref.value('Article[1]/Journal[1]/JournalIssue[1]/Issue[1]','varchar(max)') ,
							MedlineDate = nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/MedlineDate[1]','varchar(max)') ,
							JournalYear = nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Year[1]','varchar(max)') ,
							JournalMonth = nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Month[1]','varchar(max)') ,
							JournalDay=nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Day[1]','varchar(max)') ,
							JournalTitle = nref.value('Article[1]/Journal[1]/Title[1]','varchar(max)') ,
							ISOAbbreviation=nref.value('Article[1]/Journal[1]/ISOAbbreviation[1]','varchar(max)') ,
							MedlineTA = nref.value('MedlineJournalInfo[1]/MedlineTA[1]','varchar(max)') ,
							ArticleTitle = nref.value('Article[1]/ArticleTitle[1]','varchar(max)') ,
							MedlinePgn = nref.value('Article[1]/Pagination[1]/MedlinePgn[1]','varchar(max)') ,
							AbstractText = nref.value('Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') ,
							ArticleDateType= nref.value('Article[1]/ArticleDate[1]/@DateType[1]','varchar(max)') ,
							ArticleYear = nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(max)') ,
							ArticleMonth = nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(max)') ,
							ArticleDay = nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(max)') ,
							Affiliation = COALESCE(nref.value('Article[1]/AuthorList[1]/Author[1]/AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
								nref.value('Article[1]/AuthorList[1]/Author[1]/Affiliation[1]','varchar(max)'),
								nref.value('Article[1]/Affiliation[1]','varchar(max)')) ,
							AuthorListCompleteYN = nref.value('Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(max)') ,
							GrantListCompleteYN=nref.value('Article[1]/GrantList[1]/@CompleteYN[1]','varchar(max)'),
							PMCID=nref.value('(OtherID[@Source="NLM"])[1]','varchar(max)')
				FROM  [Profile.Data].[Publication.PubMed.General]  g
				JOIN  [Profile.Data].[Publication.PubMed.AllXML] a ON a.pmid = g.pmid
					 CROSS APPLY  x.nodes('//MedlineCitation[1]') as R(nref)
				WHERE a.pmid = @pmid
				
		END
	ELSE 
		BEGIN 
		
			--*** general ***
			insert into [Profile.Data].[Publication.PubMed.General] (pmid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN,PMCID)
				select pmid, 
					nref.value('@Owner[1]','varchar(max)') Owner,
					nref.value('@Status[1]','varchar(max)') Status,
					nref.value('Article[1]/@PubModel','varchar(max)') PubModel,
					nref.value('Article[1]/Journal[1]/JournalIssue[1]/Volume[1]','varchar(max)') Volume,
					nref.value('Article[1]/Journal[1]/JournalIssue[1]/Issue[1]','varchar(max)') Issue,
					nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/MedlineDate[1]','varchar(max)') MedlineDate,
					nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Year[1]','varchar(max)') JournalYear,
					nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Month[1]','varchar(max)') JournalMonth,
					nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Day[1]','varchar(max)') JournalDay,
					nref.value('Article[1]/Journal[1]/Title[1]','varchar(max)') JournalTitle,
					nref.value('Article[1]/Journal[1]/ISOAbbreviation[1]','varchar(max)') ISOAbbreviation,
					nref.value('MedlineJournalInfo[1]/MedlineTA[1]','varchar(max)') MedlineTA,
					nref.value('Article[1]/ArticleTitle[1]','varchar(max)') ArticleTitle,
					nref.value('Article[1]/Pagination[1]/MedlinePgn[1]','varchar(max)') MedlinePgn,
					nref.value('Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') AbstractText,
					nref.value('Article[1]/ArticleDate[1]/@DateType[1]','varchar(max)') ArticleDateType,
					nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(max)') ArticleYear,
					nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(max)') ArticleMonth,
					nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(max)') ArticleDay,
					Affiliation = COALESCE(nref.value('Article[1]/AuthorList[1]/Author[1]/AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
						nref.value('Article[1]/AuthorList[1]/Author[1]/Affiliation[1]','varchar(max)'),
						nref.value('Article[1]/Affiliation[1]','varchar(max)')) ,
					nref.value('Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(max)') AuthorListCompleteYN,
					nref.value('Article[1]/GrantList[1]/@CompleteYN[1]','varchar(max)') GrantListCompleteYN,
					nref.value('(OtherID[@Source="NLM"])[1]','varchar(max)')
				from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//MedlineCitation[1]') as R(nref)
				where pmid = @pmid
	END


	--*** authors ***
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('@ValidYN','varchar(max)') ValidYN, 
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
		where pmid = @pmid
		

	--*** investigators ***
	insert into [Profile.Data].[Publication.PubMed.Investigator] (pmid, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//InvestigatorList/Investigator') as R(nref)
		where pmid = @pmid
		

	--*** pubtype ***
	insert into [Profile.Data].[Publication.PubMed.PubType] (pmid, PublicationType)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') PublicationType
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//PublicationTypeList/PublicationType') as R(nref)
			where pmid = @pmid
		) t where PublicationType is not null


	--*** chemicals
	insert into [Profile.Data].[Publication.PubMed.Chemical] (pmid, NameOfSubstance)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') NameOfSubstance
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//ChemicalList/Chemical/NameOfSubstance') as R(nref)
			where pmid = @pmid
		) t where NameOfSubstance is not null


	--*** databanks ***
	insert into [Profile.Data].[Publication.PubMed.Databank] (pmid, DataBankName)
		select * from (
			select distinct pmid, 
				nref.value('.','varchar(max)') DataBankName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/DataBankName') as R(nref)
			where pmid = @pmid
		) t where DataBankName is not null


	--*** accessions ***
	insert into [Profile.Data].[Publication.PubMed.Accession] (pmid, DataBankName, AccessionNumber)
		select * from (
			select distinct pmid, 
				nref.value('../../DataBankName[1]','varchar(max)') DataBankName,
				nref.value('.','varchar(max)') AccessionNumber
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/AccessionNumberList/AccessionNumber') as R(nref)
			where pmid = @pmid
		) t where DataBankName is not null and AccessionNumber is not null


	--*** keywords ***
	insert into [Profile.Data].[Publication.PubMed.Keyword] (pmid, Keyword, MajorTopicYN)
		select pmid, Keyword, max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('.','varchar(max)') Keyword,
				nref.value('@MajorTopicYN','varchar(max)') MajorTopicYN
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//KeywordList/Keyword') as R(nref)
			where pmid = @pmid
		) t where Keyword is not null
		group by pmid, Keyword


	--*** grants ***
	insert into [Profile.Data].[Publication.PubMed.Grant] (pmid, GrantID, Acronym, Agency)
		select pmid, GrantID, max(Acronym), max(Agency)
		from (
			select pmid, 
				nref.value('GrantID[1]','varchar(max)') GrantID, 
				nref.value('Acronym[1]','varchar(max)') Acronym,
				nref.value('Agency[1]','varchar(max)') Agency
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//GrantList/Grant') as R(nref)
			where pmid = @pmid
		) t where GrantID is not null
		group by pmid, GrantID


	--*** mesh ***
	insert into [Profile.Data].[Publication.PubMed.Mesh] (pmid, DescriptorName, QualifierName, MajorTopicYN)
		select pmid, DescriptorName, coalesce(QualifierName,''), max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('.','varchar(max)') DescriptorName,
				null QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/DescriptorName') as R(nref)
			where pmid = @pmid
			union all
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('../DescriptorName[1]','varchar(max)') DescriptorName,
				nref.value('.','varchar(max)') QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/QualifierName') as R(nref)
			where pmid = @pmid
		) t where DescriptorName is not null
		group by pmid, DescriptorName, QualifierName





	--*** general (authors) ***

	declare @a as table (
		i int identity(0,1) primary key,
		pmid int,
		lastname varchar(100),
		initials varchar(20),
		s varchar(max)
	)

	insert into @a (pmid, lastname, initials)
		select pmid, lastname, initials
		from [Profile.Data].[Publication.PubMed.Author]
		where pmid = @pmid
		order by pmid, PmPubsAuthorID

	declare @s varchar(max)
	declare @lastpmid int
	set @s = ''
	set @lastpmid = -1

	update @a
		set
			@s = s = case
					when @lastpmid <> pmid then lastname+' '+initials
					else @s + ', ' + lastname+' '+initials
				end,
			@lastpmid = pmid

	--create nonclustered index idx_p on @a (pmid)

	update g
		set g.authors = coalesce(a.authors,'')
		from [Profile.Data].[Publication.PubMed.General] g, (
				select pmid, (case when authors > authors_short then authors_short+', et al' else authors end) authors
				from (
					select pmid, max(s) authors,
							max(case when len(s)<3990 then s else '' end) authors_short
						from @a group by pmid
				) t
			) a
		where g.pmid = a.pmid





	--*** general (pubdate) ***

	declare @d as table (
		pmid int,
		PubDate datetime
	)

	insert into @d (pmid,PubDate)
		select pmid,[Profile.Data].[fnPublication.Pubmed.GetPubDate](MedlineDate,JournalYear,JournalMonth,JournalDay,ArticleYear,ArticleMonth,ArticleDay)
		from [Profile.Data].[Publication.PubMed.General]
		where pmid = @pmid



	/*

	insert into @d (pmid,PubDate)
		select pmid,
			case when JournalMonth is not null then JournalMonth
				when MedlineMonth is not null then MedlineMonth
				else coalesce(ArticleMonth,'1') end
			+'/'+
			case when JournalMonth is not null then coalesce(JournalDay,'1')
				when MedlineMonth is not null then '1'
				else coalesce(ArticleDay,'1') end
			+'/'+
			case when JournalYear is not null then coalesce(JournalYear,'1900')
				when MedlineMonth is not null then coalesce(MedlineYear,'1900')
				else coalesce(ArticleYear,'1900') end
			as PubDate
		from (
			select pmid, ArticleYear, ArticleDay, MedlineYear, JournalYear, JournalDay,
				(case MedlineMonth
					when 'Jan' then '1'
					when 'Feb' then '2'
					when 'Mar' then '3'
					when 'Arp' then '4'
					when 'May' then '5'
					when 'Jun' then '6'
					when 'Jul' then '7'
					when 'Aug' then '8'
					when 'Sep' then '9'
					when 'Oct' then '10'
					when 'Nov' then '11'
					when 'Dec' then '12'
					when 'Win' then '1'
					when 'Spr' then '4'
					when 'Sum' then '7'
					when 'Fal' then '10'
					else null end) MedlineMonth,
				(case JournalMonth
					when 'Jan' then '1'
					when 'Feb' then '2'
					when 'Mar' then '3'
					when 'Arp' then '4'
					when 'May' then '5'
					when 'Jun' then '6'
					when 'Jul' then '7'
					when 'Aug' then '8'
					when 'Sep' then '9'
					when 'Oct' then '10'
					when 'Nov' then '11'
					when 'Dec' then '12'
					when 'Win' then '1'
					when 'Spr' then '4'
					when 'Sum' then '7'
					when 'Fal' then '10'
					when '1' then '1'
					when '2' then '2'
					when '3' then '3'
					when '4' then '4'
					when '5' then '5'
					when '6' then '6'
					when '7' then '7'
					when '8' then '8'
					when '9' then '9'
					when '10' then '10'
					when '11' then '11'
					when '12' then '12'
					else null end) JournalMonth,
				(case ArticleMonth
					when 'Jan' then '1'
					when 'Feb' then '2'
					when 'Mar' then '3'
					when 'Arp' then '4'
					when 'May' then '5'
					when 'Jun' then '6'
					when 'Jul' then '7'
					when 'Aug' then '8'
					when 'Sep' then '9'
					when 'Oct' then '10'
					when 'Nov' then '11'
					when 'Dec' then '12'
					when 'Win' then '1'
					when 'Spr' then '4'
					when 'Sum' then '7'
					when 'Fal' then '10'
					when '1' then '1'
					when '2' then '2'
					when '3' then '3'
					when '4' then '4'
					when '5' then '5'
					when '6' then '6'
					when '7' then '7'
					when '8' then '8'
					when '9' then '9'
					when '10' then '10'
					when '11' then '11'
					when '12' then '12'
					else null end) ArticleMonth
			from (
				select pmid,
					left(medlinedate,4) as MedlineYear,
					substring(replace(medlinedate,' ',''),5,3) as MedlineMonth,
					JournalYear, left(journalMonth,3) as JournalMonth, JournalDay,
					ArticleYear, ArticleMonth, ArticleDay
				from pm_pubs_general
				where pmid = @pmid
			) t
		) t

	*/


	--create nonclustered index idx_p on @d (pmid)

	update g
		set g.PubDate = coalesce(d.PubDate,'1/1/1900')
		from [Profile.Data].[Publication.PubMed.General] g, @d d
		where g.pmid = d.pmid


END
GO
PRINT N'Altering [Ontology.].[CleanUp]...';


GO
ALTER PROCEDURE [Ontology.].[CleanUp]
	@Action varchar(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- This stored procedure contains code to help developers manage
	-- content in several ontology tables.
	
	-------------------------------------------------------------
	-- View the contents of the tables
	-------------------------------------------------------------

	if @Action = 'ShowTables'
	begin
		select * from [Ontology.].ClassGroup
		select * from [Ontology.].ClassGroupClass
		select * from [Ontology.].ClassProperty
		select * from [Ontology.].DataMap
		select * from [Ontology.].Namespace
		select * from [Ontology.].PropertyGroup
		select * from [Ontology.].PropertyGroupProperty
		select * from [Ontology.Import].[Triple]
		select * from [Ontology.Import].OWL
		select * from [Ontology.Presentation].General
	end
	
	-------------------------------------------------------------
	-- Insert missing records, use default values
	-------------------------------------------------------------

	if @Action = 'AddMissingRecords'
	begin

		insert into [Ontology.].ClassProperty (ClassPropertyID, Class, NetworkProperty, Property, IsDetail, Limit, IncludeDescription, IncludeNetwork, SearchWeight, CustomDisplay, CustomEdit, ViewSecurityGroup, EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup, EditDeleteSecurityGroup, MinCardinality, MaxCardinality, CustomEditModule)
			select ClassPropertyID, Class, NetworkProperty, Property, IsDetail, Limit, IncludeDescription, IncludeNetwork, SearchWeight, CustomDisplay, CustomEdit, ViewSecurityGroup, EditSecurityGroup, EditPermissionsSecurityGroup, EditExistingSecurityGroup, EditAddNewSecurityGroup, EditAddExistingSecurityGroup, EditDeleteSecurityGroup, MinCardinality, MaxCardinality, CustomEditModule
				from [Ontology.].vwMissingClassProperty

		insert into [Ontology.].PropertyGroupProperty (PropertyGroupURI, PropertyURI, SortOrder)
			select PropertyGroupURI, PropertyURI, SortOrder
				from [Ontology.].vwMissingPropertyGroupProperty

	end

	-------------------------------------------------------------
	-- Update IDs using the default sort order
	-------------------------------------------------------------

	if @Action = 'UpdateIDs'
	begin
		
		update x
			set x.ClassPropertyID = y.k
			from [Ontology.].ClassProperty x, (
				select *, row_number() over (order by (case when NetworkProperty is null then 0 else 1 end), Class, NetworkProperty, IsDetail, IncludeNetwork, Property) k
					from [Ontology.].ClassProperty
			) y
			where x.Class = y.Class and x.Property = y.Property
				and ((x.NetworkProperty is null and y.NetworkProperty is null) or (x.NetworkProperty = y.NetworkProperty))

		update x
			set x.DataMapID = y.k
			from [Ontology.].DataMap x, (
				select *, row_number() over (order by	(case when Property is null then 0 when NetworkProperty is null then 1 else 2 end), 
														(case when Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User' then 0 else 1 end), 
														Class,
														(case when NetworkProperty = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' then 0 when NetworkProperty = 'http://www.w3.org/2000/01/rdf-schema#label' then 1 else 2 end),
														NetworkProperty, 
														(case when Property = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' then 0 when Property = 'http://www.w3.org/2000/01/rdf-schema#label' then 1 else 2 end),
														MapTable,
														Property
														) k
					from [Ontology.].DataMap
			) y
			where x.Class = y.Class and x.sInternalType = y.sInternalType
				and ((x.Property is null and y.Property is null) or (x.Property = y.Property))
				and ((x.NetworkProperty is null and y.NetworkProperty is null) or (x.NetworkProperty = y.NetworkProperty))

		update x
			set x.PresentationID = y.k
			from [Ontology.Presentation].General x, (
				select *, row_number() over (order by	(case when Type = 'E' then 1 else 0 end), 
														Subject,
														(case Type when 'P' then 1 when 'N' then 2 else 3 end),
														Predicate, Object
														) k
					from [Ontology.Presentation].General
			) y
			where x.Type = y.Type
				and ((x.Subject is null and y.Subject is null) or (x.Subject = y.Subject))
				and ((x.Predicate is null and y.Predicate is null) or (x.Predicate = y.Predicate))
				and ((x.Object is null and y.Object is null) or (x.Object = y.Object))	

		update x 
			set x.JobID = y.k 
			from [Framework.].Job x, (
				select *, ROW_NUMBER() over (order by JobGroup, Step) k 
					from [Framework.].Job
			) y
			where x.JobGroup = y.JobGroup and x.Step = y.Step
	end

	-------------------------------------------------------------
	-- Update derived and calculated fields
	-------------------------------------------------------------

	if @Action = 'UpdateFields'
	begin
		exec [Ontology.].UpdateDerivedFields
		exec [Ontology.].UpdateCounts
	end
    
END
GO
PRINT N'Altering [Profile.Data].[Publication.PubMed.GetPersonInfoForDisambiguation]...';


GO
ALTER procedure [Profile.Data].[Publication.PubMed.GetPersonInfoForDisambiguation] 
AS
BEGIN
SET nocount  ON;
 
 
DECLARE  @search XML,
            @batchID UNIQUEIDENTIFIER,
            @batchcount INT,
            @threshold FLOAT,
            @baseURI NVARCHAR(max),
			@orcidNodeID NVARCHAR(max)

--SET Custom Threshold based on internal Institutional Logic, default is .98
SELECT @threshold = .98

SELECT @batchID=NEWID()

SELECT @baseURI = [Value] FROM [Framework.].[Parameter] WHERE [ParameterID] = 'baseURI'
SELECT @orcidNodeID = NodeID from [RDF.].Node where Value = 'http://vivoweb.org/ontology/core#orcidId'

SELECT personid, 
                   (SELECT ISNULL(RTRIM(firstname),'')  "Name/First",
                                          ISNULL(RTRIM(middlename),'') "Name/Middle",
                                          ISNULL(RTRIM(p.lastname),'') "Name/Last",
                                          ISNULL(RTRIM(suffix),'')     "Name/Suffix",
                                          CASE 
                                                 WHEN a.n IS NOT NULL OR b.n IS NOT NULL 
                                                          /*  Below is example of a custom piece of logic to alter the disambiguation by telling the disambiguation service
                                                            to Require First Name usage in the algorithm for faculty who are lower in rank */
                                                      OR facultyranksort > 4 
                                                      THEN 'true'
                                                ELSE 'false'
                                          END "RequireFirstName",
                                          d.cnt                                                                              "LocalDuplicateNames",
                                          @threshold                                                                   "MatchThreshold",
                                          (SELECT DISTINCT ISNULL(LTRIM(ISNULL(emailaddress,p.emailaddr)),'') Email
                                                      FROM [Profile.Data].[Person.Affiliation] pa
                                                WHERE pa.personid = p.personid
                                                FOR XML PATH(''),TYPE) AS "EmailList",
                                          (SELECT Affiliation
                                                      FROM [Profile.Data].[Publication.PubMed.DisambiguationAffiliation]
                                                FOR XML PATH(''),TYPE) AS "AffiliationList",
                                          (SELECT PMID
                                             FROM [Profile.Data].[Publication.Person.Add]
                                            WHERE personid =p2.personid
                                        FOR XML PATH(''),ROOT('PMIDAddList'),TYPE),
                                          (SELECT PMID
                                             FROM [Profile.Data].[Publication.Person.Exclude]
                                            WHERE personid =p2.personid
                                        FOR XML PATH(''),ROOT('PMIDExcludeList'),TYPE),
                                          (SELECT @baseURI + CAST(i.NodeID AS VARCHAR) 
                                        FOR XML PATH(''),ROOT('URI'),TYPE),
										  (select n.Value as '*' from [RDF.].Node n join
											[RDF.].Triple t  on n.NodeID = t.Object
											and t.Subject = i.NodeID
											and t.Predicate = @orcidNodeID
										FOR XML PATH(''),ROOT('ORCID'),TYPE)
                              FROM [Profile.Data].Person p
                                       LEFT JOIN ( 
                                                
                                                         --case 1
                                                            SELECT LEFT(firstname,1)  f,
                                                                              LEFT(middlename,1) m,
                                                                              lastname,
                                                                              COUNT(* )          n
                                                              FROM [Profile.Data].Person
                                                            GROUP BY LEFT(firstname,1),
                                                                              LEFT(middlename,1),
                                                                              lastname
                                                            HAVING COUNT(* ) > 1
                                                      )A ON a.lastname = p.lastname
                                                        AND a.f=LEFT(firstname,1)
                                                        AND a.m = LEFT(middlename,1)
                              LEFT JOIN (               
 
                                                      --case 2
                                                      SELECT LEFT(firstname,1) f,
                                                                        lastname,
                                                                        COUNT(* )         n
                                                        FROM [Profile.Data].Person
                                                      GROUP BY LEFT(firstname,1),
                                                                        lastname
                                                      HAVING COUNT(* ) > 1
                                                                        AND SUM(CASE 
                                                                                                       WHEN middlename = '' THEN 1
                                                                                                      ELSE 0
                                                                                                END) > 0
                                                                                                
                                                )B ON b.f = LEFT(firstname,1)
                                                  AND b.lastname = p.lastname
                              LEFT JOIN ( SELECT [Utility.NLP].[fnNamePart1](firstname)F,
                                                                                          lastname,
                                                                                          COUNT(*)cnt
                                                                              FROM [Profile.Data].Person 
                                                                         GROUP BY [Utility.NLP].[fnNamePart1](firstname), 
                                                                                          lastname
                                                                  )d ON d.f = [Utility.NLP].[fnNamePart1](p2.firstname)
                                                                        AND d.lastname = p2.lastname

                              LEFT JOIN [RDF.Stage].[InternalNodeMap] i
								 ON [InternalType] = 'Person' AND [Class] = 'http://xmlns.com/foaf/0.1/Person' AND [InternalID] = CAST(p2.personid AS VARCHAR(50))                             
                         WHERE p.personid = p2.personid
                        
                        FOR XML PATH(''),ROOT('FindPMIDs')) XML--as xml)
  INTO #batch
  FROM [Profile.Data].vwperson  p2
  
   
SELECT @batchcount=@@ROWCOUNT

SELECT @BatchID,@batchcount,*
  FROM #batch 
END
GO
PRINT N'Altering [Profile.Module].[NetworkAuthorshipTimeline.Concept.GetData]...';


GO
ALTER PROCEDURE [Profile.Module].[NetworkAuthorshipTimeline.Concept.GetData]
	@NodeID BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @DescriptorName NVARCHAR(255)
 	SELECT @DescriptorName = d.DescriptorName
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n,
			[Profile.Data].[Concept.Mesh.Descriptor] d
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
			AND m.InternalID = d.DescriptorUI

    -- Insert statements for procedure here
	declare @gc varchar(max)

	declare @y table (
		y int,
		A int,
		B int
	)

	insert into @y (y,A,B)
		select n.n y, coalesce(t.A,0) A, coalesce(t.B,0) B
		from [Utility.Math].[N] left outer join (
			select (case when y < 1970 then 1970 else y end) y,
				sum(A) A,
				sum(B) B
			from (
				select pmid, pubyear y, (case when w = 1 then 1 else 0 end) A, (case when w < 1 then 1 else 0 end) B
				from (
					select distinct pmid, pubyear, topicweight w
					from [Profile.Cache].[Concept.Mesh.PersonPublication]
					where meshheader = @DescriptorName
				) t
			) t
			group by y
		) t on n.n = t.y
		where n.n between 1980 and year(getdate())

	declare @x int

	select @x = max(A+B)
		from @y

	if coalesce(@x,0) > 0
	begin
		declare @v varchar(1000)
		declare @z int
		declare @k int
		declare @i int

		set @z = power(10,floor(log(@x)/log(10)))
		set @k = floor(@x/@z)
		if @x > @z*@k
			select @k = @k + 1
		if @k > 5
			select @k = floor(@k/2.0+0.5), @z = @z*2

		set @v = ''
		set @i = 0
		while @i <= @k
		begin
			set @v = @v + '|' + cast(@z*@i as varchar(50))
			set @i = @i + 1
		end
		set @v = '|0|'+cast(@x as varchar(50))
		--set @v = '|0|50|100'

		declare @h varchar(1000)
		set @h = ''
		select @h = @h + '|' + (case when y % 2 = 1 then '' else ''''+right(cast(y as varchar(50)),2) end)
			from @y
			order by y 

		declare @w float
		--set @w = @k*@z
		set @w = @x

		declare @d varchar(max)
		set @d = ''
		select @d = @d + cast(floor(0.5 + 100*A/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1) + '|'
		select @d = @d + cast(floor(0.5 + 100*B/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1)

		declare @c varchar(50)
		set @c = 'FB8072,80B1D3'
		--set @c = 'FB8072,B3DE69,80B1D3'
		--set @c = 'F96452,a8dc4f,68a4cc'
		--set @c = 'fea643,76cbbd,b56cb5'

		--select @v, @h, @d

		--set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=First+Author|Middle or Unkown|Last+Author&chco='+@c+'&chbh=10'
		set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=Major+Topic|Minor+Topic&chco='+@c+'&chbh=10'


		declare @asText varchar(max)
		set @asText = '<table style="width:592px"><tr><th>Year</th><th>Major Topic</th><th>Minor Topic</th><th>Total</th></tr>'
		select @asText = @asText + '<tr><td>' + cast(y as varchar(50)) + '</td><td>' + cast(A as varchar(50)) + '</td><td>' + cast(B as varchar(50)) + '</td><td>' + cast(A + B as varchar(50)) + '</td></tr>'
			from @y
			where A + B > 0
			order by y 
		select @asText = @asText + '</table>'

		declare @alt varchar(max)
		select @alt = 'Bar chart showing ' + cast(sum(A + B) as varchar(50))+ ' publications over ' + cast(count(*) as varchar(50)) + ' distinct years, with a maximum of ' + cast(@x as varchar(50)) + ' publications in ' from @y where A + B > 0
		select @alt = @alt + cast(y as varchar(50)) + ' and '
			from @y
			where A + B = @x
			order by y 
		select @alt = left(@alt, len(@alt) - 4)

		select @gc gc, @alt alt, @asText asText --, @w w

		--select * from @y order by y

	end

END
GO
PRINT N'Altering [Profile.Module].[NetworkAuthorshipTimeline.Person.GetData]...';


GO
ALTER PROCEDURE [Profile.Module].[NetworkAuthorshipTimeline.Person.GetData]
	@NodeID BIGINT,
	@ShowAuthorPosition BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @PersonID INT
 	SELECT @PersonID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
    -- Insert statements for procedure here
	declare @gc varchar(max)

	declare @y table (
		y int,
		A int,
		B int,
		C int,
		T int
	)

	insert into @y (y,A,B,C,T)
		select n.n y, coalesce(t.A,0) A, coalesce(t.B,0) B, coalesce(t.C,0) C, coalesce(t.T,0) T
		from [Utility.Math].[N] left outer join (
			select (case when y < 1970 then 1970 else y end) y,
				sum(case when r in ('F','S') then 1 else 0 end) A,
				sum(case when r not in ('F','S','L') then 1 else 0 end) B,
				sum(case when r in ('L') then 1 else 0 end) C,
				count(*) T
			from (
				select coalesce(p.AuthorPosition,'U') r, year(coalesce(p.pubdate,m.publicationdt,'1/1/1970')) y
				from [Profile.Data].[Publication.Person.Include] a
					left outer join [Profile.Cache].[Publication.PubMed.AuthorPosition] p on a.pmid = p.pmid and p.personid = a.personid
					left outer join [Profile.Data].[Publication.MyPub.General] m on a.mpid = m.mpid
				where a.personid = @PersonID
			) t
			group by y
		) t on n.n = t.y
		where n.n between 1980 and year(getdate())

	declare @x int

	--select @x = max(A+B+C)
	--	from @y

	select @x = max(T)
		from @y

	if coalesce(@x,0) > 0
	begin
		declare @v varchar(1000)
		declare @z int
		declare @k int
		declare @i int

		set @z = power(10,floor(log(@x)/log(10)))
		set @k = floor(@x/@z)
		if @x > @z*@k
			select @k = @k + 1
		if @k > 5
			select @k = floor(@k/2.0+0.5), @z = @z*2

		set @v = ''
		set @i = 0
		while @i <= @k
		begin
			set @v = @v + '|' + cast(@z*@i as varchar(50))
			set @i = @i + 1
		end
		set @v = '|0|'+cast(@x as varchar(50))
		--set @v = '|0|50|100'

		declare @h varchar(1000)
		set @h = ''
		select @h = @h + '|' + (case when y % 2 = 1 then '' else ''''+right(cast(y as varchar(50)),2) end)
			from @y
			order by y 

		declare @w float
		--set @w = @k*@z
		set @w = @x

		declare @c varchar(50)
		declare @d varchar(max)
		set @d = ''

		if @ShowAuthorPosition = 0
		begin
			select @d = @d + cast(floor(0.5 + 100*T/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1)

			--set @c = 'AC1B30'
			set @c = '80B1D3'
			set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=Publications&chco='+@c+'&chbh=10'
		end
		else
		begin
			select @d = @d + cast(floor(0.5 + 100*A/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1) + '|'
			select @d = @d + cast(floor(0.5 + 100*B/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1) + '|'
			select @d = @d + cast(floor(0.5 + 100*C/@w) as varchar(50)) + ','
				from @y
				order by y
			set @d = left(@d,len(@d)-1)

			set @c = 'FB8072,B3DE69,80B1D3'
			set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=First+Author|Middle or Unkown|Last+Author&chco='+@c+'&chbh=10'
		end
		
		declare @asText varchar(max)
		set @asText = '<table style="width:592px"><tr><th>Year</th><th>Publications</th></tr>'
		select @asText = @asText + '<tr><td>' + cast(y as varchar(50)) + '</td><td>' + cast(t as varchar(50)) + '</td></tr>'
			from @y
			where t > 0
			order by y 
		select @asText = @asText + '</table>'
		
			declare @alt varchar(max)
		select @alt = 'Bar chart showing ' + cast(sum(t) as varchar(50))+ ' publications over ' + cast(count(*) as varchar(50)) + ' distinct years, with a maximum of ' + cast(@x as varchar(50)) + ' publications in ' from @y where t > 0
		select @alt = @alt + cast(y as varchar(50)) + ' and '
			from @y
			where t = @x
			order by y 
		select @alt = left(@alt, len(@alt) - 4)


		select @gc gc, @alt alt, @asText asText --, @w w
	end

END
GO
PRINT N'Altering [RDF.].[DeleteNode]...';


GO
ALTER procedure [RDF.].[DeleteNode]
	@NodeID bigint = NULL,
	@NodeURI varchar(400) = NULL,
	@DeleteType tinyint = 1,
	@SessionID uniqueidentifier = NULL,
	-- Output variables
	@Error bit = NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int,@proc VARCHAR(200),@date DATETIME,@auditid UNIQUEIDENTIFIER 
	SELECT @proc = OBJECT_NAME(@@PROCID),@date=GETDATE() 	
	EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessStartDate=@date,@insert_new_record=1
	
	SELECT @Error = 0
	
	SELECT @NodeID = NULL WHERE @NodeID = 0
 
	IF (@NodeID IS NULL) AND (@NodeURI IS NOT NULL)
		SELECT @NodeID = [RDF.].fnURI2NodeID(@NodeURI)
 
	IF (@NodeID IS NOT NULL)
	BEGIN TRY
	BEGIN TRANSACTION
	    
		IF @DeleteType = 0 -- True delete
		BEGIN
			EXEC [RDF.].[DeleteTriple] @DeleteType = @DeleteType, @SessionID = @SessionID, @SubjectID = @NodeID
			EXEC [RDF.].[DeleteTriple] @DeleteType = @DeleteType, @SessionID = @SessionID, @PredicateID = @NodeID
			EXEC [RDF.].[DeleteTriple] @DeleteType = @DeleteType, @SessionID = @SessionID, @ObjectID = @NodeID
			DELETE
				FROM [RDF.Stage].[InternalNodeMap]
				WHERE NodeID = @NodeID
			DELETE
				FROM [RDF.].[Node]
				WHERE NodeID = @NodeID
		END
 
		IF @DeleteType = 1 -- Change security groups
		BEGIN
			UPDATE [RDF.].[Node]
				SET ViewSecurityGroup = 0, EditSecurityGroup = -50
				WHERE NodeID = @NodeID
		END
  
	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
		SELECT @date=GETDATE()
		EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessEndDate=@date,@error = 1,@insert_new_record=0
		--Raise an error with the details of the exception
		SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH
 
END
GO
PRINT N'Altering [User.Session].[CreateSession]...';


GO
ALTER procedure [User.Session].[CreateSession]
    @RequestIP VARCHAR(16),
    @UserAgent VARCHAR(500) = NULL,
    @UserID VARCHAR(200) = NULL,
	@SessionPersonNodeID BIGINT = NULL OUTPUT,
	@SessionPersonURI VARCHAR(400) = NULL OUTPUT,
	@SecurityGroupID BIGINT = NULL OUTPUT
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

	-- Get the security group of the session
	EXEC [RDF.Security].[GetSessionSecurityGroup] @SessionID = @SessionID, @SecurityGroupID = @SecurityGroupID OUTPUT

    SELECT *, @SecurityGroupID SecurityGroupID
		FROM [User.Session].[Session]
		WHERE SessionID = @SessionID AND @SessionID IS NOT NULL
 
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
	@UserURI VARCHAR(400) = NULL OUTPUT,
	@SecurityGroupID BIGINT = NULL OUTPUT
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

	-- Get the security group of the session
	EXEC [RDF.Security].[GetSessionSecurityGroup] @SessionID = @SessionID, @SecurityGroupID = @SecurityGroupID OUTPUT
END
GO
PRINT N'Altering [ORNG.].[RemoveAppFromPerson]...';


GO

ALTER PROCEDURE [ORNG.].[RemoveAppFromPerson]
@SubjectID BIGINT=NULL, @SubjectURI NVARCHAR(255)=NULL, @AppID INT, @DeleteType tinyint = 1, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ApplicationInstanceNodeID  BIGINT
	DECLARE @TripleID BIGINT
	DECLARE @PersonID INT	
	DECLARE @PERSON_FILTER_ID INT
	DECLARE @InternalUserName NVARCHAR(50)
	DECLARE @PersonFilter NVARCHAR(50)

	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	-- Lookup the PersonID
	SELECT @PersonID = CAST(InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://xmlns.com/foaf/0.1/Person' AND InternalType = 'Person' AND NodeID = @SubjectID

	-- Lookup the App Instance's NodeID
	SELECT @ApplicationInstanceNodeID  = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNG Application Instance'
			AND InternalID = CAST(@PersonID AS VARCHAR(50)) + '-' + CAST(@AppID AS VARCHAR(50))
	
		
	-- there is only ONE link from the person to the application object, so grab it	
	SELECT @TripleID = [TripleID] FROM [RDF.].Triple 
		WHERE [Subject] = @SubjectID
		AND [Object] = @ApplicationInstanceNodeID

	-- now delete it
	BEGIN TRAN

		EXEC [RDF.].DeleteTriple @TripleID = @TripleID, 
								 @SessionID = @SessionID, 
								 @Error = @Error

		IF (@DeleteType = 0) -- true delete, remove the now orphaned application instance
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @ApplicationInstanceNodeID, 
							   @DeleteType = @DeleteType,
							   @SessionID = @SessionID, 
							   @Error = @Error OUTPUT
		END							   

		-- remove any filters
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE AppID = @AppID)
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				SELECT @PersonID = CAST(InternalID AS INT) FROM [RDF.Stage].[InternalNodeMap]
					WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'

				SELECT @InternalUserName = InternalUserName FROM [Profile.Data].[Person] WHERE PersonID = @PersonID
				SELECT @PersonFilter = PersonFilter FROM [Profile.Data].[Person.Filter] WHERE PersonFilterID = @PERSON_FILTER_ID

				DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE InternalUserName = @InternalUserName AND personfilter = @PersonFilter
				DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID AND personFilterId = @PERSON_FILTER_ID
			END
	COMMIT
END
GO
PRINT N'Refreshing [ORNG.].[AddAppToPerson]...';

GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Alter PROCEDURE [ORNG.].[AddAppToPerson]
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
		EXEC [RDF.].[GetStoreTriple] @SubjectID = @SubjectID, -- bigint
									 @ObjectID = @AppInstanceID, -- bigint
									 @PredicateURI = @PredicateURI, -- varchar(400)
									 @ViewSecurityGroup = @ViewSecurityGroup, -- bigint
									 @SessionID = NULL, -- uniqueidentifier
									 @Error = NULL -- bit

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



GO
EXECUTE sp_refreshsqlmodule N'[ORNG.].[AddAppToPerson]';


GO
PRINT N'Refreshing [Edit.Module].[CustomEditAuthorInAuthorship.GetList]...';


GO
EXECUTE sp_refreshsqlmodule N'[Edit.Module].[CustomEditAuthorInAuthorship.GetList]';


GO
PRINT N'Refreshing [ORCID.].[AuthorInAuthorshipForORCID.GetList]...';


GO
EXECUTE sp_refreshsqlmodule N'[ORCID.].[AuthorInAuthorshipForORCID.GetList]';


GO
PRINT N'Refreshing [Profile.Cache].[Concept.Mesh.UpdateJournal]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Cache].[Concept.Mesh.UpdateJournal]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.MyPub.UpdatePublication]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.MyPub.UpdatePublication]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]';


GO
PRINT N'Refreshing [Profile.Import].[Beta.LoadData]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Import].[Beta.LoadData]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.GetPersonPublications3]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.GetPersonPublications3]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.GetPersonPublications2]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.GetPersonPublications2]';


GO
PRINT N'Refreshing [Profile.Data].[Concept.Mesh.GetPublications]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Concept.Mesh.GetPublications]';


GO
PRINT N'Refreshing [Profile.Module].[ConnectionDetails.Person.HasResearchArea.GetData]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Module].[ConnectionDetails.Person.HasResearchArea.GetData]';


GO
PRINT N'Refreshing [Profile.Module].[ConnectionDetails.Person.CoAuthorOf.GetData]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Module].[ConnectionDetails.Person.CoAuthorOf.GetData]';


GO
PRINT N'Refreshing [Profile.Cache].[Publication.PubMed.UpdateAuthorPosition]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Cache].[Publication.PubMed.UpdateAuthorPosition]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.AddOneAuthorPosition]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.AddOneAuthorPosition]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.PubMed.GetAllPMIDs]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.PubMed.GetAllPMIDs]';


GO
PRINT N'Refreshing [Profile.Module].[NetworkTimeline.Person.CoAuthorOf.GetData]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Module].[NetworkTimeline.Person.CoAuthorOf.GetData]';


GO
PRINT N'Refreshing [Profile.Module].[NetworkTimeline.Person.HasResearchArea.GetData]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Module].[NetworkTimeline.Person.HasResearchArea.GetData]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.GetPersonPublications]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.GetPersonPublications]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.AddPubMedXML]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.AddPubMedXML]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.AddPublication]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.AddPublication]';


GO
PRINT N'Checking existing data against newly created constraints';



GO
ALTER TABLE [Profile.Data].[Publication.PubMed.Author] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_authors_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.PubType] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_pubtypes_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.Keyword] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_keywords_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.Accession] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_accessions_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.Databank] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_databanks_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.Chemical] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_chemicals_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.Mesh] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_mesh_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.Investigator] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_investigators_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.PubMed.Grant] WITH CHECK CHECK CONSTRAINT [FK_pm_pubs_grants_pm_pubs_general];

ALTER TABLE [Profile.Data].[Publication.Person.Include] WITH CHECK CHECK CONSTRAINT [FK_publications_include_pm_pubs_general];


GO
PRINT N'Update complete.';


GO
