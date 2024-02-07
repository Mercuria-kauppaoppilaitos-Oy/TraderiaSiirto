#CHARSET UTF8
#STRICT
#SORT V1
#DATABASE opphenk
// HAKU: Henkilötunnus<>"" JA Aloituspäivä=<Nykyinen päivämäärä 
#SEARCH K1=%B0% AND (K5<>"" AND K200=<V2)
//
// Siirtotiedoston muoto:
// Sarake A = 1
// Sarake B = SOTU väliviivalla tai A:lla, ilman viimeistä merkkiä, tai oid tunnisteen viimeinen osa.
// Sarake C = 1
// Sarake D = Aterioiden lukumäärä / päivä
// Sarake E = Asiakasnumero, miltä ateriat laskutetaan (voi olla useita samassa tiedostossa). Lukio: 40774
// Sarake F = 1
// CSV erotin puolipilkku ;, lainausmerkit ei välttämättömiä
//
// HETU
#IF{K5<>""}
#LINE_START
1;
#DATA{K5, CPSTR(1,10)};
1;1;40774;1
#LINE_STOP
#ENDIF