create or replace table UZIS_CSU_OBYVATELE_2010_2019 as 
select
a."idhod"	as ID_hodnota
,to_date(a."casref_do", 'YYYY-MM-DD') as datum
,a."hodnota"::int	as pocet_obyvatel
/////'stapro_kod'	
////'pohlavi_cis'
////,a."pohlavi_kod" as pohlavi_kod
,case --- nen� t�eba p�ed�l�vat, kdy� pou�ijeme textovo hodnotu ve sloupci pohlavi_txt
     ///when a."pohlavi_kod"	= 1 then 'mu�'
     ///when a."pohlavi_kod"	= 2 then '�ena'
     when a."pohlavi_kod"	is null then '99'
        else a."pohlavi_kod"
 end as pohlavi_kod /// 1 a 2, NULL hodnoty nahrazeny kodem 99, pro sou�et muzu a zen dohoromady, mo�n� nadbyte�n� sloupec, kdy� v pohlavi_txt je NULL hodnota
,case 
    when a."pohlavi_txt" is NULL then 'dohromady' --- dohromady jsou ob� pohlav� dohromdy
    else a."pohlavi_txt"
 end as pohlavi_txt
///'vek_cis'	
///,a."vek_kod" as kategorie_vek
,case
    when civ.alternativni_text is null then 'v�e' --- v�e jsou v�echny v�kooov� kategorie dohromady
    else civ.alternativni_text 
 end as kategorie_vek_txt
,case
     when a."vuzemi_cis" = 97 then '�R'
     when a."vuzemi_cis" = 100 then 'kraj'
     when a."vuzemi_cis" = 101 then 'okres'---101 okresy, 100 kraje, 97 je cel� CR
 end as uzemi_jednotka
,a."vuzemi_kod"	as kod_uzemi_101
,case ---- dopln�n� CZ NUTS klasifikace por napojen� na poskytovatele a p��padn� srovn�n�
    when a."vuzemi_kod" ilike ck.chodnota then ck.cznuts
    when a."vuzemi_kod" ilike co.chodnota2 then co.chodnota1 
    when a."vuzemi_kod" like '19' then 'CZ0' --- dopln�no ru�n�, m�lo by tam b�t jen jednou
    else 'error'
 end as kod_uzemi_109
,a."vuzemi_txt" as uzemi_txt
///,a."vek_txt"
from UZIS_CSU_OBYVATELE_KAT as a
left join "ciselnik-intervaly-vek" as civ
on a."vek_kod"=civ.kod
left join CSU_CISELNIK_OKRESY as co
on a."vuzemi_kod"=co.chodnota2
left join CSU_CISELNIK_KRAJE as ck
on a."vuzemi_kod"=ck.chodnota;

create or replace table UZIS_CSU_OBYVATELE_2019 as
select *
from UZIS_CSU_OBYVATELE_2010_2019
where date_part(year, datum) = 2019;

create or replace table UZIS_CSU_OBYVATELE_OBCE_2020 as
select "Kod_okresu" as kod_okresu
        , "Kod_obce"	as kod_obce
        ,"Nazev_obce"	as nazev_obce
        ,"Pocet_obyvatel_celkem"::int as pocet_obyvatel
        ,"Pocet_obyvatel__Muzi"::int as pocet_obyvatel_muzi
        ,"Pocet_obyvatel__Zeny"::int	as pocet_obyvatel_zeny
        ,"Prumerny_vek_celkem"::number(5,1) as prumerny_vek
        ,"Vek__Muzi"::number(5,1) as prumerny_vek_muzi
        ,"Vek__Zeny"::number(5,1) as prumerny_vek_zeny
from "pocet-obyvatel-v-obcich-cr-k-1-1-2020"
where kod_okresu  ilike 'CZ%';

create or replace table UZIS_CSU_OBYVATELE_OBCE_2020 as
select o.*, c.chodnota1 as kod_obce_CSU, c.text1 as nazev_obce_CSU
from UZIS_CSU_OBYVATELE_OBCE_2020 as o
left join "csu-ciselnik-obce" as c
on o.KOD_OBCE=c.chodnota1;

create or replace table UZIS_CSU_OBYVATELE_2019_PRAHA_OKRESY as
select *,
        case
        when kod_uzemi_109 = 'CZ010' then 'CZ0100'
        else kod_uzemi_109
        end as kod_uzemi_109_Praha
from UZIS_CSU_OBYVATELE_2019
where uzemi_txt ilike '%Praha' OR uzemi_jednotka ilike 'okres';