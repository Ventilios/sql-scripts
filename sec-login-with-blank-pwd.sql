---SQL Logins with blank passwords
select serverproperty('machinename')as 'Server Name',
isnull(serverproperty('instancename'),serverproperty('machinename')) as 'Instance Name',
name as 'Login With Blank Password'
from master.sys.sql_logins
where pwdcompare('',password_hash)=1
order by name
option (maxdop 1)
go