-- Alexander Zarichkovyi
-- Group: IP-51
-- Variant: 6
-- Task: �������� � ������� �����


-- Version: 0.8, build #3 (Oct 06, 2017)

-----------------------------------------------------
-- Subtask 0: Create database 

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
-- �������������� count() (��� ����-��� ���� ��������� �������), partition
-- by, order by �� �����, �� ����� ����� ����� ���������, ��� ��
-- ������������ �������� �������

--  ��������� ���� ������
--  ��� ������� �������� ���������� ���� �����
--  ����� �������� = ʳ������ �������� * ֳ�� ��������

-- � ������������� ���������� ��������
SELECT DISTINCT
       [T].[SubjectId],
       SUM([S].[SubjectPrice]) OVER (PARTITION BY [T].[SubjectId]) AS [SubjectIncome]
FROM [dbo].[Tests] AS [T]
INNER JOIN [dbo].[Subject] AS [S]
           ON [S].[SubjectId] = [T].[SubjectId]
WHERE [PassedDate] IS NOT NULL

-- ��� ������������ ���������� �������
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
-- �������������� rank() ��� dense_rank(), partition by, order by �� �����, ��
-- ����� ����� ����� ���������, ��� �� ������������ �������� �������.

--  ��������� ���� ������
--  ��� ������� � �������� ������� ���� ������������ �����, �� �� �������.

-- � ������������� ���������� ��������
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

-- ��� ������������ ���������� �������
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
-- �������������� sliding window (rows), partition by, order by �� �����, ��
-- ����� ����� ����� ���������, ��� �� ������������ �������� �������.

--  ��������� ���� ������
--  ��� ������� ������� �� ������� ���������� ����� ���������� ����� �������
--  �� ����� (����������� ������ ��������� �� +/- ��������� 1 �����)

-- � ������������� ���������� ��������

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

-- ��� ������������ ���������� �������

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
-- �������������� sliding window (range) , partition by, order by �� �����, ��
-- ����� ����� ����� ���������, ��� �� ������������ �������� �������

--  ��������� ���� ������
--  ��� ������� ������� �� ������� ���������� ����� ���������� ����� �������
--  �� ����� (����������� ������ ����� ��������� ��������� � ��������� �����)

-- � ������������� ���������� ��������

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

-- ��� ������������ ���������� �������
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
-- ��������� ����������, �� ������������� ������� lag().
-- �������������� lag(), partition by, order by �� �����, �� ����� �����
-- ����� ���������, ��� �� ������������ �������� �������.

--  ��������� ���� ������
--  ��� ������� ������� �� ������� ���������� ����� ������� �������
--  ��������� �� ����������� ������������ ���������� �����

-- � ������������� ���������� ��������
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

-- ��� ������������ ���������� �������
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
-- ��������� ����������, �� ������������� ������� lead().
-- �������������� lead(), partition by, order by �� �����, �� ����� �����
-- ����� ���������, ��� �� ������������ �������� �������.

--  ��������� ���� ������
--  ��� ������� ������� �� ������� ���������� ����� ������� �������
--  ��������� �� ����������� ���������� ���������� �����

-- � ������������� ���������� ��������
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

-- ��� ������������ ���������� �������
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


-----------------------------------------------------
-- Subtask 2: Normalization
GO


IF EXISTS(SELECT *
          FROM   [dbo].[Tests])
  DROP TABLE [dbo].[Tests]
GO

-- Bad table
CREATE TABLE [Tests] (
    [SubjectName] NVARCHAR(255) NOT NULL,
    [ListenerName] NVARCHAR(255) NOT NULL,
    [SubjectPrice] INT NOT NULL,
    [SubjectDuration] INT NOT NULL,
    [TeacherName] NVARCHAR(255) NOT NULL,
    [TeacherPhoneNumber] NVARCHAR(255) NOT NULL,
    [PassedDate] DATE NULL,
    CONSTRAINT PK_Test PRIMARY KEY CLUSTERED ([SubjectName], [ListenerName]))

INSERT INTO [dbo].[Tests] (
            [SubjectName],
            [ListenerName], 
            [SubjectPrice], 
            [SubjectDuration],
            [TeacherName],
            [TeacherPhoneNumber],
            [PassedDate])
VALUES ('Math', 'Alexander Zarichkovyi', 100, 4, 'Bodnarchyk Semen', '+380123456789,+380987654321', '2017-12-31'),
       ('Physics', 'Alexander Zarichkovyi', 80, 8, 'QWERTY Semen', '+380123456789', '2017-12-29'),
       ('C++', 'Alexander Zarichkovyi', 800, 3, 'Mykha Semen', '+380123456789', '2017-12-20'),
       ('OOP', 'Alexander Zarichkovyi', 1000, 3, 'Kyd Jasper', '+380123456789', '2017-12-01'),
       ('Math', 'Alexander Onbysh', 100, 4, 'Bodnarchyk Semen', '+380123456789,+380987654321', '2017-06-21'),
       ('C++', 'Anna Khuda', 800, 3, 'Mykha Irina', '+380123456789', '2017-12-20'),
       ('OOP', 'Nastya Starchnko', 1000, 3, 'Kyd Jasper', '+380123456789', '2017-12-01') 

SELECT * FROM [dbo].[Tests] 
GO


-- 1 NF
-- ����: �������� ���� ��� ������� ������ ���������.
IF EXISTS(SELECT *
          FROM   [dbo].[Tests])
  DROP TABLE [dbo].[Tests]
GO

CREATE TABLE [Tests] (
    [SubjectName] NVARCHAR(255) NOT NULL,
    [ListenerName] NVARCHAR(255) NOT NULL,
    [SubjectPrice] INT NOT NULL,
    [SubjectDuration] INT NOT NULL,
    [TeacherName] NVARCHAR(255) NOT NULL,
    [TeacherPhoneNumber_01] NVARCHAR(255) NOT NULL,
    [TeacherPhoneNumber_02] NVARCHAR(255) NULL,
    [PassedDate] DATE NULL,
    CONSTRAINT PK_Test PRIMARY KEY CLUSTERED ([SubjectName], [ListenerName]))

INSERT INTO [dbo].[Tests] (
            [SubjectName],
            [ListenerName], 
            [SubjectPrice], 
            [SubjectDuration],
            [TeacherName],
            [TeacherPhoneNumber_01],
            [TeacherPhoneNumber_02],
            [PassedDate])
VALUES ('Math', 'Alexander Zarichkovyi', 100, 4, 'Bodnarchyk Semen', '+380123456789', '+380987654321', '2017-12-31'),
       ('Physics', 'Alexander Zarichkovyi', 80, 8, 'QWERTY Semen', '+380123456789', NULL, '2017-12-29'),
       ('C++', 'Alexander Zarichkovyi', 800, 3, 'Mykha Semen', '+380123456789', NULL, '2017-12-20'),
       ('OOP', 'Alexander Zarichkovyi', 1000, 3, 'Kyd Jasper', '+380123456789', NULL, '2017-12-01'),
       ('Math', 'Alexander Onbysh', 100, 4, 'Bodnarchyk Semen', '+380123456789', '+380987654321', '2017-06-21'),
       ('C++', 'Anna Khuda', 800, 3, 'Mykha Irina', '+380123456789', NULL, '2017-12-20'),
       ('OOP', 'Nastya Starchnko', 1000, 3, 'Kyd Jasper', '+380123456789', NULL, '2017-12-01') 

SELECT * FROM [dbo].[Tests]
GO 

-- 2 NF
-- ����: ������� [SubjectName], [SubjectPrice], [SubjectDuration] � ������ �������
IF EXISTS(SELECT *
          FROM   [dbo].[Tests])
  DROP TABLE [dbo].[Tests]
GO

CREATE TABLE [SubjectDict] (
    [ID] INT IDENTITY(1,1) NOT NULL, 
    [SubjectName] NVARCHAR(255) NOT NULL,
    [SubjectPrice] INT NOT NULL,
    [SubjectDuration] INT NOT NULL,
    CONSTRAINT PK_Test PRIMARY KEY CLUSTERED ([ID]))

CREATE TABLE [Tests] (
    [ListenerName] NVARCHAR(255) NOT NULL,
    [SubjectDescript] INT NOT NULL FOREIGN KEY REFERENCES [SubjectDict]([ID]),
    [TeacherName] NVARCHAR(255) NOT NULL,
    [TeacherPhoneNumber_01] NVARCHAR(255) NOT NULL,
    [TeacherPhoneNumber_02] NVARCHAR(255) NULL,
    [PassedDate] DATE NULL,
    CONSTRAINT PK_Test2 PRIMARY KEY CLUSTERED ([SubjectDescript], [ListenerName]))

INSERT INTO [dbo].[SubjectDict] (
            [SubjectName],
            [SubjectPrice], 
            [SubjectDuration])
VALUES ('Math', 100, 4),
       ('Physics', 80, 8),
       ('C++',  800, 3),
       ('OOP', 1000, 3)

INSERT INTO [dbo].[Tests] (
            [SubjectDescript],
            [ListenerName], 
            [TeacherName],
            [TeacherPhoneNumber_01],
            [TeacherPhoneNumber_02],
            [PassedDate])
VALUES (1, 'Alexander Zarichkovyi', 'Bodnarchyk Semen', '+380123456789', '+380987654321', '2017-12-31'),
       (2, 'Alexander Zarichkovyi', 'QWERTY Semen', '+380123456789', NULL, '2017-12-29'),
       (3, 'Alexander Zarichkovyi', 'Mykha Semen', '+380123456789', NULL, '2017-12-20'),
       (4, 'Alexander Zarichkovyi', 'Kyd Jasper', '+380123456789', NULL, '2017-12-01'),
       (1, 'Alexander Onbysh', 'Bodnarchyk Semen', '+380123456789', '+380987654321', '2017-06-21'),
       (3, 'Anna Khuda', 'Mykha Irina', '+380123456789', NULL, '2017-12-20'),
       (4, 'Nastya Starchnko', 'Kyd Jasper', '+380123456789', NULL, '2017-12-01') 

SELECT * FROM [dbo].[Tests]
GO 

-- 3NF
-- ����: ������� ���������� ��������� � ������� �������� ������� �
-- ������ �������
IF EXISTS(SELECT *
          FROM   [dbo].[Tests])
  DROP TABLE [dbo].[Tests]
GO

CREATE TABLE [TeachersPhones] (
    [ID] INT IDENTITY(1,1) NOT NULL, 
    [TeacherName] NVARCHAR(255) NOT NULL,
    [TeacherPhoneNumber] NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_TeachersPhones PRIMARY KEY CLUSTERED ([ID]))

CREATE TABLE [Tests] (
    [ListenerName] NVARCHAR(255) NOT NULL,
    [SubjectDescript] INT NOT NULL FOREIGN KEY REFERENCES [SubjectDict]([ID]),
    [TeacherName] NVARCHAR(255) NOT NULL,
    [PassedDate] DATE NULL,
    CONSTRAINT PK_Test3 PRIMARY KEY CLUSTERED ([SubjectDescript], [ListenerName]))

INSERT INTO [dbo].[TeachersPhones] (
    [TeacherName],
    [TeacherPhoneNumber]) 
VALUES ('Bodnarchyk Semen', '+380123456789'),
       ('Bodnarchyk Semen', '+380987654321'),
       ('QWERTY Semen', '+380123456789'),
       ('Mykha Semen', '+380123456789'),
       ('Kyd Jasper', '+380123456789'),
       ('Mykha Irina', '+380123456789')

INSERT INTO [dbo].[Tests] (
            [SubjectDescript],
            [ListenerName], 
            [TeacherName],
            [PassedDate])
VALUES (1, 'Alexander Zarichkovyi', 'Bodnarchyk Semen', '2017-12-31'),
       (2, 'Alexander Zarichkovyi', 'QWERTY Semen', '2017-12-29'),
       (3, 'Alexander Zarichkovyi', 'Mykha Semen', '2017-12-20'),
       (4, 'Alexander Zarichkovyi', 'Kyd Jasper', '2017-12-01'),
       (1, 'Alexander Onbysh', 'Bodnarchyk Semen', '2017-06-21'),
       (3, 'Anna Khuda', 'Mykha Irina', '2017-12-20'),
       (4, 'Nastya Starchnko', 'Kyd Jasper', '2017-12-01')

SELECT * FROM [dbo].[Tests]
GO 

-- 3.5NF
-- ����: ������� ������� � ���� ������� (��������� �� ��� �� ��������)
IF EXISTS(SELECT *
          FROM   [dbo].[Tests])
  DROP TABLE [dbo].[Tests]
GO

CREATE TABLE [Teachers](
    [ID] INT IDENTITY(1,1) NOT NULL,
    [SubjectDescript] INT NOT NULL FOREIGN KEY REFERENCES [SubjectDict]([ID]),
    [TeacherName] NVARCHAR(255) NOT NULL
)

CREATE TABLE [Tests] (
    [ListenerName] NVARCHAR(255) NOT NULL,
    [SubjectDescript] INT NOT NULL FOREIGN KEY REFERENCES [SubjectDict]([ID]),
    [PassedDate] DATE NULL,
    CONSTRAINT PK_Test4 PRIMARY KEY CLUSTERED ([SubjectDescript], [ListenerName]))

INSERT INTO [dbo].[Teachers] (
    [TeacherName],
    [SubjectDescript]) 
VALUES ('Bodnarchyk Semen', 1),
       ('QWERTY Semen', 2),
       ('Mykha Semen', 3),
       ('Kyd Jasper', 4),
       ('Mykha Irina', 3)

INSERT INTO [dbo].[Tests] (
            [SubjectDescript],
            [ListenerName], 
            [PassedDate])
VALUES (1, 'Alexander Zarichkovyi', '2017-12-31'),
       (2, 'Alexander Zarichkovyi', '2017-12-29'),
       (3, 'Alexander Zarichkovyi', '2017-12-20'),
       (4, 'Alexander Zarichkovyi', '2017-12-01'),
       (1, 'Alexander Onbysh', '2017-06-21'),
       (3, 'Anna Khuda', '2017-12-20'),
       (4, 'Nastya Starchnko', '2017-12-01')

SELECT * FROM [dbo].[Tests]
GO 
