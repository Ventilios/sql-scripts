/************************
-- [Step 0] Initial setup - Table to store results
************************/
DECLARE @QueryString NVARCHAR(MAX);
/* Create temporary table #x */
CREATE TABLE #x ( [dbid] INT NULL, [fullname] VARCHAR(255) NULL, [database_name] VARCHAR(255) NULL, [schema_name] VARCHAR(255) NULL, [table_name] VARCHAR(255) NULL, [rowcount] INT NULL)

/***************************************************************************************
-- [Step 1] Insert the full path - [Database].[Schema].[Table] - into the #x temp table 
***************************************************************************************/
EXEC sp_msforeachdb 'USE [?]
insert into #x ([dbid], [fullname], [database_name], [schema_name], [table_name]) SELECT DB_ID("?"), ''['' + "?" + '']''
+ ''.'' + QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)) + ''.'' + QUOTENAME(sOBJ.name) AS [TableName],
''['' + "?" + '']'', QUOTENAME(SCHEMA_NAME(sOBJ.schema_id)), QUOTENAME(sOBJ.name)
FROM sys.objects AS sOBJ WHERE sOBJ.type = ''U'' AND sOBJ.is_ms_shipped = 0x0 ORDER BY SCHEMA_NAME(sOBJ.schema_id), sOBJ.name;'

/************************************************************
-- [Step 2] Update #x with rowcounts for each database and table
************************************************************/
SELECT @QueryString = COALESCE(@QueryString + ' ','')
+ 'UPDATE #x SET [rowcount] = inner_query.[rowcount]'
+ 'from #x x inner join ( SELECT ''' + [fullname] + ''' as [fullname], COUNT(*) AS [RowCount] FROM '
+ [fullname] + ' inner_query WITH (NOLOCK) ) inner_query '
+ 'ON x.[fullname] = inner_query.[fullname]'
FROM #x
WHERE [dbid] > 4 -- Exclude system databases!

/*************************************
-- [Step 3] Perform the actual updates 
*************************************/
EXEC sp_executesql @QueryString

/***********************************************************
-- [Step 4] Report the data, only user databases (dbid > 4) 
***********************************************************/
SELECT * FROM #x WHERE [dbid] > 4

/*** Cleanup?! ***/
DROP TABLE #x
