USE master 
GO 

SELECT 
	serverproperty('machinename') as 'Server Name', 
	isnull(serverproperty('instancename'),serverproperty('machinename')) as 'Instance Name', 
	[name], 
	[is_policy_checked], 
	[is_expiration_checked] 
FROM master.sys.sql_logins 
WHERE ( [is_policy_checked] = 0 
OR [is_expiration_checked] = 0) 
and name not like '##MS_%' 

-- To apply the password policy to an existing login, run the following script.
-- enable complexity 
ALTER LOGIN [<SQL LOGIN>] WITH CHECK_POLICY=ON; 
GO 

-- optional, enable password expiration, can be only enabled if check_policy is enabled 
ALTER LOGIN [<SQL LOGIN>] WITH CHECK_EXPIRATION=ON; 
GO 
