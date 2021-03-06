/*
Run this script on:

        Profiles 2.6.0   -  This database will be modified

to synchronize it with:

        Profiles 2.7.0

You are recommended to back up your database before running this script

Details of which objects have changed can be found in the release notes.
If you have made changes to existing tables or stored procedures in profiles, you may need to merge changes individually. 

*/



/**
* Drop Duplicate Indexes
**/
GO
DROP INDEX [missing_index_73248] ON [Profile.Data].[Person.Affiliation];
GO
DROP INDEX [missing_index_73175] ON [Profile.Data].[Publication.Entity.Authorship];
GO
DROP INDEX [missing_index_73031] ON [Profile.Data].[Publication.Entity.InformationResource];
GO
DROP INDEX [missing_index_158] ON [Profile.Import].[PersonAffiliation];
GO
DROP INDEX [missing_index_1811_1810] ON [Profile.Import].[PersonAffiliation];
GO
DROP INDEX [missing_index_73037] ON [RDF.].[Triple];
GO
DROP INDEX [missing_index_73079] ON [RDF.].[Triple];
GO
DROP INDEX [missing_index_73181] ON [RDF.].[Triple];
GO
DROP INDEX [missing_index_1] ON [RDF.Stage].[InternalNodeMap];
GO
DROP INDEX [missing_index_72997] ON [RDF.Stage].[InternalNodeMap];
GO


/**
* Add activity log tables and Stored procedures
**/
GO
CREATE TABLE [Framework.].[Log.Activity] (
    [activityLogId] INT            IDENTITY (1, 1) NOT NULL,
    [userId]        INT            NULL,
    [personId]      INT            NULL,
    [methodName]    NVARCHAR (255) NULL,
    [property]      NVARCHAR (255) NULL,
    [privacyCode]   INT            NULL,
    [param1]        NVARCHAR (255) NULL,
    [param2]        NVARCHAR (255) NULL,
    [createdDT]     DATETIME       NOT NULL,
    CONSTRAINT [PK__Log.Activity] PRIMARY KEY CLUSTERED ([activityLogId] ASC)
);


GO

ALTER TABLE [Framework.].[Log.Activity]
    ADD CONSTRAINT [DF_Log.Activity_createdDT] DEFAULT (getdate()) FOR [createdDT];


GO

CREATE PROCEDURE [Framework.].[Log.AddActivity]
	@userId int,
	@personId int = null,
	@subjectId bigint = null, 
	@methodName varchar(255),
	@property varchar(255),
	@propertyID bigint = null,
	@privacyCode int,
	@param1 varchar(255),
	@param2 varchar(255)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@personId is null)
	BEGIN
		select @personID = InternalID from [RDF.Stage].InternalNodeMap  where class = 'http://xmlns.com/foaf/0.1/Person' and nodeID = @subjectId
	END
	IF (@property is null)
	BEGIN
		select @property = value from [RDF.].Node where NodeID = @propertyID
	END
	INSERT INTO [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2) 
		VALUES(@userId, @personId, @methodName, @property, @privacyCode, @param1, @param2)
END
GO


/**
* Alter [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]
* and [Profile.Import].[LoadProfilesData]
* to add activity logging
**/
GO
ALTER procedure [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]
AS
BEGIN
BEGIN TRY  
BEGIN TRAN
 
-- Remove orphaned pubs
DECLARE @deletedPMIDTable TABLE (PersonID int, PMID int)
DELETE FROM [Profile.Data].[Publication.Person.Include]
OUTPUT deleted.PersonID, deleted.PMID into @deletedPMIDTable
	  WHERE NOT EXISTS (SELECT *
						  FROM [Profile.Data].[Publication.PubMed.Disambiguation] p
						 WHERE p.personid = [Profile.Data].[Publication.Person.Include].personid
						   AND p.pmid = [Profile.Data].[Publication.Person.Include].pmid)
		AND mpid IS NULL
INSERT INTO [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2) 
SELECT 0, PersonID, '[Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]', null, null, 'Delete PMID', PMID FROM @deletedPMIDTable

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
DECLARE @addedPMIDTable TABLE (PersonID int, PMID int)
INSERT INTO [Profile.Data].[Publication.Person.Include]
OUTPUT inserted.PersonID, inserted.PMID into @addedPMIDTable
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
 INSERT INTO [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2) 
SELECT 0, PersonID, '[Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]', null, null, 'Add PMID', PMID FROM @addedPMIDTable	  
 
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

/*

Copyright (c) 2008-2010 by the President and Fellows of Harvard College. All rights reserved.  Profiles Research Networking Software was developed under the supervision of Griffin M Weber, MD, PhD., and Harvard Catalyst: The Harvard Clinical and Translational Science Center, with support from the National Center for Research Resources and Harvard University.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name "Harvard" nor the names of its contributors nor the name "Harvard Catalyst" may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER (PRESIDENT AND FELLOWS OF HARVARD COLLEGE) AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.




*/
ALTER procedure [Profile.Import].[LoadProfilesData]
    (
      @use_internalusername_as_pkey BIT = 0
    )
AS 
    BEGIN
        SET NOCOUNT ON;	


	-- Start Transaction. Log load failures, roll back transaction on error.
        BEGIN TRY
            BEGIN TRAN				 

            DECLARE @ErrMsg NVARCHAR(4000) ,
                @ErrSeverity INT


						-- Department
            INSERT  INTO [Profile.Data].[Organization.Department]
                    ( departmentname ,
                      visible
                    )
                    SELECT DISTINCT
                            departmentname ,
                            1
                    FROM    [Profile.Import].PersonAffiliation a
                    WHERE   departmentname IS NOT NULL
                            AND departmentname NOT IN (
                            SELECT  departmentname
                            FROM    [Profile.Data].[Organization.Department] )


						-- institution
            INSERT  INTO [Profile.Data].[Organization.Institution]
                    ( InstitutionName ,
                      InstitutionAbbreviation
										
                    )
                    SELECT  INSTITUTIONNAME ,
                            INSTITUTIONABBREVIATION
                    FROM    ( SELECT    INSTITUTIONNAME ,
                                        INSTITUTIONABBREVIATION ,
                                        COUNT(*) CNT ,
                                        ROW_NUMBER() OVER ( PARTITION BY institutionname ORDER BY SUM(CASE
                                                              WHEN INSTITUTIONABBREVIATION = ''
                                                              THEN 0
                                                              ELSE 1
                                                              END) DESC ) rank
                              FROM      [Profile.Import].PersonAffiliation
                              GROUP BY  INSTITUTIONNAME ,
                                        INSTITUTIONABBREVIATION
                            ) A
                    WHERE   rank = 1
                            AND institutionname <> ''
                            AND NOT EXISTS ( SELECT b.institutionname
                                             FROM   [Profile.Data].[Organization.Institution] b
                                             WHERE  b.institutionname = a.institutionname )


						-- division
            INSERT  INTO [Profile.Data].[Organization.Division]
                    ( DivisionName  
										
                    )
                    SELECT DISTINCT
                            divisionname
                    FROM    [Profile.Import].PersonAffiliation a
                    WHERE   divisionname IS NOT NULL
                            AND NOT EXISTS ( SELECT b.divisionname
                                             FROM   [Profile.Data].[Organization.Division] b
                                             WHERE  b.divisionname = a.divisionname )



					-- Flag deleted people
			DECLARE @deletedPersonIDTable TABLE (PersonID int)
            
			UPDATE  [Profile.Data].Person
            SET     ISactive = 0
			OUTPUT inserted.PersonID into @deletedPersonIDTable
            WHERE   internalusername NOT IN (
                    SELECT  internalusername
                    FROM    [Profile.Import].Person where isactive = 1)
			
			INSERT INTO [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2) 
			SELECT 0, PersonID, '[Profile.Import].[LoadProfilesData]', null, null, 'Person Delete', null FROM @deletedPersonIDTable

					-- Update person/user records where data has changed. 
			DECLARE @updatedPersonIDTable TABLE (PersonID int)
            
			UPDATE  p
            SET     p.firstname = lp.firstname ,
                    p.lastname = lp.lastname ,
                    p.middlename = lp.middlename ,
                    p.displayname = lp.displayname ,
                    p.suffix = lp.suffix ,
                    p.addressline1 = lp.addressline1 ,
                    p.addressline2 = lp.addressline2 ,
                    p.addressline3 = lp.addressline3 ,
                    p.addressline4 = lp.addressline4 ,
                    p.city = lp.city ,
                    p.state = lp.state ,
                    p.zip = lp.zip ,
                    p.building = lp.building ,
                    p.room = lp.room ,
                    p.phone = lp.phone ,
                    p.fax = lp.fax ,
                    p.EmailAddr = lp.EmailAddr ,
                    p.AddressString = lp.AddressString ,
                    p.isactive = lp.isactive ,
                    p.visible = lp.isvisible
					OUTPUT inserted.PersonID into @updatedPersonIDTable
            FROM    [Profile.Data].Person p
                    JOIN [Profile.Import].Person lp ON lp.internalusername = p.internalusername
                                                       AND ( ISNULL(lp.firstname,
                                                              '') <> ISNULL(p.firstname,
                                                              '')
                                                             OR ISNULL(lp.lastname,
                                                              '') <> ISNULL(p.lastname,
                                                              '')
                                                             OR ISNULL(lp.middlename,
                                                              '') <> ISNULL(p.middlename,
                                                              '')
                                                             OR ISNULL(lp.displayname,
                                                              '') <> ISNULL(p.displayname,
                                                              '')
                                                             OR ISNULL(lp.suffix,
                                                              '') <> ISNULL(p.suffix,
                                                              '')
                                                             OR ISNULL(lp.addressline1,
                                                              '') <> ISNULL(p.addressline1,
                                                              '')
                                                             OR ISNULL(lp.addressline2,
                                                              '') <> ISNULL(p.addressline2,
                                                              '')
                                                             OR ISNULL(lp.addressline3,
                                                              '') <> ISNULL(p.addressline3,
                                                              '')
                                                             OR ISNULL(lp.addressline4,
                                                              '') <> ISNULL(p.addressline4,
                                                              '')
                                                             OR ISNULL(lp.city,
                                                              '') <> ISNULL(p.city,
                                                              '')
                                                             OR ISNULL(lp.state,
                                                              '') <> ISNULL(p.state,
                                                              '')
                                                             OR ISNULL(lp.zip,
                                                              '') <> ISNULL(p.zip,
                                                              '')
                                                             OR ISNULL(lp.building,
                                                              '') <> ISNULL(p.building,
                                                              '')
                                                             OR ISNULL(lp.room,
                                                              '') <> ISNULL(p.room,
                                                              '')
                                                             OR ISNULL(lp.phone,
                                                              '') <> ISNULL(p.phone,
                                                              '')
                                                             OR ISNULL(lp.fax,
                                                              '') <> ISNULL(p.fax,
                                                              '')
                                                             OR ISNULL(lp.EmailAddr,
                                                              '') <> ISNULL(p.EmailAddr,
                                                              '')
                                                             OR ISNULL(lp.AddressString,
                                                              '') <> ISNULL(p.AddressString,
                                                              '')
                                                             OR ISNULL(lp.Isactive,
                                                              '') <> ISNULL(p.Isactive,
                                                              '')
                                                             OR ISNULL(lp.isvisible,
                                                              '') <> ISNULL(p.visible,
                                                              '')
                                                           ) 

			INSERT INTO [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2) 
			SELECT 0, PersonID, '[Profile.Import].[LoadProfilesData]', null, null, 'Person Update', null FROM @updatedPersonIDTable
						-- Update changed user info
            UPDATE  u
            SET     u.firstname = up.firstname ,
                    u.lastname = up.lastname ,
                    u.displayname = up.displayname ,
                    u.institution = up.institution ,
                    u.department = up.department ,
                    u.emailaddr = up.emailaddr
            FROM    [User.Account].[User] u
                    JOIN [Profile.Import].[User] up ON up.internalusername = u.internalusername
                                                       AND ( ISNULL(up.firstname,
                                                              '') <> ISNULL(u.firstname,
                                                              '')
                                                             OR ISNULL(up.lastname,
                                                              '') <> ISNULL(u.lastname,
                                                              '')
                                                             OR ISNULL(up.displayname,
                                                              '') <> ISNULL(u.displayname,
                                                              '')
                                                             OR ISNULL(up.institution,
                                                              '') <> ISNULL(u.institution,
                                                              '')
                                                             OR ISNULL(up.department,
                                                              '') <> ISNULL(u.department,
                                                              '')
                                                             OR ISNULL(up.emailaddr,
                                                              '') <> ISNULL(u.emailaddr,
                                                              '')
                                                           )

					-- Remove Affiliations that have changed, so they'll be re-added
            SELECT DISTINCT
                    COALESCE(p.internalusername, pa.internalusername) internalusername
            INTO    #affiliations
            FROM    [Profile.Cache].[Person.Affiliation] cpa
            JOIN	[Profile.Data].Person p ON p.personid = cpa.personid
       FULL JOIN	[Profile.Import].PersonAffiliation pa ON pa.internalusername = p.internalusername
                                                              AND  pa.affiliationorder =  cpa.sortorder  
                                                              AND pa.primaryaffiliation = cpa.isprimary  
                                                              AND pa.title = cpa.title  
                                                              AND pa.institutionabbreviation =  cpa.institutionabbreviation  
                                                              AND pa.departmentname =  cpa.departmentname  
                                                              AND pa.divisionname = cpa.divisionname 
                                                              AND pa.facultyrank  = cpa.facultyrank
                                                              
            WHERE   pa.internalusername IS NULL
                    OR cpa.personid IS NULL

            DELETE  FROM [Profile.Data].[Person.Affiliation]
            WHERE   personid IN ( SELECT    personid
                                  FROM      [Profile.Data].Person
                                  WHERE     internalusername IN ( SELECT
                                                              internalusername
                                                              FROM
                                                              #affiliations ) )

					-- Remove Filters that have changed, so they'll be re-added
            SELECT  internalusername ,
                    personfilter
            INTO    #filter
            FROM    [Profile.Data].[Person.FilterRelationship] pfr
                    JOIN [Profile.Data].Person p ON p.personid = pfr.personid
                    JOIN [Profile.Data].[Person.Filter] pf ON pf.personfilterid = pfr.personfilterid
            CREATE CLUSTERED INDEX tmp ON #filter(internalusername)
            DELETE  FROM [Profile.Data].[Person.FilterRelationship]
            WHERE   personid IN (
                    SELECT  personid
                    FROM    [Profile.Data].Person
                    WHERE   InternalUsername IN (
                            SELECT  COALESCE(a.internalusername,
                                             p.internalusername)
                            FROM    [Profile.Import].PersonFilterFlag pf
                                    JOIN [Profile.Import].Person p ON p.internalusername = pf.internalusername
                                    FULL JOIN #filter a ON a.internalusername = p.internalusername
                                                           AND a.personfilter = pf.personfilter
                            WHERE   a.internalusername IS NULL
                                    OR p.internalusername IS NULL ) )






					-- user
            IF @use_internalusername_as_pkey = 0 
                BEGIN
                    INSERT  INTO [User.Account].[User]
                            ( IsActive ,
                              CanBeProxy ,
                              FirstName ,
                              LastName ,
                              DisplayName ,
                              Institution ,
                              Department ,
                              InternalUserName ,
                              emailaddr 
						        
                            )
                            SELECT  1 ,
                                    canbeproxy ,
                                    ISNULL(firstname, '') ,
                                    ISNULL(lastname, '') ,
                                    ISNULL(displayname, '') ,
                                    institution ,
                                    department ,
                                    InternalUserName ,
                                    emailaddr
                            FROM    [Profile.Import].[User] u
                            WHERE   NOT EXISTS ( SELECT *
                                                 FROM   [User.Account].[User] b
                                                 WHERE  b.internalusername = u.internalusername )
                            UNION
                            SELECT  1 ,
                                    1 ,
                                    ISNULL(firstname, '') ,
                                    ISNULL(lastname, '') ,
                                    ISNULL(displayname, '') ,
                                    institutionname ,
                                    departmentname ,
                                    u.InternalUserName ,
                                    u.emailaddr
                            FROM    [Profile.Import].Person u
                                    LEFT JOIN [Profile.Import].PersonAffiliation pa ON pa.internalusername = u.internalusername
                                                              AND pa.primaryaffiliation = 1
                            WHERE   NOT EXISTS ( SELECT *
                                                 FROM   [User.Account].[User] b
                                                 WHERE  b.internalusername = u.internalusername )
                END
            ELSE 
                BEGIN
                    SET IDENTITY_INSERT [User.Account].[User] ON 

                    INSERT  INTO [User.Account].[User]
                            ( userid ,
                              IsActive ,
                              CanBeProxy ,
                              FirstName ,
                              LastName ,
                              DisplayName ,
                              Institution ,
                              Department ,
                              InternalUserName ,
                              emailaddr 
						        
                            )
                            SELECT  u.internalusername ,
                                    1 ,
                                    canbeproxy ,
                                    ISNULL(firstname, '') ,
                                    ISNULL(lastname, '') ,
                                    ISNULL(displayname, '') ,
                                    institution ,
                                    department ,
                                    InternalUserName ,
                                    emailaddr
                            FROM    [Profile.Import].[User] u
                            WHERE   NOT EXISTS ( SELECT *
                                                 FROM   [User.Account].[User] b
                                                 WHERE  b.internalusername = u.internalusername )
                            UNION ALL
                            SELECT  u.internalusername ,
                                    1 ,
                                    1 ,
                                    ISNULL(firstname, '') ,
                                    ISNULL(lastname, '') ,
                                    ISNULL(displayname, '') ,
                                    institutionname ,
                                    departmentname ,
                                    u.InternalUserName ,
                                    u.emailaddr
                            FROM    [Profile.Import].Person u
                                    LEFT JOIN [Profile.Import].PersonAffiliation pa ON pa.internalusername = u.internalusername
                                                              AND pa.primaryaffiliation = 1
                            WHERE   NOT EXISTS ( SELECT *
                                                 FROM   [User.Account].[User] b
                                                 WHERE  b.internalusername = u.internalusername )
                                    AND NOT EXISTS ( SELECT *
                                                     FROM   [Profile.Import].[User] b
                                                     WHERE  b.internalusername = u.internalusername )

                    SET IDENTITY_INSERT [User.Account].[User] OFF
                END

					-- faculty ranks
            INSERT  INTO [Profile.Data].[Person.FacultyRank]
                    ( FacultyRank ,
                      FacultyRankSort ,
                      Visible
					        
                    )
                    SELECT DISTINCT
                            facultyrank ,
                            facultyrankorder ,
                            1
                    FROM    [Profile.Import].PersonAffiliation p
                    WHERE   NOT EXISTS ( SELECT *
                                         FROM   [Profile.Data].[Person.FacultyRank] a
                                         WHERE  a.facultyrank = p.facultyrank )

					-- person
			DECLARE @newPersonIDTable TABLE (personID INT)	
            IF @use_internalusername_as_pkey = 0 
                BEGIN
								
                    INSERT  INTO [Profile.Data].Person
                            ( UserID ,
                              FirstName ,
                              LastName ,
                              MiddleName ,
                              DisplayName ,
                              Suffix ,
                              IsActive ,
                              EmailAddr ,
                              Phone ,
                              Fax ,
                              AddressLine1 ,
                              AddressLine2 ,
                              AddressLine3 ,
                              AddressLine4 ,
                              city ,
                              state ,
                              zip ,
                              Building ,
                              Floor ,
                              Room ,
                              AddressString ,
                              Latitude ,
                              Longitude ,
                              FacultyRankID ,
                              InternalUsername ,
                              Visible
						        
                            )
							OUTPUT inserted.PersonID into @newPersonIDTable
                            SELECT  UserID ,
                                    ISNULL(p.FirstName, '') ,
                                    ISNULL(p.LastName, '') ,
                                    ISNULL(p.MiddleName, '') ,
                                    ISNULL(p.DisplayName, '') ,
                                    ISNULL(Suffix, '') ,
                                    p.IsActive ,
                                    p.EmailAddr ,
                                    Phone ,
                                    Fax ,
                                    AddressLine1 ,
                                    AddressLine2 ,
                                    AddressLine3 ,
                                    AddressLine4 ,
                                    city ,
                                    state ,
                                    zip ,
                                    Building ,
                                    Floor ,
                                    Room ,
                                    AddressString ,
                                    Latitude ,
                                    Longitude ,
                                    FacultyRankID ,
                                    p.InternalUsername ,
                                    p.isvisible
                            FROM    [Profile.Import].Person p
                                    OUTER APPLY ( SELECT TOP 1
                                                            internalusername ,
                                                            facultyrankid ,
                                                            facultyranksort
                                                  FROM      [Profile.import].[PersonAffiliation] pa
                                                            JOIN [Profile.Data].[Person.FacultyRank] fr ON fr.facultyrank = pa.facultyrank
                                                  WHERE     pa.internalusername = p.internalusername
                                                  ORDER BY  facultyranksort ASC
                                                ) a
                                    JOIN [User.Account].[User] u ON u.internalusername = p.internalusername
                            WHERE   NOT EXISTS ( SELECT *
                                                 FROM   [Profile.Data].Person b
                                                 WHERE  b.internalusername = p.internalusername )	   
                END
            ELSE 
                BEGIN
						
                    SET IDENTITY_INSERT [Profile.Data].Person ON
                    INSERT  INTO [Profile.Data].Person
                            ( personid ,
                              UserID ,
                              FirstName ,
                              LastName ,
                              MiddleName ,
                              DisplayName ,
                              Suffix ,
                              IsActive ,
                              EmailAddr ,
                              Phone ,
                              Fax ,
                              AddressLine1 ,
                              AddressLine2 ,
                              AddressLine3 ,
                              AddressLine4 ,
                              Building ,
                              Floor ,
                              Room ,
                              AddressString ,
                              Latitude ,
                              Longitude ,
                              FacultyRankID ,
                              InternalUsername ,
                              Visible
						        
                            )
							OUTPUT inserted.PersonID into @newPersonIDTable
                            SELECT  p.internalusername ,
                                    userid ,
                                    ISNULL(p.FirstName, '') ,
                                    ISNULL(p.LastName, '') ,
                                    ISNULL(p.MiddleName, '') ,
                                    ISNULL(p.DisplayName, '') ,
                                    ISNULL(Suffix, '') ,
                                    p.IsActive ,
                                    p.EmailAddr ,
                                    Phone ,
                                    Fax ,
                                    AddressLine1 ,
                                    AddressLine2 ,
                                    AddressLine3 ,
                                    AddressLine4 ,
                                    Building ,
                                    Floor ,
                                    Room ,
                                    AddressString ,
                                    Latitude ,
                                    Longitude ,
                                    FacultyRankID ,
                                    p.InternalUsername ,
                                    p.isvisible
                            FROM    [Profile.Import].Person p
                                    OUTER APPLY ( SELECT TOP 1
                                                            internalusername ,
                                                            facultyrankid ,
                                                            facultyranksort
                                                  FROM      [Profile.import].[PersonAffiliation] pa
                                                            JOIN [Profile.Data].[Person.FacultyRank] fr ON fr.facultyrank = pa.facultyrank
                                                  WHERE     pa.internalusername = p.internalusername
                                                  ORDER BY  facultyranksort ASC
                                                ) a
                                    JOIN [User.Account].[User] u ON u.internalusername = p.internalusername
                            WHERE   NOT EXISTS ( SELECT *
                                                 FROM   [Profile.Data].Person b
                                                 WHERE  b.internalusername = p.internalusername )  
                    SET IDENTITY_INSERT [Profile.Data].Person OFF

                END

			INSERT INTO [Framework.].[Log.Activity] (userId, personId, methodName, property, privacyCode, param1, param2) 
			SELECT 0, PersonID, '[Profile.Import].[LoadProfilesData]', null, null, 'Person Insert', null FROM @newPersonIDTable
						-- add personid to user
            UPDATE  u
            SET     u.personid = p.personid
            FROM    [Profile.Data].Person p
                    JOIN [User.Account].[User] u ON u.userid = p.userid


					-- person affiliation
            INSERT  INTO [Profile.Data].[Person.Affiliation]
                    ( PersonID ,
                      SortOrder ,
                      IsActive ,
                      IsPrimary ,
                      InstitutionID ,
                      DepartmentID ,
                      DivisionID ,
                      Title ,
                      EmailAddress ,
                      FacultyRankID
					        
                    )
                    SELECT  p.personid ,
                            affiliationorder ,
                            1 ,
                            primaryaffiliation ,
                            InstitutionID ,
                            DepartmentID ,
                            DivisionID ,
                            c.title ,
                            c.emailaddr ,
                            fr.facultyrankid
                    FROM    [Profile.Import].PersonAffiliation c
                            JOIN [Profile.Data].Person p ON c.internalusername = p.internalusername
                            LEFT JOIN [Profile.Data].[Organization.Institution] i ON i.institutionname = c.institutionname
                            LEFT JOIN [Profile.Data].[Organization.Department] d ON d.departmentname = c.departmentname
                            LEFT JOIN [Profile.Data].[Organization.Division] di ON di.divisionname = c.divisionname
                            LEFT JOIN [Profile.Data].[Person.FacultyRank] fr ON fr.facultyrank = c.facultyrank
                    WHERE   NOT EXISTS ( SELECT *
                                         FROM   [Profile.Data].[Person.Affiliation] a
                                         WHERE  a.personid = p.personid
                                                AND ISNULL(a.InstitutionID, '') = ISNULL(i.InstitutionID,
                                                              '')
                                                AND ISNULL(a.DepartmentID, '') = ISNULL(d.DepartmentID,
                                                              '')
                                                AND ISNULL(a.DivisionID, '') = ISNULL(di.DivisionID,
                                                              '') )


					-- person_filters
            INSERT  INTO [Profile.Data].[Person.Filter]
                    ( PersonFilter 
					        
                    )
                    SELECT DISTINCT
                            personfilter
                    FROM    [Profile.Import].PersonFilterFlag b
                    WHERE   NOT EXISTS ( SELECT *
                                         FROM   [Profile.Data].[Person.Filter] a
                                         WHERE  a.personfilter = b.personfilter )


				-- person_filter_relationships
            INSERT  INTO [Profile.Data].[Person.FilterRelationship]
                    ( PersonID ,
                      PersonFilterid
					        
                    )
                    SELECT DISTINCT
                            p.personid ,
                            personfilterid
                    FROM    [Profile.Import].PersonFilterFlag ptf
                            JOIN [Profile.Data].[Person.Filter] pt ON pt.personfilter = ptf.personfilter
                            JOIN [Profile.Data].Person p ON p.internalusername = ptf.internalusername
                    WHERE   NOT EXISTS ( SELECT *
                                         FROM   [Profile.Data].[Person.FilterRelationship] ptf
                                                JOIN [Profile.Data].[Person.Filter] pt2 ON pt2.personfilterid = ptf.personfilterid
                                                JOIN [Profile.Data].Person p2 ON p2.personid = ptf.personid
                                         WHERE  ( p2.personid = p.personid
                                                  AND pt.personfilterid = pt2.personfilterid
                                                ) )												     										     

			-- update changed affiliation in person table
            UPDATE  p
            SET     facultyrankid = a.facultyrankid
            FROM    [Profile.Data].person p
                    OUTER APPLY ( SELECT TOP 1
                                            internalusername ,
                                            facultyrankid ,
                                            facultyranksort
                                  FROM      [Profile.import].[PersonAffiliation] pa
                                            JOIN [Profile.Data].[Person.FacultyRank] fr ON fr.facultyrank = pa.facultyrank
                                  WHERE     pa.internalusername = p.internalusername
                                  ORDER BY  facultyranksort ASC
                                ) a
            WHERE   p.facultyrankid <> a.facultyrankid
			 
			 
			-- Hide/Show Departments
            UPDATE  d
            SET     d.visible = ISNULL(t.v, 0)
            FROM    [Profile.Data].[Organization.Department] d
                    LEFT OUTER JOIN ( SELECT    a.departmentname ,
                                                MAX(CAST(a.departmentvisible AS INT)) v
                                      FROM      [Profile.Import].PersonAffiliation a ,
                                                [Profile.Import].Person p
                                      WHERE     a.internalusername = p.internalusername
                                                AND p.isactive = 1
                                      GROUP BY  a.departmentname
                                    ) t ON d.departmentname = t.departmentname


			-- Apply person active changes to user table
			UPDATE u 
			   SET isactive  = p.isactive
			  FROM [User.Account].[User] u 
			  JOIN [Profile.Data].Person p ON p.PersonID = u.PersonID 
			  
            COMMIT
        END TRY
        BEGIN CATCH
			--Check success
            IF @@TRANCOUNT > 0 
                ROLLBACK

			-- Raise an error with the details of the exception
            SELECT  @ErrMsg = ERROR_MESSAGE() ,
                    @ErrSeverity = ERROR_SEVERITY()

            RAISERROR(@ErrMsg, @ErrSeverity, 1)
        END CATCH	

    END
GO


/**
* Alter [Profile.Data].[Publication.Pubmed.ParsePubMedXML]
* to improve parsing PMCIDs
**/
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
							PMCID=COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(max)'), nref.value('(OtherID[@Source="NLM"][1])','varchar(max)'))
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
					PMCID=COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(max)'), nref.value('(OtherID[@Source="NLM"][1])','varchar(max)'))
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
/**
* Alter [User.Session].[CreateSession]
* to fix bug that returns incorrect sessionID values and overwrites data in other nodes.
**/
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
		DECLARE @NodeIDTable TABLE (nodeId BIGINT)
		INSERT INTO [RDF.].[Node] (ViewSecurityGroup, EditSecurityGroup, Value, ObjectType, ValueHash)
			  OUTPUT Inserted.NodeID INTO @NodeIDTable
			  SELECT IDENT_CURRENT('[RDF.].[Node]'), -50, @baseURI+CAST(IDENT_CURRENT('[RDF.].[Node]') as varchar(50)), 0,
					[RDF.].fnValueHash(null,null,@baseURI+CAST(IDENT_CURRENT('[RDF.].[Node]') as nvarchar(50)))
		SELECT @NodeID = nodeId from @NodeIDTable

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



/**
* New procedure used by Active Directory and Shibboleth authentication modules
**/
GO
CREATE PROCEDURE [User.Account].[AuthenticateExternal] (
	@UserName NVARCHAR(50),
	@UserID INT = NULL OUTPUT,
	@PersonID INT = NULL OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY	
		SELECT @UserID = UserID, @PersonID = PersonID
			FROM [User.Account].[User]
			WHERE UserName = @UserName

	END TRY
	BEGIN CATCH	
		--Check success		
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		IF @@TRANCOUNT > 0  ROLLBACK
			--Raise an error with the details of the exception
		SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

END
GO

PRINT N'Update complete.';


GO
