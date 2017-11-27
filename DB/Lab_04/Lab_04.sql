-- Alexander Zarichkovyi
-- Group: IP-51
-- Variant: 6
-- Task: Навчання з охорони праці


-- Version: 1 (Nov 27, 2017)

-----------------------------------------------------
-- Subtask 0: Create database 

USE [master]
CREATE DATABASE [Study]
GO

USE [Study]
GO

CREATE TABLE [Listeners] (
    [ListenerId] INT IDENTITY(1,1) NOT NULL,
    [FirstName] NVARCHAR(255) NOT NULL,
    [LastName] NVARCHAR(255) NOT NULL,
    [WorkPlace] NVARCHAR(255),
    [LastTestDate] DATE,
    CONSTRAINT PK_ListenerId PRIMARY KEY CLUSTERED (ListenerId))


CREATE TABLE [Subject] (
    [SubjectId] INT IDENTITY(1,1) NOT NULL,
    [SubjectName] NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_SubjecId PRIMARY KEY CLUSTERED (SubjectId))


CREATE TABLE [Tests] (
    [TestId] INT IDENTITY(1,1) NOT NULL,
    [SubjectId] INT NOT NULL FOREIGN KEY REFERENCES [Subject]([SubjectId]),
    [ListenerId] INT NOT NULL FOREIGN KEY REFERENCES [Listeners]([ListenerId]),
    [PassedDate] DATE NULL,
    CONSTRAINT PK_TestId PRIMARY KEY CLUSTERED (TestId))


CREATE TABLE [PIVOT_TABLE] (
    [SubjectId] INT NOT NULL FOREIGN KEY REFERENCES [Subject]([SubjectId]),
    [2017-12-27] INT NOT NULL, 
    [2017-12-28] INT NOT NULL,
    [2017-12-29] INT NOT NULL)
GO

-------------------------------------------------------
-- Adding data to DB

INSERT INTO [dbo].[Listeners] ([FirstName], [LastName], [WorkPlace], [LastTestDate])
VALUES ('Alexander', 'Zarichkovyi', 'RingLabs', '2017-12-31'),
       ('Alexander', 'Onbysh', 'RingLabs', '2017-06-21'),
       ('Anna', 'Khuda', 'NTUU KPI', '2017-06-30'),
       ('Nastya', 'Starchnko', 'MacPaw', '2017-06-29') 


INSERT INTO [dbo].[Subject] ([SubjectName])
VALUES ('Math'),
       ('Programming'),
       ('English'),
       ('Physics')


INSERT INTO [dbo].[Tests] ([SubjectId], [ListenerId], [PassedDate])
VALUES (1, 1, '2017-12-29'),
       (2, 1, '2017-12-28'),
       (3, 1, '2017-12-27'),
       (4, 1, '2017-12-29'),
       (1, 2, '2017-12-29'),
       (2, 3, '2017-12-29'),
       (3, 4, '2017-12-28'),
       (4, 4, '2017-12-28'),
       (3, 3, '2017-12-28'),
       (3, 4, '2017-12-27')


INSERT INTO [PIVOT_TABLE] 
VALUES (1, 0, 0, 2),
       (2, 0, 0, 1),
       (3, 2, 2, 0),
       (4, 0, 1, 1)


-----------------------------------------------------
-- Subtask 2: QUERIES
GO


-- PIVOT with one aggregation function
-- Task: Count number of students that passed
-- subject in days (27, 28, 29 of Dec, 2017)

SELECT [SubjectId], 
       [2017-12-27], 
       [2017-12-28], 
       [2017-12-29]
FROM (
    SELECT [SubjectId],
           [ListenerId], 
           [PassedDate]
    FROM [dbo].[Tests]
) AS [T]
PIVOT (
    COUNT ([ListenerId])
    FOR [PassedDate] IN
        ([2017-12-29], [2017-12-28], [2017-12-27])
) AS [PVT]
ORDER BY [PVT].[SubjectId]


-- PIVOT with two aggregation functions
-- Task: Print maximum number of students that passed
-- one of subjects in days (27, 28, 29 of Dec, 2017)

SELECT 'Maximum_students_count' AS [Description],
       [2017-12-27], 
       [2017-12-28], 
       [2017-12-29]
FROM (
    SELECT
           COUNT([ListenerId]) AS [Counted], 
           [PassedDate]
    FROM [dbo].[Tests]
    GROUP BY [SubjectId], [PassedDate]
) AS [T]
PIVOT (
    MAX ([Counted])
    FOR [PassedDate] IN
        ([2017-12-29], [2017-12-28], [2017-12-27])
) AS [PVT]


-- UNPIVOT
-- Task: Compress table [PIVOT_TABLE] 

SELECT [SubjectId],
       [Date],
       [Counted]
FROM [PIVOT_TABLE]
UNPIVOT (
    [Counted] FOR [Date] IN 
          ([2017-12-29], [2017-12-28], [2017-12-27])
) AS [UNPVT]
WHERE [UNPVT].[Counted] != 0
