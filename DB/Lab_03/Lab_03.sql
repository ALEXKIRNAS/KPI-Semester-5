-- Alexander Zarichkovyi
-- Group: IP-51
-- Variant: 6
-- Task: Навчання з охорони праці


-- Version: 1.0, build #1 (Nov 05, 2017)

-----------------------------------------------------
-- Subtask 1: Create database 

USE [master]
CREATE DATABASE [Study]
GO

USE [Study]
GO

-- Aditional_table_01
CREATE TABLE [Listeners] (
    [ListenerId] INT IDENTITY(1,1) NOT NULL,
    [FirstName] NVARCHAR(255) NOT NULL,
    [LastName] NVARCHAR(255) NOT NULL,
    [WorkPlace] NVARCHAR(255),
    [LastTestDate] DATE,
    CONSTRAINT PK_ListenerId PRIMARY KEY CLUSTERED (ListenerId))

-- Table_01
-- Operated data
CREATE TABLE [Curators] (
    [Id] INT IDENTITY(1,1) NOT NULL,
    [CuratorsId] INT NOT NULL FOREIGN KEY REFERENCES [Listeners]([ListenerId]),
    [ListnerId] INT NOT NULL FOREIGN KEY REFERENCES [Listeners]([ListenerId])
    CONSTRAINT PK_TestId PRIMARY KEY CLUSTERED ([Id]))
GO

-------------------------------------------------------
-- Adding data to created tabels

INSERT INTO [dbo].[Listeners] ([FirstName], [LastName], [WorkPlace], [LastTestDate])
VALUES ('Alexander', 'Zarichkovyi', 'RingLabs', '2017-12-31'),
       ('Alexander', 'Onbysh', 'RingLabs', '2017-06-21'),
       ('Anna', 'Khuda', 'NTUU KPI', '2017-06-30'),
       ('Nastya', 'Starchnko', 'MacPaw', '2017-06-29'),
       ('Alexander', 'Obiednikov', 'RingLabs', '2011-12-29'),
       ('Alexander', 'Malinin', 'RingLabs', '2010-12-29')


INSERT INTO [dbo].[Curators] ([CuratorsId], [ListnerId])
VALUES
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (2, 3),
    (2, 4),
    (2, 5),
    (3, 4),
    (3, 5),
    (4, 5),
    (5, 6)


-----------------------------------------------------
-- Subtask 2: QUERIES
GO

-- Task 2.1: Вивести список всіх «нащадків» вказаного «предка». 
-- Для заданого куратора рекурсивно вивести всіх його слухачів
CREATE PROCEDURE CURATORS_LITENERS
    @curator_id INT
AS 
   WITH sub(listener_id) AS 
   (SELECT ListnerId 
    FROM [dbo].[Curators]
    WHERE CuratorsId = @curator_id
    UNION ALL
    SELECT [C].ListnerId 
    FROM sub
    INNER JOIN [Curators] AS [C] ON 
        [C].[CuratorsId] = [sub].[listener_id]
   )

   SELECT distinct listener_id
   FROM sub
GO

EXEC CURATORS_LITENERS 1 
GO

-- Task 2.2: Вивести список всіх «предків» вказаного «нащадка». 
-- Для заданого слухача рекурсивно вивести усіх його кураторів та їх кураторів
CREATE PROCEDURE LITENERS_CURATORS
    @listner_id INT
AS 
   WITH sub(curator_id) AS 
   (SELECT CuratorsId 
    FROM [dbo].[Curators]
    WHERE [ListnerId] = @listner_id
    UNION ALL
    SELECT [C].CuratorsId 
    FROM sub
    INNER JOIN [Curators] AS [C] ON 
        [C].[ListnerId] = [sub].[curator_id]
   )

   SELECT distinct curator_id
   FROM sub
GO

EXEC LITENERS_CURATORS 5
GO

-- Task 2.3: Вивести список, другий полем якого є «рівень» 
-- (аналог псевдостовпчика level в connect by). 
-- Для заданого куратора вивести усіх його слухачів та рівень слухача
-- в ієрархії слухачів
CREATE PROCEDURE LISTNERS_LEVEL
    @curator_id INT
AS 
   WITH sub(listener_id, listner_level) AS 
   (SELECT ListnerId, 1
    FROM [dbo].[Curators]
    WHERE CuratorsId = @curator_id
    UNION ALL
    SELECT [C].ListnerId , [sub].[listner_level] + 1
    FROM sub
    INNER JOIN [Curators] AS [C] ON 
        [C].[CuratorsId] = [sub].[listener_id]
   )

   SELECT listener_id, MIN(listner_level) as level
   FROM sub
   GROUP BY listener_id
GO

EXEC LISTNERS_LEVEL 1
GO

-- Task 2.4.1: Змінити дані в доданій таблиці так, щоб утворився цикл.-- Написати запит, що видає помилку при зациклюванні. -- Див. запит в задачі 2.3INSERT INTO [dbo].[Curators] ([CuratorsId], [ListnerId])
VALUES
    (6, 1)EXEC LISTNERS_LEVEL 1
GO

-- Task 2.4.2: Змінити цей запит так, щоб помилки не було
CREATE PROCEDURE LISTNERS_LEVEL_ACYRCLE
    @curator_id INT
AS 
   WITH sub(listener_id, listner_level, iscyrcle) AS 
   (SELECT ListnerId, 1, 0
    FROM [dbo].[Curators]
    WHERE CuratorsId = @curator_id
    UNION ALL
    SELECT [C].ListnerId , [sub].[listner_level] + 1, 
           (CASE WHEN sub.[listener_id] = [C].[CuratorsId] THEN 1 ELSE 0 END) as iscycle
    FROM sub
    INNER JOIN [Curators] AS [C] ON 
        [C].[CuratorsId] = [sub].[listener_id]
    WHERE [sub].iscyrcle = 0
    )

   SELECT listener_id, MIN(listner_level) as level
   FROM sub
   GROUP BY listener_id
GO

EXEC LISTNERS_LEVEL_ACYRCLE 1
GO

-- Task 2.5:  Для всіх «нащадків» (це перше поле: Іванов ) вивести список «предків»
-- через «/», де останнім в ланцюгу є цей «нащадок» ( це друге поле:
-- Іваненко/Іванченко/Іванчук/Іванов)-- Вивести ієрахію слухач-кураторCREATE PROCEDURE LISTNER_LEVEL
AS 
   WITH sub(listener_id, lister_path, iscyrcle) AS 
   (SELECT [CuratorsId], CAST([CuratorsId] AS NVARCHAR(256)), 0
    FROM [dbo].[Curators]
    UNION ALL
    SELECT [C].ListnerId , 
           CAST(CONCAT(sub.lister_path, '/', CAST([C].ListnerId AS NVARCHAR(256))) AS NVARCHAR(256)), 
           (CASE WHEN sub.[listener_id] = [C].[CuratorsId] THEN 1 ELSE 0 END) as iscycle
    FROM sub
    INNER JOIN [Curators] AS [C] ON 
        [C].[CuratorsId] = [sub].[listener_id]
    WHERE [sub].iscyrcle = 0
    )

   SELECT DISTINCT listener_id, lister_path
   FROM sub
GO

EXEC LISTNER_LEVEL
GO