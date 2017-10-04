-- Alexander Zarichkovyi
-- Group: IP-51
-- Variant: 6
-- Task: Навчання з охорони праці


-- Version: 2 (Oct 04, 2017)

-----------------------------------------------------
-- Subtask 0: Create database 

USE [master]
CREATE DATABASE [Study]
GO

USE [Study]
GO

-- Aditionaly_table_01
CREATE TABLE [Listeners] (
    [ListenerId] INT IDENTITY(1,1) NOT NULL,
    [FirstName] NVARCHAR(255) NOT NULL,
    [LastName] NVARCHAR(255) NOT NULL,
    [WorkPlace] NVARCHAR(255),
    [LastTestDate] DATE,
    CONSTRAINT PK_ListenerId PRIMARY KEY CLUSTERED (ListenerId))

-- Table_02 
-- Dictionory, that used in Table_01
CREATE TABLE [Subject] (
    [SubjectId] INT IDENTITY(1,1) NOT NULL,
    [SubjectName] NVARCHAR(255) NOT NULL,
    [SubjectPrice] INT NOT NULL,
    CONSTRAINT PK_SubjecId PRIMARY KEY CLUSTERED (SubjectId))

-- Table_01
-- Operated data
CREATE TABLE [Tests] (
    [TestId] INT IDENTITY(1,1) NOT NULL,
    [SubjectId] INT NOT NULL FOREIGN KEY REFERENCES [Subject]([SubjectId]),
    [ListenerId] INT NOT NULL FOREIGN KEY REFERENCES [Listeners]([ListenerId]),
    [PassedDate] DATE NULL,
    CONSTRAINT PK_TestId PRIMARY KEY CLUSTERED (TestId))

GO

-------------------------------------------------------
-- Adding data to created tabels

INSERT INTO [dbo].[Listeners] ([FirstName], [LastName], [WorkPlace], [LastTestDate])
VALUES ('Alexander', 'Zarichkovyi', 'RingLabs', '2017-12-31'),
       ('Alexander', 'Onbysh', 'RingLabs', '2017-06-21'),
       ('Anna', 'Khuda', 'NTUU KPI', '2017-06-30'),
       ('Nastya', 'Starchnko', 'MacPaw', '2017-06-29') 


INSERT INTO [dbo].[Subject] ([SubjectName], [SubjectPrice])
VALUES ('Math', 100),
       ('Programming', 1500),
       ('English', 150),
       ('Physics', 125)


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

-----------------------------------------------------
-- Subtask 1: QUERIES
GO

------------------------------------------------------
-- QUERY 1
-- Використовуючи count() (або будь-яку іншу агрегатну функцію), partition
-- by, order by та запит, що дасть такий самий результат, але не
-- застосовуючи аналітичні функції

--  Словесний опис запиту
--  Для кожного предмета підрахувати його дохід
--  Дохід предмета = Кількість слухачів * Ціна предмету

-- З використанням аналітичних фукнкцій
SELECT DISTINCT
       [T].[SubjectId],
       SUM([S].[SubjectPrice]) OVER (PARTITION BY [T].[SubjectId]) AS [SubjectIncome]
FROM [dbo].[Tests] AS [T]
INNER JOIN [dbo].[Subject] AS [S]
           ON [S].[SubjectId] = [T].[SubjectId]
WHERE [PassedDate] IS NOT NULL

-- Без використання аналітичних функцій
SELECT DISTINCT
       [T].[SubjectId],
       SUM([S].[SubjectPrice]) AS [SubjectIncome]
FROM [dbo].[Tests] AS [T]
INNER JOIN [dbo].[Subject] AS [S]
           ON [S].[SubjectId] = [T].[SubjectId]
WHERE [PassedDate] IS NOT NULL
GROUP BY [T].[SubjectId]

------------------------------------------------------

-- QUERY 2
-- Використовуючи rank() або dense_rank(), partition by, order by та запит, що
-- дасть такий самий результат, але не застосовуючи аналітичні функції.

--  Словесний опис запиту
--  Для кожного зі студентів вивести ціну найдорожчого курсу, що він пройшов.

-- З використанням аналітичних фукнкцій
SELECT *
FROM (
        SELECT DISTINCT
               [T].[ListenerId],
               [S].[SubjectPrice],
               RANK() OVER (PARTITION BY [T].[ListenerId] 
                            ORDER BY [S].[SubjectPrice] DESC) AS [Top]
        FROM [dbo].[Tests] AS [T]
        INNER JOIN [dbo].[Subject] AS [S]
                   ON [S].[SubjectId] = [T].[SubjectId]
        WHERE [PassedDate] IS NOT NULL) AS [T]
WHERE [T].[Top] = 1

-- Без використання аналітичних функцій
SELECT DISTINCT
        [T].[ListenerId],
        MAX([S].[SubjectPrice]) AS [Top]
FROM [dbo].[Tests] AS [T]
INNER JOIN [dbo].[Subject] AS [S]
            ON [S].[SubjectId] = [T].[SubjectId]
WHERE [PassedDate] IS NOT NULL
GROUP BY [T].[ListenerId]

------------------------------------------------------

-- QUERY 3
-- Використовуючи sliding window (rows), partition by, order by та запит, що
-- дасть такий самий результат, але не застосовуючи аналітичні функції.

--  Словесний опис запиту
--  Для кожного слухача та кожного придбаного курсу підрахувати сердні розходи
--  на курси (хронологічно середнє поточного та +/- купленого 1 курса)

-- З використанням аналітичних фукнкцій

;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
)

SELECT 
    [T].[TestId],
    [T].[SubjectId],
    [T].[ListenerId],
    AVG([T].[SubjectPrice]) OVER(PARTITION BY [T].[ListenerId] ORDER BY [T].[PassedDate]
                                 ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS [AVG_PRICE],
    [T].[PassedDate]
FROM [merged_table] AS [T]

-- Без використання аналітичних функцій

;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
),
[rows_table] AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [T].[SubjectPrice],
            [T].[PassedDate],
            COUNT([T2].[SubjectId]) AS [ROW_COUNT]
    FROM [merged_table] AS [T], [merged_table] AS [T2]
    WHERE [T].[PassedDate] >= [T2].[PassedDate] 
            AND [T].[ListenerId] = [T2].[ListenerId]
    GROUP BY [T].[TestId], [T].[SubjectId], 
             [T].[ListenerId], [T].[SubjectPrice],
             [T].[PassedDate]
)

SELECT 
    [T].[TestId],
    [T].[SubjectId],
    [T].[ListenerId],
    AVG([T2].[SubjectPrice]) AS [AVG_PRICE],
    [T].[PassedDate]
FROM [rows_table] AS [T], 
     [rows_table] AS [T2]
WHERE ([T2].[ROW_COUNT] BETWEEN [T].[ROW_COUNT] - 1 AND [T].[ROW_COUNT] + 1)
      AND [T2].[ListenerId] = [T].[ListenerId]
GROUP BY [T].[TestId], [T].[SubjectId], 
         [T].[ListenerId], [T].[PassedDate]

-- QUERY 4
-- Використовуючи sliding window (range) , partition by, order by та запит, що
-- дасть такий самий результат, але не застосовуючи аналітичні функції

--  Словесний опис запиту
--  Для кожного слухача та кожного придбаного курсу підрахувати сердні розходи
--  на курси (хронологічно середнє курсів придбаних починаючи з поточного курсу)

-- З використанням аналітичних фукнкцій

;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
)

SELECT 
    [T].[TestId],
    [T].[SubjectId],
    [T].[ListenerId],
    AVG([T].[SubjectPrice]) OVER(PARTITION BY [T].[ListenerId] ORDER BY [T].[PassedDate] DESC
                                 RANGE UNBOUNDED PRECEDING) AS [AVG_PRICE],
    [T].[PassedDate]
FROM [merged_table] AS [T]

-- Без використання аналітичних функцій
;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
)

SELECT 
    [T].[TestId],
    [T].[SubjectId],
    [T].[ListenerId],
    AVG([T2].[SubjectPrice]) AS [AVG_PRICE],
    [T].[PassedDate]
FROM [merged_table] AS [T], 
     [merged_table] AS [T2]
WHERE [T2].[PassedDate] >= [T].[PassedDate]
      AND [T2].[ListenerId] = [T].[ListenerId]
GROUP BY [T].[TestId], [T].[SubjectId], 
         [T].[ListenerId], [T].[PassedDate]


-- QUERY 5
-- Самостійно розібратися, як застосовується функція lag().
-- Використовуючи lag(), partition by, order by та запит, що дасть такий
-- самий результат, але не застосовуючи аналітичні функції.

--  Словесний опис запиту
--  Для кожного слухача та кожного придбаного курсу вивести ватрість
--  поточного та хронологічно попереднього пройденого курса

-- З використанням аналітичних фукнкцій
;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
)

SELECT *
FROM (
    SELECT 
        [T].[TestId],
        [T].[SubjectId],
        [T].[ListenerId],
        [T].[SubjectPrice],
        LAG([T].[SubjectPrice], 1, 0) OVER(PARTITION BY [T].[ListenerId] ORDER BY [T].[PassedDate]) AS [PreviousSubjectPrice],
        [T].[PassedDate]
    FROM [merged_table] AS [T]) AS [T]
WHERE [T].[PreviousSubjectPrice] != 0

-- Без використання аналітичних функцій
;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
),
[rows_table] AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [T].[SubjectPrice],
            [T].[PassedDate],
            COUNT([T2].[SubjectId]) AS [ROW_COUNT]
    FROM [merged_table] AS [T], [merged_table] AS [T2]
    WHERE [T].[PassedDate] >= [T2].[PassedDate] 
            AND [T].[ListenerId] = [T2].[ListenerId]
    GROUP BY [T].[TestId], [T].[SubjectId], 
             [T].[ListenerId], [T].[SubjectPrice],
             [T].[PassedDate]
)

SELECT 
    [T].[TestId],
    [T].[SubjectId],
    [T].[ListenerId],
    [T].[SubjectPrice],
    [T2].[SubjectPrice] AS [PreviousSubjectPrice],
    [T].[PassedDate]
FROM [rows_table] AS [T], 
     [rows_table] AS [T2]
WHERE [T2].[ROW_COUNT] = [T].[ROW_COUNT] - 1 
      AND [T2].[ListenerId] = [T].[ListenerId]

-- QUERY 6
-- Самостійно розібратися, як застосовується функція lead().
-- Використовуючи lead(), partition by, order by та запит, що дасть такий
-- самий результат, але не застосовуючи аналітичні функції.

--  Словесний опис запиту
--  Для кожного слухача та кожного придбаного курсу вивести ватрість
--  поточного та хронологічно наступного пройденого курса

-- З використанням аналітичних фукнкцій
;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
)

SELECT *
FROM (
    SELECT 
        [T].[TestId],
        [T].[SubjectId],
        [T].[ListenerId],
        [T].[SubjectPrice],
        LEAD([T].[SubjectPrice], 1, 0) OVER(PARTITION BY [T].[ListenerId] ORDER BY [T].[PassedDate]) AS [NextSubjectPrice],
        [T].[PassedDate]
    FROM [merged_table] AS [T]) AS [T]
WHERE [T].[NextSubjectPrice] != 0

-- Без використання аналітичних функцій
;WITH [merged_table] ([TestId], [SubjectId], [ListenerId], [SubjectPrice], [PassedDate]) AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [S].[SubjectPrice],
            [T].[PassedDate]
    FROM [dbo].[Tests] AS [T]
    INNER JOIN [dbo].[Subject] AS [S]
                ON [S].[SubjectId] = [T].[SubjectId]
    WHERE [T].[PassedDate] IS NOT NULL
),
[rows_table] AS
(
    SELECT
            [T].[TestId],
            [T].[SubjectId],
            [T].[ListenerId],
            [T].[SubjectPrice],
            [T].[PassedDate],
            COUNT([T2].[SubjectId]) AS [ROW_COUNT]
    FROM [merged_table] AS [T], [merged_table] AS [T2]
    WHERE [T].[PassedDate] >= [T2].[PassedDate] 
            AND [T].[ListenerId] = [T2].[ListenerId]
    GROUP BY [T].[TestId], [T].[SubjectId], 
             [T].[ListenerId], [T].[SubjectPrice],
             [T].[PassedDate]
)

SELECT 
    [T].[TestId],
    [T].[SubjectId],
    [T].[ListenerId],
    [T].[SubjectPrice],
    [T2].[SubjectPrice] AS [NextSubjectPrice],
    [T].[PassedDate]
FROM [rows_table] AS [T], 
     [rows_table] AS [T2]
WHERE [T2].[ROW_COUNT] = [T].[ROW_COUNT] + 1 
      AND [T2].[ListenerId] = [T].[ListenerId]