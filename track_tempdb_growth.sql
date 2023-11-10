/*
-- https://datamasterminds.io/tempdb-is-full/
*/
CREATE EVENT SESSION [Track_Tempdb_Growth] ON SERVER
ADD EVENT sqlserver.database_file_size_change (
	ACTION ( 
		sqlserver.session_id,
		sqlserver.client_app_name, 
		sqlserver.client_hostname, 
		sqlserver.database_name, 
		sqlserver.session_nt_username, 
		sqlserver.sql_text 
		)

	WHERE (
		-- select * from sys.databases;
		[database_id] = ( 2 ) 
	) -- We filter on database_id=2 to get TempDB growth only
)
ADD TARGET package0.event_file ( SET filename = 'F:\data\extended_events_output\Track_Tempdb_Growth.xel',
	max_file_size = ( 10 ) )
WITH (  MAX_MEMORY = 4096 KB,
		EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
		MAX_DISPATCH_LATENCY = 1 SECONDS,
		MAX_EVENT_SIZE = 0 KB,
		MEMORY_PARTITION_MODE = NONE,
		TRACK_CAUSALITY = OFF,
		STARTUP_STATE = ON 
)
GO

-- Don't forget to stop the session when you're done. 
ALTER EVENT SESSION [Track_Tempdb_Growth] ON SERVER STATE = STOP


/*********************************
-- Query Extended Event data
**********************************/
DECLARE @TraceFileLocation nvarchar(255) = N'F:\data\extended_events_output\Track_Tempdb_Growth*.xel';
WITH FileSizeChangedEvent AS (
	SELECT object_name AS Event,
	CONVERT (xml, event_data) AS Data
	FROM sys.fn_xe_file_target_read_file (@TraceFileLocation, NULL, NULL, NULL) 
)
	SELECT FileSizeChangedEvent.Data.value ('(/event/@timestamp)[1]', 'DATETIME') AS EventTime,
	FileSizeChangedEvent.Data.value ('(/event/data/value)[7]', 'BIGINT') AS GrowthInKB,
	-- Added sesion id
	FileSizeChangedEvent.Data.value ('(/event/action/value)[6]', 'VARCHAR(MAX)') AS SQLServerSessionId,
	FileSizeChangedEvent.Data.value ('(/event/action/value)[2]', 'VARCHAR(MAX)') AS ClientUsername,
	FileSizeChangedEvent.Data.value ('(/event/action/value)[4]', 'VARCHAR(MAX)') AS ClientHostname,
	FileSizeChangedEvent.Data.value ('(/event/action/value)[5]', 'VARCHAR(MAX)') AS ClientAppName,
	FileSizeChangedEvent.Data.value ('(/event/action/value)[3]', 'VARCHAR(MAX)') AS ClientAppDBName,
	FileSizeChangedEvent.Data.value ('(/event/action/value)[1]', 'VARCHAR(MAX)') AS SQLCommandText,
	FileSizeChangedEvent.Data.value ('(/event/data/value)[1]', 'BIGINT') AS SystemDuration,
	FileSizeChangedEvent.Data.value ('(/event/data/value)[2]', 'BIGINT') AS SystemDatabaseId,
	FileSizeChangedEvent.Data.value ('(/event/data/value)[8]', 'VARCHAR(MAX)') AS SystemDatabaseFileName,
	FileSizeChangedEvent.Data.value ('(/event/data/text)[1]', 'VARCHAR(MAX)') AS SystemDatabaseFileType,
	FileSizeChangedEvent.Data.value ('(/event/data/value)[5]', 'VARCHAR(MAX)') AS SystemIsAutomaticGrowth,
	FileSizeChangedEvent.Data
FROM FileSizeChangedEvent;
