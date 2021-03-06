SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [Framework.].[Log.Activity](
	[activityLogId] [int] IDENTITY(1,1) NOT NULL,
	[userId] [int] NULL,
	[personId] [int] NULL,
	[methodName] [nvarchar](255) NULL,
	[property] [nvarchar](255) NULL,
	[privacyCode] [int] NULL,
	[param1] [nvarchar](255) NULL,
	[param2] [nvarchar](255) NULL,
	[createdDT] [datetime] NOT NULL,
 CONSTRAINT [PK__Log.Activity] PRIMARY KEY CLUSTERED 
(
	[activityLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [Framework.].[Log.Activity] ADD  CONSTRAINT [DF_Log.Activity_createdDT]  DEFAULT (getdate()) FOR [createdDT]
GO
