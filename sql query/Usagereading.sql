

/*taking all reads*/
SELECT * INTO #t1 FROM
(
SELECT DISTINCT
[meterPointIdentifier]  
,meterRegisterIdentifier  
,[eventDttm]
,receivedDttm
,[sequenceType]
,[cumulative]
,meterIdentifier SerialNum
,NULL as mrmr
,[readingQuality]
FROM 
[soenergy20160101].[dbo].[UtilityInputEvent] uts16
WHERE
([readingQuality] =  'Normal' OR [readingQuality] =  'Manual') 
UNION
(
SELECT DISTINCT
[meterPointIdentifier],
meterRegisterIdentifier,
[eventDttm],
receivedDttm,
[sequenceType],
[cumulative]
,meterIdentifier SerialNum
,NULL as mrmr
,[readingQuality]
FROM 
[soenergy20170101].[dbo].[UtilityInputEvent] uts17
WHERE 
([readingQuality] =  'Normal' OR [readingQuality] =  'Manual')  
)
UNION
(
SELECT DISTINCT
[meterPointIdentifier],
meterRegisterIdentifier,
[eventDttm],
receivedDttm,
[sequenceType],
[cumulative]
,meterIdentifier SerialNum
,NULL as mrmr
,[readingQuality]
FROM 
[soenergy20180101].[dbo].[UtilityInputEvent] uts18
WHERE 
([readingQuality] =  'Normal' OR [readingQuality] =  'Manual') 
)
union
SELECT DISTINCT
mp.[identifier],
mr.identifier meterRegisterIdentifier,
[eventDttm], 
eventDttm receivedDttm,
[sequenceType],   
[cumulative] 
,m.identifier SerialNum
, mrmr.[metricUnitFk]
,tsq.code
FROM 
[soenergy].[dbo].[MeterReadingManual] mrm, 
[soenergy].[dbo].[MeterReadingManualReading] mrmr, 
[soenergy].[dbo].[MeterPointPhyTimeSeries] mppts,
[soenergy].[dbo].[MeterPointTimeSeries] mpts, 
[soenergy].[dbo].[MeterPoint] mp,
[soenergy].[dbo].[MeterRegister] mr,
soenergy.dbo.Meter m,
soenergy.dbo.TimeSeriesQuality tsq
WHERE 
mrm.id = mrmr.meterReadingManualFk
and
mrmr.[meterPointPhyTimeSeriesFk] = mppts.id 
AND 
mppts.[meterPointTimeSeriesFk] = mpts.[id] 
AND 
mpts.[meterPointFk] = mp.id 
AND 
mrmr.[meterRegisterFk]= mr.id 
and
mr.meterFk=m.id
and
mrm.timeSeriesQualityFk = tsq.id
and tsq.code in ('Normal','Manual')
--order by SerialNum,receivedDttm
) as temp1



/*LDZ with its ALP for each day*/
SELECT * INTO #t2 FROM
(
select gldZ.code,gldZ.name,galp.source,galp.validDt,galp.value ALP from soenergy.dbo.UkGasAnnualLoadProfile galp,
soenergy.dbo.UkGasFullEndUserCategory feuc,
soenergy.dbo.UkGasLocalDistribZone gldZ
where
galp.ukGasFullEndUserCategoryFk=feuc.id
and
feuc.ukGasLocalDistribZoneFk=gldZ.id
) as temp2


SELECT * FROM #t2

/*MPRN with LDZ*/
SELECT * INTO #t3 FROM
(
SELECT DISTINCT 
    MP.identifier MPRN,
	LDZ.code LDZ
FROM 
[soenergy].[dbo].mprn M,
[soenergy].[dbo].MeterPoint MP,
[soenergy].[dbo].[MprnConfigPeriod] MCP,
[soenergy].[dbo].MprnEndUserCategory MEUC,
[soenergy].[dbo].UkGasFullEndUserCategory UGFEUC,
[soenergy].[dbo].UkGasLocalDistribZone LDZ
 
WHERE
    m.meterPointFk=mp.id
    and
    MEUC.mprnFk = M.id
    and
    MEUC.ukGasFullEndUserCategoryFk = UGFEUC.id
    and
    UGFEUC.ukGasLocalDistribZoneFk = LDZ.id
	and
	M.deleteFl='N'        
)

as temp3


SELECT * INTO #t6 FROM
(
(SELECT mpt.identifier meterPointIdentifier,utsevent16.[status] as STAT, utsevent16.cumulative FROM
[soenergy20160101].[dbo].[UtilityTimeSeriesEvent] utsevent16
INNER JOIN [soenergy].[dbo].[MeterPoint] mpt on mpt.id = utsevent16.meterPointFk
WHERE
utsevent16.status='Accepted'
)
UNION
(SELECT mpt.identifier meterPointIdentifier,utsevent17.[status] as STAT, utsevent17.cumulative  FROM

[soenergy20170101].[dbo].[UtilityTimeSeriesEvent] utsevent17
INNER JOIN [soenergy].[dbo].[MeterPoint] mpt on mpt.id = utsevent17.meterPointFk
WHERE
 
utsevent17.status='Accepted'

)
UNION
(SELECT mpt.identifier meterPointIdentifier,utsevent18.[status] as STAT, utsevent18.cumulative  FROM
[soenergy20180101].[dbo].[UtilityTimeSeriesEvent] utsevent18
INNER JOIN [soenergy].[dbo].[MeterPoint] mpt on mpt.id = utsevent18.meterPointFk
WHERE
utsevent18.status='Accepted'
)
) as temp6




/*connection for getting MPRN with for the respective LDZ*/

select #t1.meterPointIdentifier, #t1.SerialNum, #t1.eventDttm, #t1.cumulative, max(#t1.mrmr) mrmr, #t3.LDZ, #t6.STAT
from #t1
inner join #t3 on #t1.meterPointIdentifier = #t3.MPRN
inner join #t6 on #t1.meterPointIdentifier = #t6.meterPointIdentifier
WHERE 
#t6.STAT='Accepted'
and #t1.cumulative = #t6.cumulative
--and #t1.meterPointIdentifier='3023598307'
GROUP BY #t1.meterPointIdentifier, #t1.SerialNum, #t1.eventDttm, #t1.cumulative, #t3.LDZ, #t6.STAT
ORDER BY #t1.meterPointIdentifier

--and #t1.cumulative=99999

select * from #t1 where #t1.meterPointIdentifier='2450462810'

Select * from #t6 where #t6.meterPointIdentifier='2450462810'

Select * from #t3 where #t3.MPRN ='2450462810'



drop table #t1
drop table #t2
drop table #t3
drop table #t6