USE [master]
GO
SELECT
serverproperty('machinename')as 'Server Name',
isnull(serverproperty('instancename'),serverproperty('machinename')) as 'Instance Name',
master.sys.sql_logins.name as 'Login With Password same as login',
master.sys.sql_logins.is_disabled,
isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=3 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_SysAdminMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=2 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_PublicMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=4 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_SecurityAdminMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=5 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_ServerAdminMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=6 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_SetupAdminMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=7 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_ProcessAdminMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=8 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_DiskAdminMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=9 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_DBCreaterMember
,isnull((Select 1 FROM sys.server_role_members RM inner JOIN master.sys.server_principals Role ON RM.role_principal_id = role.principal_id AND principal_id=10 AND rm.member_principal_id=master.sys.sql_logins.principal_id),0) AS is_BulkAdminMember
from master.sys.sql_logins
where pwdcompare(master.sys.sql_logins.name,password_hash)=1
order by name
option (maxdop 1);
GO
