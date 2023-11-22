/************************************************************************************************************************************************************************************************************************************
************************************************************************************************************************************************************************************************************************************
Source		:	https://gist.github.com/TheRockStarDBA/f5e336e09d2c9bfad52d

Author		: 	Kin Shah
 
Purpose		:	Checks weak passwords on a sql server instance using PWDCOMPARE()
	
				The list of weak passwords can be updated as per your needs. 
				Below is the source of WEAK passwords :
				-- Ref: http://security.blogoverflow.com/category/password/
				-- Ref: http://www.smartplanet.com/blog/business-brains/the-25-worst-passwords-of-2011-8216password-8216123456-8242/20065
 
Disclaimer
The views expressed on my posts on this site are mine alone and do not reflect the views of my company. All posts of mine are provided "AS IS" with no warranties, and confers no rights.
 
The following disclaimer applies to all code, scripts and demos available on my posts:
 
This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment. THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED “AS IS” WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. 
 
I grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: 
 
(i) 	to use my name, logo, or trademarks to market Your software product in which the Sample Code is embedded; 
(ii) 	to include a valid copyright notice on Your software product in which the Sample Code is embedded; and 
(iii) 	to indemnify, hold harmless, and defend me from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
************************************************************************************************************************************************************************************************************************************
*************************************************************************************************************************************************************************************************************************************/
IF OBJECT_ID('tempdb..#weakpasswords') IS NOT NULL
	DROP TABLE #weakpasswords;

IF OBJECT_ID('tempdb..#capitals') IS NOT NULL
	DROP TABLE #capitals;

create table #weakpasswords ([ServerName] sysname
							,[LoginName] sysname
							,[Password] varchar(max)
							,default_database_name sysname
							,is_policy_checked int
							,is_expiration_checked int
							,database_owner varchar(max))


/**********************************************
-- Added to the orginal (as an idea): 
-- Generate some capital versions of the login
**********************************************/
DECLARE @foo TABLE(logins NVARCHAR(255));
INSERT @foo select upper(name) from sys.sql_logins;

;WITH x AS 
(
  SELECT TOP (2048) n = ROW_NUMBER() OVER (ORDER BY Number)
  FROM master.dbo.spt_values ORDER BY Number
)
SELECT
	UPPER(LEFT(f.logins,x.n))+LOWER(SUBSTRING(f.logins,1+x.n, LEN(f.logins))) as logins_l,
	REVERSE(UPPER(LEFT(REVERSE(f.logins),x.n))+LOWER(SUBSTRING(REVERSE(f.logins),1+x.n, LEN(f.logins)))) logins_r
INTO #capitals
FROM x
INNER JOIN @foo AS f
ON x.n <= LEN(f.logins);


DECLARE @WeakPwdList TABLE (WeakPwd NVARCHAR(255))
--Define weak password list
-- Use @@Name if users password contain their name
-- Ref: http://security.blogoverflow.com/category/password/
-- Ref: http://www.smartplanet.com/blog/business-brains/the-25-worst-passwords-of-2011-8216password-8216123456-8242/20065
INSERT INTO @WeakPwdList (WeakPwd)
SELECT name COLLATE Latin1_General_CS_AS FROM sys.sql_logins
UNION
SELECT upper(name) COLLATE Latin1_General_CS_AS FROM sys.sql_logins  
UNION
SELECT lower(name) COLLATE Latin1_General_CS_AS FROM sys.sql_logins
UNION
SELECT logins_l COLLATE Latin1_General_CS_AS from #capitals
UNION 
SELECT logins_r COLLATE Latin1_General_CS_AS from #capitals
UNION
SELECT UPPER(LEFT(LOWER(name),1))+LOWER(SUBSTRING(LOWER(name),2, LEN(name))) COLLATE Latin1_General_CS_AS  FROM sys.sql_logins
UNION
SELECT UPPER(LEFT(LOWER(name),1))+LOWER(SUBSTRING(LOWER(name),2, LEN(name)-2))+UPPER(SUBSTRING(lower(name),LEN(name), LEN(NAME))) COLLATE Latin1_General_CS_AS  FROM sys.sql_logins
UNION
SELECT ''
UNION
SELECT '123'
UNION
SELECT '1234'
UNION
SELECT '12345'
UNION
SELECT '123456'
UNION
SELECT '654321'
UNION
SELECT '12345678'
UNION
SELECT '1234567'
UNION
SELECT '123456789'
UNION
SELECT '111111'
UNION
SELECT '123123'
UNION
SELECT 'abc'
UNION
SELECT 'abc123'
UNION
SELECT 'default'
UNION
SELECT 'guest'
UNION
SELECT '@@Name123'
UNION
SELECT '@@Name'
UNION
SELECT '@@Name@@Name'
UNION
SELECT 'admin'
UNION
SELECT 'Administrator'
UNION
SELECT 'admin123'
UNION
SELECT 'P@ssw0rd1'
UNION
SELECT 'Dealogic01'
UNION
SELECT 'newyork01'
UNION
SELECT 'Password'
UNION
SELECT 'iloveyou'
UNION
SELECT 'Qwerty'
UNION
SELECT 'Qw3rty'
UNION
SELECT 'rockyou'
UNION
SELECT 'Liverpool'
UNION
SELECT 'yorkshire'
UNION
SELECT 'MyPassword'
UNION
SELECT 'banana'
UNION
SELECT '6anana'
UNION
SELECT 'monkey'
UNION
SELECT 'letmein'
UNION
SELECT 'trustno1'
UNION
SELECT 'dragon'
UNION
SELECT 'drag0n1'
UNION
SELECT 'baseball'
UNION
SELECT 'passw0rd'
UNION
SELECT 'shadow'
UNION
SELECT 'superman'
UNION
SELECT 'qazwsx'
UNION
SELECT 'michael'
UNION
SELECT 'football'
UNION
SELECT 'ashley'
UNION
SELECT 'bailey'
UNION
SELECT 'INCORRECT'


INSERT INTO #weakpasswords
SELECT DISTINCT @@servername AS [ServerName]
	,sql_logins.NAME AS [LoginName]
	,CASE 
		WHEN PWDCOMPARE(REPLACE(t2.WeakPwd, '@@Name', REVERSE(sql_logins.NAME)), password_hash) = 0
			THEN REPLACE(t2.WeakPwd, '@@Name', sql_logins.NAME)
		ELSE REPLACE(t2.WeakPwd, '@@Name', REVERSE(sql_logins.NAME))
		END AS [Password]
	,sql_logins.default_database_name
	,sql_logins.is_policy_checked
	,sql_logins.is_expiration_checked
	--,sql_logins.is_disabled
	,(
		SELECT suser_sname(owner_sid)
		FROM sys.databases
		WHERE databases.NAME = sql_logins.default_database_name
		) AS database_owner
FROM sys.sql_logins
INNER JOIN @WeakPwdList t2 ON (
		PWDCOMPARE(t2.WeakPwd, password_hash) = 1
		OR PWDCOMPARE(REPLACE(t2.WeakPwd, '@@Name', sql_logins.NAME), password_hash) = 1
		OR PWDCOMPARE(REPLACE(t2.WeakPwd, '@@Name', REVERSE(sql_logins.NAME)), password_hash) = 1
		)
WHERE sql_logins.is_disabled = 0
ORDER BY sql_logins.NAME


--- report the weak passwords that we found
SELECT * FROM #weakpasswords