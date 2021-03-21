---create starting table from python jupyten notebbok queries (not included)

create or replace table UZIS_EXPORT_LISTOPAD_UPRAVENO as
SELECT row_number() over (order by "ZdravotnickeZarizeniId") as rowid
		,"ZdravotnickeZarizeniId" AS ZDRAVOTNICKEZARIZENIID
    ,"PCZ"
    ,"PCDP"
    ,"NazevCely" AS NAZEVCELY
    ,"ZdravotnickeZarizeniKod" AS ZDRAVOTNICKEZARIZENIKOD
    ,"DruhZarizeniKod" AS DRUHZARIZENIKOD
    ,"DruhZarizeni" AS DRUHZARIZENI
    ,"DruhZarizeniSekundarni" AS DRUHZARIZENISEKUNDARNI
    ,"Obec" AS OBEC
    ,"Psc" AS PSC
    ,"Ulice" AS ULICE
    ,"CisloDomovniOrientacni" AS CISLODOMOVNIORIENTACNI
    ,"Kraj" AS KRAJ
    ,"KrajKod" AS KRAJKOD
    ,"Okres" AS OKRES
    ,"OkresKod" AS OKRESKOD
    ,"SpravniObvod" AS SPRAVNIOBVOD
//    ,"PoskytovatelTelefon" AS POSKYTOVATELTELEFON
//    ,"PoskytovatelFax" AS POSKYTOVATELFAX
    ,"DatumZahajeniCinnosti" AS DATUMZAHAJENICINNOSTI
//    ,"IdentifikatorDatoveSchranky"
//    ,"PoskytovatelEmail" AS POSKYTOVATELEMAIL
//    ,"PoskytovatelWeb" AS POSKYTOVATELWEB
    ,"DruhPoskytovatele" AS DRUHPOSKYTOVATELE
    ,"PoskytovatelNazev" AS POSKYTOVATELNAZEV
    ,"Ico" AS ICO
    ,"TypOsoby" AS TYPOSOBY
    ,"PravniFormaKod" AS PRAVNIFORMAKOD
//    ,"KrajCodeSidlo" AS KRAJCODESIDLO
//    ,"OkresCodeSidlo" AS OKRESCODESIDLO
//    ,"ObecSidlo" AS OBECSIDLO
//    ,"PscSidlo" AS PSCSIDLO
//    ,"UliceSidlo" AS ULICESIDLO
//    ,"CisloDomovniOrientacniSidlo" AS CISLODOMOVNIORIENTACNISIDLO
    ,"OborPece" AS OBORPECE
    ,"FormaPece" AS FORMAPECE
    ,"DruhPece" AS DRUHPECE
//    ,"OdbornyZastupce" AS ODBORNYZASTUPCE
		,GPS
    ,split_part(gps, ' ', 1) as LATITUDE
    ,split_part(gps, ' ', 2) as LONGITUDE
from "export_sluzby_listopad_doplnene_adresy_psc_jupyter";
