SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
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
