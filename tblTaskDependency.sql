/****** Object:  Table [dbo].[tblTaskDependency]    Script Date: 03/06/2021 16:34:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblTaskDependency](
	[TaskDependencyId] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskId] [bigint] NULL,
	[TaskDependendsOnId] [bigint] NULL
) ON [PRIMARY]
GO


