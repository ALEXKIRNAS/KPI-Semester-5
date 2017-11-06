USE [Study]
GO

-- Task 2.5:  Для всіх «нащадків» (це перше поле: Іванов ) вивести список «предків»
-- через «/», де останнім в ланцюгу є цей «нащадок» ( це друге поле:
-- Іваненко/Іванченко/Іванчук/Іванов)
-- Вивести ієрахію слухач-куратор
ALTER PROCEDURE LISTNER_LEVEL_WITH_NAME
AS 
   WITH names_table([CuratorsId], [CuratorName], [ListnerId], [ListnerName]) AS
   (SELECT [CuratorsId],  
           [L_C].[LastName] AS [CuratorName],
           [ListnerId],
           [L_L].[LastName] AS [ListnerName]
    FROM [dbo].[Curators]
    INNER JOIN [dbo].[Listeners] as [L_C] ON
                [L_C].[ListenerId] = [CuratorsId]
    INNER JOIN [dbo].[Listeners] as [L_L] ON
                [L_L].[ListenerId] = [ListnerId]
   ),
   sub(listener_id, listener_name, lister_path, iscyrcle) AS 
   (SELECT  [CuratorsId], [CuratorName], CAST([CuratorName] AS NVARCHAR(256)), 0
    FROM names_table
    UNION ALL
    SELECT [C].ListnerId, [C].[ListnerName] , 
           CAST(CONCAT(sub.lister_path, '/', CAST([C].[ListnerName] AS NVARCHAR(256))) AS NVARCHAR(256)), 
           (CASE WHEN sub.[listener_id] = [C].[CuratorsId] THEN 1 ELSE 0 END) as iscycle
    FROM sub
    INNER JOIN names_table AS [C] ON 
        [C].[CuratorsId] = [sub].[listener_id]
    WHERE [sub].iscyrcle = 0
    )

   SELECT DISTINCT listener_name, lister_path
   FROM sub
GO

EXEC LISTNER_LEVEL_WITH_NAME
GO
