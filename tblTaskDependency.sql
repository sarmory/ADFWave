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

INSERT INTO [dbo].[tblTaskDependency] ([TaskId],[TaskDependendsOnId])
VALUES (1,	NULL),
(8,	NULL),
(2,	1),
(7,	1),
(4,	2),
(5,	4),
(3,	4),
(6,	3),
(6,	5),
(6,	7),
(7,	8),
(5,	8),
(5,	7)
GO
