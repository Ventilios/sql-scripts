# Azure SQL Database and Managed Instance assessment tools and scripts
For SQL Server on a physical box or virtual machine several tools are available to execute an assessment on our instances.  
Some examples are:
- PowerShell Assessment Tool: [Invoke-SqlAssessment](https://learn.microsoft.com/en-us/powershell/module/sqlserver/invoke-sqlassessment?view=sqlserver-ps)
- Azure Data Studio invoking the [SQL Assessment API](https://learn.microsoft.com/en-us/sql/tools/sql-assessment-api/sql-assessment-api-overview?view=sql-server-ver16): [SQL Server Assessment Extension](https://techcommunity.microsoft.com/t5/sql-server-blog/released-sql-server-assessment-extension-for-azure-data-studio/ba-p/1470603)
- Azure Migrate contains an assessment to support migrations: [Azure SQL assessment](https://learn.microsoft.com/en-us/azure/migrate/how-to-create-azure-sql-assessment)
- Azure Data Studio also provides advise and performance recommendations through an extension: [Azure SQL Migration extension](https://learn.microsoft.com/en-us/azure-data-studio/extensions/azure-sql-migration-extension?tabs=connected)
- A Vulnerability Assessment through Windows Defender: [Azure SQL Vulnerability Assessment](https://learn.microsoft.com/en-us/azure/defender-for-cloud/sql-azure-vulnerability-assessment-overview)

But what can we execute on our Azure SQL Database and Managed Instance? Tags: [DB] Azure SQL Database, [MI] Azure SQL Managed Instance, [DB/MI] both supported, [CONF] Customer configurable option.

## General
- [DB/MI] Glenn Berry has a nice set of diagnostic scripts that's also available for Azure SQL Database: [Diagnostic Queries](https://glennsqlperformance.com/resources/)
- [DB/MI] For overall monitoring a new service is introduced within Azure: [Azure SQL Database Watcher](https://techcommunity.microsoft.com/t5/azure-sql-blog/introducing-database-watcher-for-azure-sql/ba-p/4085637)

## Business Continuity

Human Error, Equipment Failure, Natural Disasters, Manmade Disasters. 
- Availability
  - Core Protection software or hardware failures
  - Automated backups protecting agains data deletion or corruption
  - SLA depending on the SKU chosen.
- High Availability
  - Database resilent to zonal failures: [CONF] [Zone Redundancy] ()
  - Business Critical & Premium
- Disaster Recovery - Ability to recover the database from a catastrophic regional failure. Options:
  - [CONF] Failover Groups
  - [CONF] Active Geo Replication
  - ..
