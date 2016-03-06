--sqlite> .open test.sqlite
--sqlite> .read exec.sql
--select * from readme;

select count(*)  from income_acs ; 87,200recs
select  DISTINCT filetype  from income_acs ; -- "2013e5" & "2013m5"

select count(*)  from consumer_complaints ; 529,464recs
select count(*) from consumer_complaints where TRIM(zipcode) != ''  ;  524,609
select count(DISTINCT zipcode) from consumer_complaints where TRIM(zipcode) != ''  ;  -- 26,835 unique zips


select count(*) from geography_acs; 43,600recs
select count(DISTINCT zcta5) from geography_acs where TRIM(zcta5) != ''  ; --32,989 all unique zips

-------- WIP ----------

select  * from geography_acs where TRIM(zcta5) = '707XX'  ;
select  * from consumer_complaints where TRIM(zipcode) = '707XX' ;

select * from consumer_complaints C  where C.zipcode NOT IN
( select DISTINCT zcta5 from geography_acs where TRIM(zcta5) != '' )   ; --86760 rows i.e Complaint zips not available in Geo table.

select * from geography_acs G where TRIM(G.zcta5)  NOT IN
( select DISTINCT C.zipcode from consumer_complaints C  where TRIM(C.zipcode) != '' )   ; --22106 rows i.e Geo zips not available in Complaint table.



---- Transactional data with join results of Compaints and Geography
select G.FILEID, G.STUSAB, G.SUMLEVEL, G.COMPONENT, G.LOGRECNO, G.UR as Urban, G.PCI as Metro, G.GEOID, G.NAME, C.* from consumer_complaints C, geography_acs G
where C.zipcode = G.zcta5 
AND TRIM(G.zcta5) != '' AND TRIM(C.zipcode) != ''   ;
--LIMIT 1000   --442,704 recs


---- Report 1: Summary data indicating zip codes with the highest compaints Desc with the State they belong to
SELECT COUNT(*) as issue_count, TRANS.zipcode, TRANS.STATE FROM
(
select G.FILEID, G.STUSAB, G.SUMLEVEL, G.COMPONENT, G.LOGRECNO, G.UR as Urban, G.PCI as Metro, G.GEOID, G.NAME, C.* from consumer_complaints C, geography_acs G
where C.zipcode = G.zcta5 
AND TRIM(G.zcta5) != '' AND TRIM(C.zipcode) != ''   
) as TRANS
group by TRANS.zipcode, TRANS.STATE order by  issue_count desc ; --LIMIT 1000   --25,211 recs


---- Report 2: Summary data indicating all valid US regional States with the highest compaints desc
SELECT COUNT(*) as issue_count, TRANS.STATE FROM
(
select G.FILEID, G.STUSAB, G.SUMLEVEL, G.COMPONENT, G.LOGRECNO, G.UR as Urban, G.PCI as Metro, G.GEOID, G.NAME, C.* from consumer_complaints C, geography_acs G
where C.zipcode = G.zcta5 
AND TRIM(G.zcta5) != '' AND TRIM(C.zipcode) != ''   
) as TRANS 
group by TRANS.STATE HAVING TRANS.STATE != '' order by issue_count desc ;  --61 recs
 

---- Report 3: Showing which Products have the highest complaints across US regions
SELECT COUNT(*) as Product_issue_count, TRANS.STATE, TRANS.Product FROM
(
select G.FILEID, G.STUSAB, G.SUMLEVEL, G.COMPONENT, G.LOGRECNO, G.UR as Urban, G.PCI as Metro, G.GEOID, G.NAME, C.* from consumer_complaints C, geography_acs G
where C.zipcode = G.zcta5 
AND TRIM(G.zcta5) != '' AND TRIM(C.zipcode) != ''   
) as TRANS 
group by  TRANS.STATE, TRANS.Product  HAVING TRANS.STATE != '' order by TRANS.Product , Product_issue_count DESC  ;  --594 recs


---- Report 3: Showing which Companies have the highest complaints across US regions
SELECT COUNT(*) as Company_issue_count, TRANS.Company FROM
(
select G.FILEID, G.STUSAB, G.SUMLEVEL, G.COMPONENT, G.LOGRECNO, G.UR as Urban, G.PCI as Metro, G.GEOID, G.NAME, C.* from consumer_complaints C, geography_acs G
where C.zipcode = G.zcta5 
AND TRIM(G.zcta5) != '' AND TRIM(C.zipcode) != ''   
) as TRANS 
group by  TRANS.Company  order by Company_issue_count DESC  ;  --3228 recs
 
 
 