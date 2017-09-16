-- Alexander Zarichkovyi
-- Group: IP-51
-- Variant: 6
-- Task: Навчання з охорони праці


-- Version: 2 (Sep 16, 2017)

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
    [PassedDate] DATE NULL,
    CONSTRAINT PK_TestId PRIMARY KEY CLUSTERED (TestId))


CREATE TABLE [TestsSchedule] (
    [SheduleId] INT IDENTITY(1,1) NOT NULL,
    [SubjectId] INT NOT NULL FOREIGN KEY REFERENCES [Subject]([SubjectId]),
    [ListenerId] INT NOT NULL FOREIGN KEY REFERENCES [Listeners]([ListenerId]),
    [AccessDate] DATE NOT NULL,
    [CloseDate] DATE NOT NULL,
    CONSTRAINT PK_SheduleId PRIMARY KEY CLUSTERED (SheduleId))
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
       (4, 1, '2017-12-26'),
       (1, 2, '2017-12-28'),
       (2, 3, '2017-06-29'),
       (3, 4, '2017-06-28'),
       (4, 4, NULL),
       (3, 3, NULL),
       (3, 4, NULL)


INSERT INTO [dbo].[TestsSchedule] ([SubjectId], [ListenerId], [AccessDate], [CloseDate])
VALUES (1, 1, '2017-11-30', '2017-12-30'),
       (1, 2, '2017-11-29', '2017-12-29'),
       (2, 3, '2017-05-30', '2017-06-30'),
       (3, 4, '2017-05-30', '2017-06-30'),
       (4, 4, '2017-06-21', '2017-07-31'),
       (3, 3, '2017-06-21', '2018-07-31'),
       (3, 4, '2017-06-21', '2018-07-31')


-----------------------------------------------------
-- Subtask 2: QUERIES
GO

-- Запит з використанням агрегуючих функцій та конструкції HAVING.
-- Виводить ід всіх студентів, які склали всі іспити та дати складання останнього іспиту
SELECT [ListenerId], 
        MAX([PassedDate]) AS [Worth_date]
FROM [dbo].[Tests] 
GROUP BY [ListenerId] 
HAVING COUNT([PassedDate]) = (SELECT COUNT([SubjectId]) FROM [Subject])
GO

-- Запит з перетворенням типу даних результату запиту або формату дати
-- Визначає настрій викладачі в залежності від кількості студентів що не закрили сесію
-- Перетворення INT -> STR

SELECT CASE COUNT(*)  
            WHEN 0 THEN '=)'
            WHEN 1 THEN ';)'
            ELSE ':(' 
       END AS [Teachers_mood]
    FROM [dbo].TestsSchedule AS [TS] 
    INNER JOIN [dbo].[Listeners] AS [L]
              ON [TS].[ListenerId] = [L].[ListenerId]
    INNER JOIN [dbo].[Tests] AS [T]
              ON [T].[ListenerId] = [TS].[ListenerId] AND
                 [TS].[SubjectId] = [T].[SubjectId]
    WHERE ([T].[PassedDate] IS NULL) AND
          ([TS].[CloseDate] > GETDATE()) 

-- Запит з пошуком по фрагменту текстового поля. (Ех: знайти всі прізвища, що закінчуються на «yi»)
SELECT * 
FROM [dbo].[Listeners]
WHERE [LastName] LIKE '%[y][i]'
GO

-- Запит зі вставкою будь-якого значення в поле результату запиту, що набуло
-- значення NULL в результаті запиту (Ех: якщо прізвище «AUDI», що
-- купив, - NULL, поставити символ «_» оператор NVL або CASE ).

-- Копіювання таблиці Tests в архівну таблицю TestsArchive з заміною усіх
-- нульвих значень дат на фіксовану дату 01.01.1800

CREATE TABLE [TestsArchive] (
    [TestId] INT NOT NULL,
    [SubjectId] INT NOT NULL,
    [ListenerId] INT NOT NULL,
    [PassedDate] DATE NOT NULL)

INSERT INTO [dbo].[TestsArchive]
SELECT [TestId]
      ,[SubjectId]
      ,[ListenerId]
      ,ISNULL([PassedDate], '1800-01-01')
FROM [dbo].[Tests]

DROP TABLE [dbo].[TestsArchive]
GO

-----------------------------------------------------
-- Subtask 3: QUERIES
GO

-- Де працюють слухачі що
-- склали іспит з теми “ Назва
-- теми ” до дати “Дата”

CREATE PROCEDURE WORKPLACE_LISTNERS_PASSED_SUBJECT
    @subject_id INT,
    @pass_date DATE
AS 
    SELECT [L].[FirstName],
           [L].[LastName],
           [L].[WorkPlace]
    FROM [dbo].[Tests] AS [T] 
    INNER JOIN [dbo].[Listeners] AS [L]
              ON [T].[ListenerId] = [L].[ListenerId]
    WHERE [T].[SubjectId] = @subject_id AND
          [T].[PassedDate] <= @pass_date
GO

EXEC [dbo].[WORKPLACE_LISTNERS_PASSED_SUBJECT] 1, '2017-12-29'
GO

-- Які слухачі вчасно склали
-- іспити з теми “Назва теми”
-- (Список за алфавітом)

CREATE PROCEDURE PASSED_STUDENTS
    @subject_id INT
AS 
   SELECT [L].[FirstName],
           [L].[LastName]
    FROM [dbo].TestsSchedule AS [TS] 
    INNER JOIN [dbo].[Listeners] AS [L]
              ON [TS].[ListenerId] = [L].[ListenerId]
    INNER JOIN [dbo].[Tests] AS [T]
              ON [T].[ListenerId] = [TS].[ListenerId] AND
                 [TS].[SubjectId] = [T].[SubjectId]
    WHERE [TS].[SubjectId] = @subject_id AND
          ([T].[PassedDate] BETWEEN [TS].[AccessDate] AND [TS].[CloseDate])
    ORDER BY [L].[FirstName], [L].[LastName]
GO

EXEC [dbo].[PASSED_STUDENTS] 2
GO

-- Визначити які слухачі були
-- допущені до іспиту з теми “
-- Назва теми ”, але іспити не
-- склали.

CREATE PROCEDURE NOT_PASSED_STUDENTS
    @subject_id INT
AS 
    SELECT [L].[FirstName],
           [L].[LastName]
    FROM [dbo].TestsSchedule AS [TS] 
    INNER JOIN [dbo].[Listeners] AS [L]
              ON [TS].[ListenerId] = [L].[ListenerId]
    INNER JOIN [dbo].[Tests] AS [T]
              ON [T].[ListenerId] = [TS].[ListenerId] AND
                 [TS].[SubjectId] = [T].[SubjectId]
    WHERE [TS].[SubjectId] = @subject_id AND
          ([T].[PassedDate] IS NULL)
GO

EXEC  [dbo].[NOT_PASSED_STUDENTS] 4
GO


 -- Яка кількість слухачів ще
 -- Має можливість скласти
 -- іспит (мають допуск та час до
 -- закінчення прийому іспиту з
 -- теми) з теми “ Назва теми ”.

CREATE PROCEDURE ABLE_TO_PASS_STUDENTS_COUNT
    @subject_id INT
AS 
    SELECT COUNT(*)  AS [Quantity_of_students_able_to_pass_subject]
    FROM [dbo].TestsSchedule AS [TS] 
    INNER JOIN [dbo].[Listeners] AS [L]
              ON [TS].[ListenerId] = [L].[ListenerId]
    INNER JOIN [dbo].[Tests] AS [T]
              ON [T].[ListenerId] = [TS].[ListenerId] AND
                 [TS].[SubjectId] = [T].[SubjectId]
    WHERE [TS].[SubjectId] = @subject_id AND
          ([T].[PassedDate] IS NULL) AND
          ([TS].[CloseDate] > GETDATE()) 
GO

EXEC [dbo].[ABLE_TO_PASS_STUDENTS_COUNT] 3
GO


-- Визначити слухача, що
-- першим склав іспити зі всіх
-- тем.
CREATE PROCEDURE BEST_STUDENT
AS 
    SELECT TOP(1) 
           [L].[FirstName],
           [L].[LastName]
    FROM [dbo].[Listeners] as [L]
    INNER JOIN (
                  SELECT [ListenerId], 
                         MAX([PassedDate]) AS [Worth_date],
                         COUNT([PassedDate]) AS [Subject_count]
                  FROM [dbo].[Tests] 
                  GROUP BY [ListenerId]
                ) AS [B]
              ON [B].[ListenerId] = [L].[ListenerId]
    WHERE [B].[Subject_count] = (SELECT COUNT([SubjectId]) FROM [Subject])
    ORDER BY [B].[Worth_date]
GO

EXEC BEST_STUDENT
GO   
