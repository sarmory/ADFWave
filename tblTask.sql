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

INSERT INTO [dbo].[tblTask]
           ([TaskName],[TaskSQL],[TaskTarget])
VALUES ('Transform1', 'SELECT FLOOR(RAND() * 1000) AS SomeNumber','tblTaskSomeStuff1'),
('Transform2', 'SELECT SomeNumber FROM  dbo.tblTaskSomeStuff1','tblTaskSomeStuff2'),
('Transform3','SELECT SomeNumber FROM  dbo.tblTaskSomeStuff4','tblTaskSomeStuff3'),
('Transform4','SELECT SomeNumber FROM  dbo.tblTaskSomeStuff2','tblTaskSomeStuff4'),
('Transform5','SELECT * FROM  dbo.tblTaskSomeStuff4 UNION SELECT * FROM dbo.tblTaskSomeStuff7 UNION SELECT * FROM dbo.tblTaskSomeStuff8','tblTaskSomeStuff5'),
('Transform6','SELECT * FROM  dbo.tblTaskSomeStuff3 UNION SELECT * FROM dbo.tblTaskSomeStuff5 UNION SELECT * FROM dbo.tblTaskSomeStuff7','tblTaskSomeStuff6'),
('Transform7','SELECT * FROM  dbo.tblTaskSomeStuff1 UNION SELECT * FROM  dbo.tblTaskSomeStuff8','tblTaskSomeStuff7'),
('Transform8','SELECT FLOOR(RAND() * 1000) AS SomeNumber','tblTaskSomeStuff8')
GO
