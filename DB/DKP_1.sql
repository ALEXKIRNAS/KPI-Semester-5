-- Alexander Zarichkovyi
-- Group: IP-51
-- Variant: 6
-- Task: Навчання з охорони праці


-- Version: 1 (Sep 10, 2017)

-----------------------------------------------------
-- Subtask 1: Create database 

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
[PassedDate] DATE NOT NULL,
CONSTRAINT PK_TestId PRIMARY KEY CLUSTERED (TestId))


CREATE TABLE [TestsSchedule] (
    [SheduleId] INT IDENTITY(1,1) NOT NULL,
    [SubjectId] INT NOT NULL FOREIGN KEY REFERENCES [Subject]([SubjectId]),
    [ListenerId] INT NOT NULL FOREIGN KEY REFERENCES [Listeners]([ListenerId]),
    [AccessDate] DATE NOT NULL,
    [CloseDate] DATE NOT NULL,
    CONSTRAINT PK_SheduleId PRIMARY KEY CLUSTERED (SheduleId))


