/******************************************************************************************************
-- Create table with Audits example table.
-- Goal is to limit visibility of audit records AuditPerson = 'Audit1' for database role 'dev_role'.
-- When it drops out of the function, we assume least privilege and a proper security model is applied.
-- Limit your sysadmins, limit db_owners, be aware of object owners (database), using schemas & roles.
-- TODO: Review Trace Flag 3625 to prevent data exposure by for example divide-by-zero or conversion failures. 
-- 
******************************************************************************************************/
SET STATISTICS IO ON 
SET STATISTICS TIME ON 

CREATE TABLE dbo.Audits
(
  AuditID     int  NOT NULL,
  AuditPerson varchar(20),
  AuditDate   date NOT NULL 
  CONSTRAINT df_AuditDate DEFAULT GETDATE(),
  CONSTRAINT pk_Audits PRIMARY KEY(AuditID),
  INDEX ix_Audits_sp (AuditPerson)
);
GO


/****************
-- Add test data
****************/
INSERT dbo.Audits(AuditID, AuditPerson)
SELECT TOP (2000) 
	rn = ROW_NUMBER() OVER (ORDER BY name), 
	N'Audit1' 
FROM sys.all_columns
UNION ALL 
SELECT TOP (20) 
	2000 + ROW_NUMBER() OVER (ORDER BY name), 
	N'Audit2' FROM sys.all_objects
UNION ALL
SELECT 
	2021, N'Audit3' UNION ALL SELECT 2022, N'Audit3';
GO 

-- Add some additional records
INSERT dbo.Audits(AuditID, AuditPerson, AuditDate)
SELECT TOP (20000) 
	rn = ROW_NUMBER() OVER (ORDER BY name)+100000, 
	N'Audit1', getdate()+1 
FROM sys.all_columns
UNION ALL 
SELECT TOP (20) 
	20000+100000 + ROW_NUMBER() OVER (ORDER BY name), 
	N'Audit2', getdate()+1 
FROM sys.all_objects
UNION ALL
SELECT 2021+1000000, N'Audit3', getdate()+1 UNION ALL SELECT 2022+1000000, N'Audit3', getdate()+1;
GO

-- SELECT * FROM dbo.Audits;

/*****************************************************************************
-- Add different users to the database that can be used using EXECUTE AS USER
*****************************************************************************/
-- User with no further permissions on the database
CREATE USER [nopermissions] WITHOUT LOGIN;

-- User with DB_READER role
CREATE USER [usrdbreader] WITHOUT LOGIN;
EXEC sp_addrolemember 'db_datareader', 'usrdbreader';

-- User with DB_OWNER role
CREATE USER [usrdbowner] WITHOUT LOGIN;
EXEC sp_addrolemember 'db_owner', 'usrdbowner';

-- User with column level security applied through a role.
CREATE USER [usrcolumnsec] WITHOUT LOGIN;
CREATE ROLE [dev_role] AUTHORIZATION [dbo];
GRANT SELECT ON [dbo].[Audits] ([AuditPerson]) TO [dev_role];
EXEC sp_addrolemember N'dev_role', N'usrcolumnsec';

-- User with DB_READER role
CREATE USER [usrtworoles] WITHOUT LOGIN;
EXEC sp_addrolemember 'db_datareader', 'usrtworoles';
EXEC sp_addrolemember N'dev_role', N'usrtworoles';
EXEC sp_addrolemember 'db_datareader', 'usrtworoles';

-- Permissions to view Execution Plans
GRANT SHOWPLAN TO usrdbreader, usrdbowner, usrcolumnsec, usrtworoles;

/*****************************************************************************
-- Add different users to the database that can be used using EXECUTE AS USER
*****************************************************************************/ 
CREATE FUNCTION dbo.LimitAudits(@AuditPerson varchar(20))
RETURNS TABLE
WITH SCHEMABINDING
AS
  RETURN 
  (
	SELECT [result] = 1 
	WHERE (
		(@AuditPerson <> 'Audit1' AND IS_ROLEMEMBER('dev_role') = 1) 
	OR  IS_ROLEMEMBER('dev_role') = 0)

	/* -- Alternative strategy
	SELECT [result] FROM (
		SELECT [result] = 1 WHERE @AuditPerson <> 'Audit1' AND IS_ROLEMEMBER('dev_role') = 1
		UNION ALL
		SELECT [result] = 1 WHERE IS_ROLEMEMBER('dev_role') = 0 
	) as R */
  );
GO

-- DROP SECURITY POLICY AuditPolicy
-- ALTER SECURITY POLICY AuditPolicy WITH (STATE = OFF);
-- ALTER SECURITY POLICY AuditPolicy WITH (STATE = ON);

CREATE SECURITY POLICY AuditPolicy
ADD FILTER PREDICATE dbo.LimitAudits(AuditPerson) ON dbo.Audits
WITH (STATE = ON);


/*****************************************************************************
-- Test different scenarios
*****************************************************************************/
-- Generates error and no table output
EXECUTE AS USER = 'usrdbreader'
SELECT * FROM dbo.Audits OPTION (RECOMPILE);
REVERT

-- Generates error and no table output
EXECUTE AS USER = 'usrdbowner'
SELECT * FROM dbo.Audits OPTION (RECOMPILE);
REVERT

-- Generates ERRORS and no table output
EXECUTE AS USER = 'usrcolumnsec'
SELECT * FROM dbo.Audits OPTION (RECOMPILE);
REVERT

-- Works and gives everything back except Audit1
EXECUTE AS USER = 'usrcolumnsec'
SELECT AuditPerson FROM dbo.Audits OPTION (RECOMPILE);
REVERT

-- User with both db_reader and column level security applied. 
EXECUTE AS USER = 'usrtworoles'
SELECT AuditPerson FROM dbo.Audits OPTION (RECOMPILE);
REVERT

-- User with both db_reader and column level security applied. 
-- SELECT * -> db_reader takes precedence, so all columns are visible but rows will be limited by the function.
EXECUTE AS USER = 'usrtworoles'
SELECT * FROM dbo.Audits OPTION (RECOMPILE);
REVERT

-- No access to the data, results into an error.
EXECUTE AS USER = 'nopermissions'
SELECT * FROM dbo.Audits OPTION (RECOMPILE);
REVERT

-- Alternative execution method
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;

DECLARE @sql nvarchar(max) = N'
SELECT AuditPerson FROM dbo.Audits OPTION (RECOMPILE);';

EXEC(@sql) AS USER = N'nopermissions';
EXEC(@sql) AS USER = N'usrdbreader';
EXEC(@sql) AS USER = N'usrdbowner';
EXEC(@sql) AS USER = N'usrcolumnsec';
EXEC(@sql) AS USER = N'usrtworoles';

/*
DROP USER [usrcolumnsec]
DROP USER [nopermissions]
DROP USER [usrdbreader]
DROP USER [usrdbowner]
DROP USER [usrtworoles]

DROP ROLE [dev_role]
DROP SECURITY POLICY AuditPolicy
*/
