/****** Object:  Table [dbo].[tblTask]    Script Date: 03/06/2021 16:33:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblTask](
	[TaskId] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskName] [nvarchar](50) NULL,
	[TaskSQL] [nvarchar](max) NULL,
	[TaskTarget] [nvarchar](255) NULL,
	[TaskWaterMark] [datetime] NULL,
	[TaskIsDelta] [bit] NULL,
	[TaskTruncate] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


