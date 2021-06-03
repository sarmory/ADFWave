/****** Object:  StoredProcedure [dbo].[GetTasks]    Script Date: 03/06/2021 16:35:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetTasks]
(
    @Wave INT
)
AS
BEGIN
    SET NOCOUNT ON

	SELECT dbo.tblTask.TaskId, dbo.tblTask.TaskName, dbo.tblTask.TaskSQL, dbo.tblTask.TaskTarget, dbo.tblTask.TaskWaterMark, dbo.tblTask.TaskIsDelta, dbo.tblTask.TaskTruncate, dbo.TempWave.Wave
	FROM  dbo.TempWave INNER JOIN
	dbo.tblTask ON dbo.TempWave.TaskId = dbo.tblTask.TaskId
	WHERE (dbo.TempWave.Wave = @Wave)

END
GO


