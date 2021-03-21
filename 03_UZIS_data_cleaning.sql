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
            when pravniformakod is not null AND typosoby <> 'fyzick� osoba' then lower(pravniformakod)
            when pravniformakod is null AND typosoby = 'fyzick� osoba' then 'fyzick� osoba' --- 1 164 rows nulls
            when pravniformakod is null AND (POSKYTOVATELNAZEV  ilike '%s.r.o.' or POSKYTOVATELNAZEV ilike '%s. r. o.' 
                                             OR POSKYTOVATELNAZEV ilike '%s.r.o' OR POSKYTOVATELNAZEV ilike '%s. r.o.'
                                             OR POSKYTOVATELNAZEV ilike '%spol. s r.o.') then 'spole�nost s ru�en�m omezen�m' --- 874 rows nulls
            when pravniformakod is null AND (POSKYTOVATELNAZEV  ilike '%a.s.' or POSKYTOVATELNAZEV ilike '%a. s.') then 'akciov� spole�nost' --- 871 rows
            when pravniformakod is null AND (POSKYTOVATELNAZEV  ilike '%p��sp�vkov� organizace' or POSKYTOVATELNAZEV ilike '%p.o.') then 'p��sp�vkov� organizace' --- 863 rows nulls
            when pravniformakod is null AND POSKYTOVATELNAZEV  ilike '%v.o.s.' then 've�ejn� obchodn� spole�nost' --- 862 rows nulls
            when pravniformakod is null AND POSKYTOVATELNAZEV  ilike '%z.�.' then '�stav' --- 861 rows nulls
            when pravniformakod is null AND POSKYTOVATELNAZEV  ilike '%z.s.' then 'spolek'--- 860 rows nulls 
            when pravniformakod is null AND NAZEVCELY ilike '%s.r.o.'  then 'spole�nost s ru�en�m omezen�m'--- 858 rows nulls
            else '--nespecifikov�no--'
          end as PRAVNIFORMA
        , case
            when DRUHZARIZENI ilike 'Fakultn� nemocnice' OR  DRUHZARIZENI ilike 'Nemocnice'
                    OR DRUHZARIZENI ilike 'Specializovan� nemocnice' 
                        then 'Nemocnice'
            when DRUHZARIZENI ilike 'Sam.ord.prakt.l�ka�e pro d�ti a dorost' OR  DRUHZARIZENI ilike 'Samost. ordinace v�eob. prakt. l�ka�e'
                    OR DRUHZARIZENI ilike 'Samostatn� ordinace l�ka�e specialisty' OR DRUHZARIZENI ilike 'Samostatn� ordinace PL - gynekologa'
                    OR DRUHZARIZENI ilike 'Samostatn� ordinace PL - stomatologa' OR DRUHZARIZENI ilike 'Sdru�en� ambulantn�ch za��zen�' 
                    OR DRUHZARIZENI ilike 'Samostatn� za��zen� logopeda'OR  DRUHZARIZENI ilike 'Samostatn� za��zen� psychologa'
                        then 'Ambulance'
            when DRUHZARIZENI ilike 'P�eprava pacient� neodkladn� p��e' OR  DRUHZARIZENI ilike 'Samost. ordinace v�eob. prakt. l�ka�e'
                    OR DRUHZARIZENI ilike 'Samostatn� ordinace l�ka�e specialisty' OR DRUHZARIZENI ilike 'Zdravotnick� dopravn� slu�ba'
                    OR DRUHZARIZENI ilike 'Zdravotnick� zachrann� slu�ba' 
                        then 'Doprava pacient�'
            when DRUHZARIZENI ilike 'Sdru�en� ambulantn� za��zen� - mal�' OR  DRUHZARIZENI ilike 'Sdru�en� ambulantn� za��zen� - velk�'
                        then 'Poliklinika'
            when DRUHPECE ilike 'paliativn� p��e' OR DRUHZARIZENI ilike 'Dom�c� zdravotn� p��e' OR  DRUHZARIZENI ilike 'Hospic'
                    OR DRUHZARIZENI ilike 'L��ebna pro dlouhodob� nemocn� (LDN)' OR DRUHZARIZENI ilike 'Nemocnice n�sledn� p��e'
                    OR DRUHZARIZENI ilike 'Zdravotn� p��e v �stavech soci�ln� p.' 
                        then 'Dlouhodob� a n�sledn� p��e' 
            when DRUHPECE ilike 'l��ebn� rehabilita�n� p��e' OR DRUHZARIZENI ilike 'Rehabilita�n� �stav' OR  DRUHZARIZENI ilike 'Samostatn� za��zen� fyzioterapeuta'
                         then 'Fyzioterapie, rehabilitace' --- p�em��l�m, jestli nedat samostatnou do ambulanc�, pak m��eme ud�lat povorn�n�, jestli jich je v�c v l�zn�ch nebo v asmosttn�ch ambulanc�ch
            when DRUHZARIZENI ilike 'Samostatn� stomatologick� laborato�' OR  DRUHZARIZENI ilike 'Samostatn� odborn� laborato�' then 'Laborato�'
//          --- zat�m nepou��vat---  when DRUHZARIZENI ilike 'Psychoterapeutick� stacion��' OR  DRUHZARIZENI ilike 'Samostatn� za��zen� psychologa' then 'Psychologie, psychiatrie'
            when DRUHZARIZENI ilike 'L��ebna tuberkul.a respir.nemoc� (TRN)' then 'L��ebna tuberkul�zy a respira�n�ch nemoc�'
            when DRUHZARIZENI ilike 'Samostatn� za��zen� nel�ka�e - jin�' then 'Ostatn� nezdravotnick� za��zen�'
            when DRUHZARIZENI ilike 'Za��zen� LPS' then 'Pohotovost'
            when DRUHPECE ILIKE 'l�k�rensk� p��e' OR DRUHZARIZENI ilike 'L�k�rna' then 'L�k�rna'
            when DRUHPECE ilike 'protialkoholn� a protitoxikomanick� z�chytn� slu�ba' OR DRUHZARIZENI ilike 'Z�chytn� stanice' then 'Z�chytn� stanice'
            else druhzarizeni --- 3 372 rows kter� nespadaj� do pravidel v��e
          end as poskytovatel_skupina
//          p�em��l�m, zda do toho motat ten druh p��e, tady se jedn� jen o za��zen�
        ,OBORPECE --- 2353 null
        , case
            when oborpece is null AND DRUHZARIZENI  ilike 'Samost. ordinace v�eob. prakt. l�ka�e'  then 'v�eobecn� praktick� l�ka�stv�'
            when oborpece is null AND DRUHZARIZENI  ilike 'Sam.ord.prakt.l�ka�e pro d�ti a dorost'  then 'praktick� l�ka�stv� pro d�ti a dorost'
            when oborpece is null AND DRUHZARIZENI  ilike 'Samostatn� ordinace PL - stomatologa'  then 'zubn� l�ka�stv�'
            when oborpece is null AND DRUHZARIZENI  ilike 'Samostatn� ordinace PL - gynekologa'  then 'gynekologie a porodnictv�'
            when oborpece is null AND DRUHZARIZENI  ilike 'Samostatn� za��zen� fyzioterapeuta'  then 'fyzioterapeut'
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
where oborpece_update ilike '%praktick� l�ka�stv�' and oborpece_update <> 'praktick� l�ka�stv� pro d�ti a dorost';

create or replace table UZIS_pediatr as
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike 'praktick� l�ka�stv� pro d�ti a dorost';

---- 2596

create or replace table UZIS_gyn as --- 2557
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike '%gynekologie%';

create or replace table UZIS_lekarny as --- 2461 
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike '%praktick� l�k�renstv�';

create or replace table UZIS_zubari as --- 6839 
select * from UZIS_EXPORT_LISTOPAD_FINAL
where oborpece_update ilike 'klinick� stomatologie' or  oborpece_update ilike 'zubn� l�ka�stv�';