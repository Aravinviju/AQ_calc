
SELECT DISTINCT 
    MP.identifier MPRN,
	LDZ.code LDZ,
    MA.fromDt,MA.toDt,
	 MA.source,
    MA.consumption industAQ
	INTO #t1 
FROM 
[soenergy].[dbo].[MprnAnnualQuantity] MA,
[soenergy].[dbo].mprn M,
[soenergy].[dbo].MeterPoint MP,
[soenergy].[dbo].[MprnConfigPeriod] MCP,
[soenergy].[dbo].MprnEndUserCategory MEUC,
[soenergy].[dbo].UkGasFullEndUserCategory UGFEUC,
[soenergy].[dbo].UkGasLocalDistribZone LDZ,
[soenergy].[dbo].Account ac,
[soenergy].[dbo].ProductBundle pb,
[soenergy].[dbo].Product p,
[soenergy].[dbo].ProductPropertyAsset ppa,
[soenergy].[dbo].Asset ass
 
WHERE
    M.id=MA.mprnFk
    and
    m.meterPointFk=mp.id
    and
    MEUC.mprnFk = M.id
    and
    MEUC.ukGasFullEndUserCategoryFk = UGFEUC.id
    and
    UGFEUC.ukGasLocalDistribZoneFk = LDZ.id    
    and
    MCP.mprnFK = M.id
    and
    ma.cancelledDttm is null 
    and
    ma.toDt='9999-01-01 00:00:00.0000000'
    and
    mcp.toDt='9999-01-01 00:00:00.0000000'
    and
    ma.source='Industry'
    
    and ac.id=pb.accountFk
    and p.productBundleFk=pb.id
    and ppa.productFk=p.id
    and ass.id=ppa.assetFk
    and ass.id=mp.assetFk
    
    and
    ac.closedDttm is null
    and
    ac.cancelFl = 'N'
	and
	MA.cancelFl = 'N'
	and 
	MA.deleteFl = 'N'
    and
    ac.terminatedUserTblFk is null;


SELECT * FROM #t1 where MPRN = '1003112405'




SELECT DISTINCT [meterPointIdentifier],SerialNum  INTO #t2 FROM
(
SELECT 
[meterPointIdentifier]  
,meterIdentifier SerialNum
FROM 
[soenergy20160101].[dbo].[UtilityInputEvent] uts16
--WHERE
--([readingQuality] =  'Normal' OR [readingQuality] =  'Manual')
--AND 
--([sequenceType] =  'Normal' OR [sequenceType] =  'First')
  
UNION
(
SELECT 
[meterPointIdentifier],
meterIdentifier SerialNum
FROM 
[soenergy20170101].[dbo].[UtilityInputEvent] uts17
--WHERE 
--([readingQuality] =  'Normal' OR [readingQuality] =  'Manual')  
--AND 
--([sequenceType] =  'Normal' OR [sequenceType] =  'First')
)
 
UNION
 
 
(
SELECT 
[meterPointIdentifier],
meterIdentifier SerialNum

FROM 
[soenergy20180101].[dbo].[UtilityInputEvent] uts18
--WHERE 
--([readingQuality] =  'Normal' OR [readingQuality] =  'Manual')  
--AND 
--([sequenceType] =  'Normal' OR [sequenceType] =  'First')
)
) as temp2



SELECT #t1.*, #t2.SerialNum into #t3
FROM
#t1 inner join #t2
ON #t1.MPRN = #t2.meterPointIdentifier

select * from #t3 where MPRN = '1009231500'

-------==================
--/ Change By Arav Begin

DELETE FROM #t3  
WHERE #t3.fromDt not in 
(select max(e.fromDt) from #t3 e where e.MPRN=#t3.MPRN)

--Change By Arav Ends /
-------==================



drop table #t1
drop table #t2
drop table #t3