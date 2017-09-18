-- Завдання: Визначити премети з найбільшою кількістю студентів
-- що забажали складати по них іспити.

USE [Study]
GO

;WITH [counted_table] ([SubjectId], [Counted])
 AS ( 
        SELECT [SubjectId],
               COUNT(*) AS [Counted]
        FROM [dbo].[Tests]
        GROUP BY [SubjectId]
    )

 SELECT [S].[SubjectId],
        [S].[SubjectName]
 FROM [counted_table] AS [C]
 INNER JOIN [dbo].[Subject] AS [S]
            ON [C].[SubjectId] = [S].[SubjectId]
 WHERE [Counted] IN (SELECT MAX([Counted]) FROM [counted_table])

