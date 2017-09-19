SELECT [cntr_value]
FROM sys.dm_os_performance_counters
WHERE
	[object_name] LIKE '%Buffer Manager%'
	AND [counter_name] = 'Page life expectancy'



SELECT 
    EventTime,
    record.value('(/Record/ResourceMonitor/Notification)[1]', 'varchar(max)') as [Type],
    record.value('(/Record/ResourceMonitor/IndicatorsProcess)[1]', 'int') as [IndicatorsProcess],
    record.value('(/Record/ResourceMonitor/IndicatorsSystem)[1]', 'int') as [IndicatorsSystem],
    record.value('(/Record/MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS [Avail Phys Mem, Kb],
    record.value('(/Record/MemoryRecord/AvailableVirtualAddressSpace)[1]', 'bigint') AS [Avail VAS, Kb]
FROM (
    SELECT
        DATEADD (ss, (-1 * ((cpu_ticks / CONVERT (float, ( cpu_ticks / ms_ticks ))) - [timestamp])/1000), GETDATE()) AS EventTime,
        CONVERT (xml, record) AS record
    FROM sys.dm_os_ring_buffers
    CROSS JOIN sys.dm_os_sys_info
    WHERE ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR') AS tab
ORDER BY EventTime DESC;

SELECT TYPE, SUM(single_pages_kb) InternalPressure, SUM(multi_pages_kb) ExtermalPressure
FROM sys.dm_os_memory_clerks
GROUP BY TYPE
ORDER BY SUM(single_pages_kb) DESC, SUM(multi_pages_kb) DESC
GO

select counter_name ,cntr_value,cast((cntr_value/1024.0)/1024.0 as numeric(8,2)) as Gb
from sys.dm_os_performance_counters
where counter_name like '%server_memory%';

select convert(xml, record) from sys.dm_os_ring_buffers where ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'


WITH    RingBuffer
          AS (SELECT    CAST(dorb.record AS XML) AS xRecord,
                        dorb.TIMESTAMP
              FROM      sys.dm_os_ring_buffers AS dorb
              WHERE     dorb.ring_buffer_type = 'RING_BUFFER_RESOURCE_MONITOR'
             )
    SELECT  xr.value('(ResourceMonitor/Notification)[1]', 'varchar(75)') AS RmNotification,
            xr.value('(ResourceMonitor/IndicatorsProcess)[1]', 'tinyint') AS IndicatorsProcess,
            xr.value('(ResourceMonitor/IndicatorsSystem)[1]', 'tinyint') AS IndicatorsSystem,
            DATEADD(ss,
                    (-1 * ((dosi.cpu_ticks / CONVERT (FLOAT, (dosi.cpu_ticks / dosi.ms_ticks)))
                           - rb.TIMESTAMP) / 1000), GETDATE()) AS RmDateTime,
            xr.value('(MemoryNode/TargetMemory)[1]', 'bigint') AS TargetMemory,
            xr.value('(MemoryNode/ReserveMemory)[1]', 'bigint') AS ReserveMemory,
            xr.value('(MemoryNode/CommittedMemory)[1]', 'bigint') AS CommitedMemory,
            xr.value('(MemoryNode/SharedMemory)[1]', 'bigint') AS SharedMemory,
            xr.value('(MemoryNode/PagesMemory)[1]', 'bigint') AS PagesMemory,
            xr.value('(MemoryRecord/MemoryUtilization)[1]', 'bigint') AS MemoryUtilization,
            xr.value('(MemoryRecord/TotalPhysicalMemory)[1]', 'bigint') AS TotalPhysicalMemory,
            xr.value('(MemoryRecord/AvailablePhysicalMemory)[1]', 'bigint') AS AvailablePhysicalMemory,
            xr.value('(MemoryRecord/TotalPageFile)[1]', 'bigint') AS TotalPageFile,
            xr.value('(MemoryRecord/AvailablePageFile)[1]', 'bigint') AS AvailablePageFile,
            xr.value('(MemoryRecord/TotalVirtualAddressSpace)[1]', 'bigint') AS TotalVirtualAddressSpace,
            xr.value('(MemoryRecord/AvailableVirtualAddressSpace)[1]',
                     'bigint') AS AvailableVirtualAddressSpace,
            xr.value('(MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]',
                     'bigint') AS AvailableExtendedVirtualAddressSpace
    FROM    RingBuffer AS rb
            CROSS APPLY rb.xRecord.nodes('Record') record (xr)
            CROSS JOIN sys.dm_os_sys_info AS dosi
    ORDER BY RmDateTime DESC;
	
	RESOURCE_MEM_STEADY 