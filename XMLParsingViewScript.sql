-- use for testing


select * from XMLSourceTable
DELETE FROM XMLSourceTable
GO

-- Temporary table to load the XML Source data
BEGIN TRY
	DROP TABLE #XMLSourceTable
END TRY
BEGIN CATCH
END CATCH
GO

-- create the table to hold the data
CREATE TABLE #XMLSourceTable
(XMLData XML NOT NULL);
GO

-- insert the XML Data into this area
INSERT INTO #XMLSourceTable(XMLData)
SELECT *
FROM OPENROWSET(
	BULK 'C:\Scripts\Powershell\XML\test2.xml', SINGLE_BLOB)
AS ImportSource
GO

-- pure hack to remove the name spaces.. not pretty but couldn't get the declare namespaces thing to work
DECLARE @XMLString as NVARCHAR(MAX);
select @XMLString = CAST(XMLData as NVARCHAR(MAX)) 
from #XMLSourceTable

SELECT @XMLSTRING = REPLACE(@XMLSTRING,'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"','')
SELECT @XMLSTRING = REPLACE(@XMLSTRING,'xmlns="http://www.dhcs.ca.gov/EDS/DHCSResponse"','')

-- insert the data back into the table
INSERT INTO XMLSourceTable(XMLData)
SELECT CAST(@XMLString as XML)

-- start querying the data 
WITH XMLNAMESPACES ('http://www.w3.org/2001/XMLSchema-instance' AS xsi,
                     DEFAULT 'http://www.dhcs.ca.gov/EDS/DHCSResponse')
SELECT 
RecordID
, x1.EncounterValidationResponse.value('(EncounterFileName/text())[1]', 'VARCHAR(255)') as EncounterFileName
, x1.EncounterValidationResponse.value('(EncounterSubmitterName/text())[1]', 'VARCHAR(255)') as EncounterSubmitterName
, x1.EncounterValidationResponse.value('(EncounterSubmissionDate/text())[1]', 'DATETIME2') as EncounterSubmissionDate
, x1.EncounterValidationResponse.value('(ValidationStatus/text())[1]', 'VARCHAR(50)') as ValidationStatus
, x2.Trans.value('(@Status)','VARCHAR(50)') as TransStatus
, x3.Enve.value('(@IdentifierName)[1]','VARCHAR(50)') as IdentifierName
, x3.Enve.value('(@IdentifierValue)[1]','VARCHAR(50)') as IdentifierValue
, x4.Encnt.value('(@Status)','VARCHAR(50)') as EncounterStatus
, x4.Encnt.value('(IdentifierType/text())[1]','VARCHAR(50)') as IdentifierType
, x4.Encnt.value('(EncounterReferenceNumber/text())[1]','VARCHAR(50)') as EncounterReferenceNumber
, x4.Encnt.value('(EncounterId/text())[1]','VARCHAR(50)') as EncounterId
, x6.Serv.value('(@Line)[1]','VARCHAR(6)') as ServiceLine
, x7.ServResp.value('(@Severity)[1]','VARCHAR(20)') as ServiceLineResponseSeverity
, x7.ServResp.value('(Id/text())[1]','VARCHAR(20)') as ServiceLineResponseId
, x7.ServResp.value('(Description/text())[1]','VARCHAR(255)') as ServiceLineResponseDescription
, x5.Response.value('(@Severity)[1]','VARCHAR(50)') as ResponseSeverity
, x5.Response.value('(Id/text())[1]','VARCHAR(50)') as ResponseId
, x5.Response.value('(Description/text())[1]','VARCHAR(100)') as ResponseDescription
FROM XMLSourceTable
OUTER APPLY XMLData.nodes('EncounterValidationResponse')                    x1(EncounterValidationResponse)
OUTER APPLY EncounterValidationResponse.nodes('./Transactions/Transaction') x2(Trans)
OUTER APPLY Trans.nodes('Identifiers/Envelope')                             x3(Enve)
OUTER APPLY Trans.nodes('Encounters/Encounter')                             x4(Encnt)
OUTER APPLY Encnt.nodes('EncounterResponses/Response')                      x5(Response)
OUTER APPLY Encnt.nodes('ServiceLines/Service')                             x6(Serv)
OUTER APPLY Serv.nodes('Response')                                          x7(ServResp)

