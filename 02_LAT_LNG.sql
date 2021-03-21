--- find empty LAT and LNG

create or replace table UZIS_EXPORT_LISTOPAD_lat_lng_empty as
select * from UZIS_EXPORT_LISTOPAD_UPRAVENO
where gps is null;

--- create concat for geocoding extractor in Keboola

create or replace table UZIS_LISTOPAD_ADDRESS_CONCAT AS
select distinct
        CONCAT(ifnull(Obec, ''), ' ', ifnull(PSC, ''),' ', ifnull(ULICE, ''),' ', 
               ifnull(CISLODOMOVNIORIENTACNI, 		'')) as address_all
FROM UZIS_EXPORT_LISTOPAD_lat_lng_empty;

--- join LAT a LNG from geocoding

create or replace table UZIS_EXPORT_LISTOPAD_lat_lng_concat as --- vytvori table prazdnych GPS se sloupcem concat pro join
select *
        , CONCAT(ifnull(Obec, ''), ' ', ifnull(PSC, ''),' ', ifnull(ULICE, ''),' ', 
               ifnull(CISLODOMOVNIORIENTACNI, 		'')) as concat      
from UZIS_EXPORT_LISTOPAD_lat_lng_empty;

--join doplnìných lat a lng do 324 prázdných radku

create or replace table UZIS_EXPORT_LISTOPAD_LAT_LNG_EMPTY_UPDATE as --- join doplnìných lat a lng do 324 prázdných radku
select empty.rowid, empty.ZdravotnickeZarizeniId, empty.NazevCely, empty.Obec, empty.Ulice, empty.CisloDomovniOrientacni, empty.concat,
        geo."city", geo."streetName", geo."streetNumber",geo."query", geo."latitude", geo."longitude"
from UZIS_EXPORT_LISTOPAD_lat_lng_concat as empty
inner join UZIS_EXPORT_LISTOPAD_LAT_LNG_EMPTY_GEOCODING as geo
            on geo."query" = empty.concat;

--- jen 33 øádkù nedoplnìných
--- jen 15 unikatnich adres nedoplnenych

create or replace table UZIS_EXPORT_LISTOPAD_lat_lng_ALL as
select  t.rowid
        , t.ZDRAVOTNICKEZARIZENIID
        , t.PCZ
        , t.PCDP
        , t.NAZEVCELY
        , t.ZDRAVOTNICKEZARIZENIKOD	
        , t.DRUHZARIZENIKOD	
        , t.DRUHZARIZENI	
        , t.DRUHZARIZENISEKUNDARNI	
        , t.OBEC	
        , t.PSC	
        , t.ULICE	
        , t.CISLODOMOVNIORIENTACNI	
        , t.KRAJ	
        , t.KRAJKOD
        , t.OKRES	
        , t.OKRESKOD	
        , t.SPRAVNIOBVOD	
        , t.DATUMZAHAJENICINNOSTI	
        , t.DRUHPOSKYTOVATELE	
        , t.POSKYTOVATELNAZEV	
        , t.ICO
        , t.TYPOSOBY
        , t.PRAVNIFORMAKOD
        , t.OBORPECE
        , t.FORMAPECE
        , t.DRUHPECE
        , t.GPS
        , up."latitude"	
        , up."longitude"
from UZIS_EXPORT_LISTOPAD_UPRAVENO as t
inner join UZIS_EXPORT_LISTOPAD_LAT_LNG_EMPTY_UPDATE as up
            on up.rowid = t.rowid;

--- 33 rows
create or replace table UZIS_EXPORT_LISTOPAD_ALL as
select * from UZIS_EXPORT_LISTOPAD_lat_lng_ALL
union all 
select * from UZIS_EXPORT_LISTOPAD_UPRAVENO;

create or replace table UZIS_EXPORT_LISTOPAD_ALL as
select * from UZIS_EXPORT_LISTOPAD_ALL
where "latitude" <> '';

-- 61 363