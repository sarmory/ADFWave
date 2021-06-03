/****** Object:  StoredProcedure [dbo].[MakeWaves]    Script Date: 03/06/2021 16:32:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[MakeWaves]
AS
BEGIN
    SET NOCOUNT ON

	DECLARE @RowCount AS INT
	DECLARE @Wave AS INT

	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[TempWave]') AND type in (N'U'))
		DROP TABLE [dbo].[TempWave]

	CREATE TABLE [dbo].[TempWave](
		[Wave] [int] NOT NULL,
		[TaskId] [bigint] NOT NULL
	)

	-- Get Seed Dependencies
	SET @Wave = 1
	SET @RowCount = 0

	SELECT @RowCount = COUNT(*) FROM tblTask INNER JOIN tblTaskDependency ON tblTask.TaskId = tblTaskDependency.TaskId
	WHERE tblTaskDependency.TaskDependendsOnId IS NULL

	IF @RowCount > 0
	BEGIN
		INSERT INTO TempWave
		SELECT @Wave, tblTask.TaskId FROM tblTask INNER JOIN tblTaskDependency ON tblTask.TaskId = tblTaskDependency.TaskId
		WHERE tblTaskDependency.TaskDependendsOnId IS NULL
	END

	-- Loop through each wave of dependencies
	WHILE @RowCount > 0 AND @Wave <= 99
    BEGIN
		SET @Wave = @Wave + 1
		SET @RowCount = 0
		SELECT @RowCount = COUNT(*)
		FROM  dbo.tblTaskDependency INNER JOIN
				 dbo.TempWave ON dbo.tblTaskDependency.TaskDependendsOnId = dbo.TempWave.TaskId INNER JOIN
				 dbo.tblTaskDependency AS tblTaskDependency_1 ON dbo.tblTaskDependency.TaskId = tblTaskDependency_1.TaskId LEFT OUTER JOIN
				 dbo.TempWave AS TempWave_2 ON dbo.tblTaskDependency.TaskId = TempWave_2.TaskId LEFT OUTER JOIN
				 dbo.TempWave AS TempWave_1 ON tblTaskDependency_1.TaskDependendsOnId = TempWave_1.TaskId
		GROUP BY dbo.tblTaskDependency.TaskId
		HAVING (MIN(ISNULL(TempWave_1.TaskId, 0)) > 0) AND (MIN(ISNULL(TempWave_2.TaskId, 0)) = 0)
		PRINT @RowCount
		IF @RowCount > 0
		BEGIN
			INSERT INTO TempWave
			SELECT @Wave, dbo.tblTaskDependency.TaskId
			FROM  dbo.tblTaskDependency INNER JOIN
						dbo.TempWave ON dbo.tblTaskDependency.TaskDependendsOnId = dbo.TempWave.TaskId INNER JOIN
						dbo.tblTaskDependency AS tblTaskDependency_1 ON dbo.tblTaskDependency.TaskId = tblTaskDependency_1.TaskId LEFT OUTER JOIN
						dbo.TempWave AS TempWave_2 ON dbo.tblTaskDependency.TaskId = TempWave_2.TaskId LEFT OUTER JOIN
						dbo.TempWave AS TempWave_1 ON tblTaskDependency_1.TaskDependendsOnId = TempWave_1.TaskId
			GROUP BY dbo.tblTaskDependency.TaskId
			HAVING (MIN(ISNULL(TempWave_1.TaskId, 0)) > 0) AND (MIN(ISNULL(TempWave_2.TaskId, 0)) = 0)
		END
	END

END
GO


