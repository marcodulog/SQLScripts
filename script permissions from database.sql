--USE prodSupport
USE CGHC_Drug_Him
GO


--CREATE USER [HRP\HRP RAG - CN PRD AppData Reader] for login [HRP\HRP RAG - CN PRD AppData Reader]

--EXECUTE sp_AddRoleMember 'db_datareader', 'HRP\HRP RAG - CN PRD AppData Reader'



-- Often connect to HRPUATDBS601

-- SCRIPT OUT CREATE USERS
SELECT 'CREATE USER [' + name + '] for login [' + name + ']'
FROM sys.database_principals
WHERE 1=1
--and Type = 'U' -- AD User
--and Type = 'S' -- SQL User
--and Type = 'G' -- AD GROUP
AND Type in ('U','G') -- USERS AND GROUPS
AND name <> 'dbo'

-- SCRIPT OUT ADD ROLE MEMBERSHIP
SELECT 'EXECUTE sp_AddRoleMember ''' + roles.name + ''', ''' + users.name + ''''
FROM sys.database_principals users
INNER JOIN sys.database_role_members link
ON link.member_principal_id = users.principal_id
INNER JOIN sys.database_principals roles
ON roles.principal_id = link.role_principal_id
order by 1



-- SCRIPT OUT CREATE USER PERMISSIONS
SELECT 
dp.permission_name collate latin1_general_cs_as    AS Permission,
t.TABLE_SCHEMA + '.' + o.name AS Object,
dpr.name AS Username
, 'GRANT ' + dp.permission_name collate latin1_general_cs_as 
    + ' ON ' 
    + t.TABLE_SCHEMA 
    + '.' 
    + o.name 
    + ' TO [' 
    +  dpr.name
       + ']'
FROM sys.database_permissions AS dp
INNER JOIN sys.objects AS o ON dp.major_id=o.object_id
INNER JOIN sys.schemas AS s ON o.schema_id = s.schema_id
INNER JOIN sys.database_principals AS dpr ON dp.grantee_principal_id=dpr.principal_id
INNER JOIN INFORMATION_SCHEMA.TABLES t
    ON  TABLE_NAME = o.name     

