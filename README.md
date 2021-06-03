# ADFWave
Data Factory / Synapse Pipelines - Using control tables to handle complex copy/transform dependencies.

I recently came across a problem that didn't seem to have a nice fit into an existing standard approach. Though, it's one of the types of tasks that I would have thought was fairly common in ETL / ELT scenarios.

In ADF (Azure Data Factory) it is possible to dynamically copy tables from one place to another, typically using some kind of control table. However this assumes that each table can be considered as complete and ready to go.

What if the process contains a number of dependencies, you would likely see this in the transformation stage. What if you've got a few hundred copy/sql tasks that have dependencies on other copy/sql tasks being complete.

This breaks the model, you can't just use a control table as the process will fail. If you just create pipelines to replicate these dependencies, you end up with something truly horrific. Looking more like a knitting pattern than an ETL process.

You could just sequence the control table into an order that would work and go through each task in sequence, that would work. Problem here is that you would never carry out any tasks in parallel. Which could severely slow down your process.

So... what to do.

After scratching my head for a bit, I came up with an approach that I'm calling "Wave Dependency Loading". It's probably been done before in other technologies. It's rare to come up with something truly new.

Here's an example that I've been using to test my approach. It proposes that a transformation requires 8 tasks to be completed. (SQL Select to Table Load)

Each task has a number of dependencies.

![image](https://user-images.githubusercontent.com/18702185/120648528-a4cb4480-c473-11eb-917d-9dbfe1d11094.png)

It struck me that the best approach would be to do everything you can do first (Early Bias) then move onto what you can do next, then so on..

Working through the example, I found that 5 iterations (Waves) would be required.

![image](https://user-images.githubusercontent.com/18702185/120649010-2fac3f00-c474-11eb-8c0f-20f5c4ed8ff7.png)

Okay, you could just leave it at that and create 5 pipelines. The challenge unfortunately is how to handle hundreds of these dependencies!

So the next step is how to capture the details of the tasks and map their dependencies. Working through the example again, I came up with a simple data structure that would support recording this information.

![image](https://user-images.githubusercontent.com/18702185/120649521-c37e0b00-c474-11eb-893a-83a23a7e40b4.png)

Scratching out a couple of quick and dirty table definitions.

CREATE TABLE [dbo].[tblTask](
	[TaskId] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskName] [nvarchar](50) NULL,
	[TaskSQL] [nvarchar](max) NULL,
	[TaskTarget] [nvarchar](255) NULL,
)
  
 CREATE TABLE [dbo].[tblTaskDependency](
	[TaskDependencyId] [bigint] IDENTITY(1,1) NOT NULL,
	[TaskId] [bigint] NULL,
	[TaskDependendsOnId] [bigint] NULL
)

And then loading the data relevant to the example.

(tblTask)
![image](https://user-images.githubusercontent.com/18702185/120650339-99791880-c475-11eb-9695-95ffe8d8161e.png)

(tblTaskDependency)
![image](https://user-images.githubusercontent.com/18702185/120650516-c62d3000-c475-11eb-9475-37f57076c10a.png)

All good so far, we've now at least modelled the problem, next, how to create the Waves.

I had a few goes at this and decided that a Stored Proc would probably work best.

It's a bit scruffy, again apologies, this is a first cut.

-----------------------

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

-----------------------

Great, I gave it a run and here's the output.

![image](https://user-images.githubusercontent.com/18702185/120652193-6fc0f100-c477-11eb-98bb-d478a4586bdd.png)

