create or replace table UZIS_EXPORT_LISTOPAD_FINAL as
select 
        ROWID
         ,ZDRAVOTNICKEZARIZENIID
//        , PCZ
//        , PCDP
        , NAZEVCELY
//        , ZDRAVOTNICKEZARIZENIKOD	
//        , DRUHZARIZENIKOD	
        , DRUHZARIZENI	
//        , DRUHZARIZENISEKUNDARNI	--- 7997 null  hodnot
        , OBEC	
//        , PSC	
        , ULICE	
        , CISLODOMOVNIORIENTACNI	
        , KRAJ	
        , KRAJKOD
        , OKRES	
        , OKRESKOD	
        , SPRAVNIOBVOD	---- 8871 PHA
        , to_date(DATUMZAHAJENICINNOSTI, 'DD.MM.YYYY') as DATUMZAHAJENICINNOSTI
        , DRUHPOSKYTOVATELE	
        , POSKYTOVATELNAZEV	
//        , ICO
//        , TYPOSOBY
//        , PRAVNIFORMAKOD --- 21 876 rows nulls
        , case 
            when pravniformakod is not null AND typosoby <> 'fyzická osoba' then lower(pravniformakod)
            when pravniformakod is null AND typosoby = 'fyzická osoba' then 'fyzická osoba' --- 1 164 rows nulls
            when pravniformakod is null AND (POSKYTOVATELNAZEV  ilike '%s.r.o.' or POSKYTOVATELNAZEV ilike '%s. r. o.' 
                                             OR POSKYTOVATELNAZEV ilike '%s.r.o' OR POSKYTOVATELNAZEV ilike '%s. r.o.'
                                             OR POSKYTOVATELNAZEV ilike '%spol. s r.o.') then 'spoleènost s ruèením omezeným' --- 874 rows nulls
            when pravniformakod is null AND (POSKYTOVATELNAZEV  ilike '%a.s.' or POSKYTOVATELNAZEV ilike '%a. s.') then 'akciová spoleènost' --- 871 rows
            when pravniformakod is null AND (POSKYTOVATELNAZEV  ilike '%pøíspìvková organizace' or POSKYTOVATELNAZEV ilike '%p.o.') then 'pøíspìvková organizace' --- 863 rows nulls
            when pravniformakod is null AND POSKYTOVATELNAZEV  ilike '%v.o.s.' then 'veøejná obchodní spoleènost' --- 862 rows nulls
            when pravniformakod is null AND POSKYTOVATELNAZEV  ilike '%z.ú.' then 'ústav' --- 861 rows nulls
            when pravniformakod is null AND POSKYTOVATELNAZEV  ilike '%z.s.' then 'spolek'--- 860 rows nulls 
            when pravniformakod is null AND NAZEVCELY ilike '%s.r.o.'  then 'spoleènost s ruèením omezeným'--- 858 rows nulls
            else '--nespecifikováno--'
          end as PRAVNIFORMA
        , case
            when DRUHZARIZENI ilike 'Fakultní nemocnice' OR  DRUHZARIZENI ilike 'Nemocnice'
                    OR DRUHZARIZENI ilike 'Specializovaná nemocnice' 
                        then 'Nemocnice'
            when DRUHZARIZENI ilike 'Sam.ord.prakt.lékaøe pro dìti a dorost' OR  DRUHZARIZENI ilike 'Samost. ordinace všeob. prakt. lékaøe'
                    OR DRUHZARIZENI ilike 'Samostatná ordinace lékaøe specialisty' OR DRUHZARIZENI ilike 'Samostatná ordinace PL - gynekologa'
                    OR DRUHZARIZENI ilike 'Samostatná ordinace PL - stomatologa' OR DRUHZARIZENI ilike 'Sdružení ambulantních zaøízení' 
                    OR DRUHZARIZENI ilike 'Samostatné zaøízení logopeda'OR  DRUHZARIZENI ilike 'Samostatné zaøízení psychologa'
                        then 'Ambulance'
            when DRUHZARIZENI ilike 'Pøeprava pacientù neodkladné péèe' OR  DRUHZARIZENI ilike 'Samost. ordinace všeob. prakt. lékaøe'
                    OR DRUHZARIZENI ilike 'Samostatná ordinace lékaøe specialisty' OR DRUHZARIZENI ilike 'Zdravotnická dopravní služba'
                    OR DRUHZARIZENI ilike 'Zdravotnická zachranná služba' 
                        then 'Doprava pacientù'
            when DRUHZARIZENI ilike 'Sdružené ambulantní zaøízení - malé' OR  DRUHZARIZENI ilike 'Sdružené ambulantní zaøízení - velké'
                        then 'Poliklinika'
            when DRUHPECE ilike 'paliativní péèe' OR DRUHZARIZENI ilike 'Domácí zdravotní péèe' OR  DRUHZARIZENI ilike 'Hospic'
                    OR DRUHZARIZENI ilike 'Léèebna pro dlouhodobì nemocné (LDN)' OR DRUHZARIZENI ilike 'Nemocnice následné péèe'
                    OR DRUHZARIZENI ilike 'Zdravotní péèe v ústavech sociální p.' 
                        then 'Dlouhodobá a následná péèe' 
            when DRUHPECE ilike 'léèebnì rehabilitaèní péèe' OR DRUHZARIZENI ilike 'Rehabilitaèní ústav' OR  DRUHZARIZENI ilike 'Samostatné zaøízení fyzioterapeuta'
                         then 'Fyzioterapie, rehabilitace' --- pøemýšlím, jestli nedat samostatnou do ambulancí, pak mùžeme udìlat povornání, jestli jich je víc v lázních nebo v asmosttných ambulancích
            when DRUHZARIZENI ilike 'Samostatná stomatologická laboratoø' OR  DRUHZARIZENI ilike 'Samostatná odborná laboratoø' then 'Laboratoø'
//          --- zatím nepoužívat---  when DRUHZARIZENI ilike 'Psychoterapeutický stacionáø' OR  DRUHZARIZENI ilike 'Samostatné zaøízení psychologa' then 'Psychologie, psychiatrie'
            when DRUHZARIZENI ilike 'Léèebna tuberkul.a respir.nemocí (TRN)' then 'Léèebna tuberkulózy a respiraèních nemocí'
            when DRUHZARIZENI ilike 'Samostatné zaøízení nelékaøe - jiné' then 'Ostatní nezdravotnická zaøízení'
            when DRUHZARIZENI ilike 'Zaøízení LPS' then 'Pohotovost'
            when DRUHPECE ILIKE 'lékárenská péèe' OR DRUHZARIZENI ilike 'Lékárna' then 'Lékárna'
            when DRUHPECE ilike 'protialkoholní a protitoxikomanická záchytná služba' OR DRUHZARIZENI ilike 'Záchytná stanice' then 'Záchytná stanice'
            else druhzarizeni --- 3 372 rows které nespadají do pravidel výše
          end as poskytovatel_skupina
//          pøemýšlím, zda do toho motat ten druh péèe, tady se jedná jen o zaøízení
        ,OBORPECE --- 2353 null
        , case
            when oborpece is null AND DRUHZARIZENI  ilike 'Samost. ordinace všeob. prakt. lékaøe'  then 'všeobecné praktické lékaøství'
            when oborpece is null AND DRUHZARIZENI  ilike 'Sam.ord.prakt.lékaøe pro dìti a dorost'  then 'praktické lékaøství pro dìti a dorost'
            when oborpece is null AND DRUHZARIZENI  ilike 'Samostatná ordinace PL - stomatologa'  then 'zubní lékaøství'
            when oborpece is null AND DRUHZARIZENI  ilike 'Samostatná ordinace PL - gynekologa'  then 'gynekologie a porodnictví'
            when oborpece is null AND DRUHZARIZENI  ilike 'Samostatné zaøízení fyzioterapeuta'  then 'fyzioterapeut'
            else lower(oborpece)
            end as OBORPECE_UPDATE --- 2352 NULL hodnot
        , FORMAPECE
        , DRUHPECE
//        , GPS
        , "latitude" as LATITUDE	
        , "longitude" as LONGITUDE     
from uzis_export_listopad_all;

create or replace table UZIS_EXPORT_LISTOPAD_FINAL as
select 1 as num, *
        , date_part(year, current_date()) - date_part(year, DATUMZAHAJENICINNOSTI)   as let_cinnosti
        , case
            when let_cinnosti < 1 then 'do 1 roka'
            when let_cinnosti between 1 AND 4 then '1-4 roky'
            when let_cinnosti between 5 AND 9 then '5-9 let'
            when let_cinnosti between 10 AND 19 then '10-19 let'
            when let_cinnosti between 20 AND 29 then '20-29 let'
            else '30+ let'
          end as kategorie_praxe
from UZIS_EXPORT_LISTOPAD_FINAL;

create or replace table UZIS_praktik as --- 6858
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike '%praktické lékaøství' and oborpece_update <> 'praktické lékaøství pro dìti a dorost';

create or replace table UZIS_pediatr as
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike 'praktické lékaøství pro dìti a dorost';

---- 2596

create or replace table UZIS_gyn as --- 2557
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike '%gynekologie%';

create or replace table UZIS_lekarny as --- 2461 
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike '%praktické lékárenství';

create or replace table UZIS_zubari as --- 6839 
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike 'klinická stomatologie' or  oborpece_update ilike 'zubní lékaøství';