# Opiskelijatunnisteiden siirto ravintolan kassajärjestelmää varten.

Käyttöönotto
1. Tallenna kansioon **primusquery** primusqueryn vaatimat tiedostot (primusquery.exe, libeay32.dll, ssleay32.dll)
   Saat tiedostot esim. primuksen päivityspalvelusta.
2. Tallenna kansioon **winscp** sfpt siirtoon tarvittavat tiedostot (WinCSP.exe, WinSCPnet.dll)
   Saat tiedostot esim. https://winscp.net/download/WinSCP-6.1.2-Automation.zip
3. Kopioi example.config.xml tiedosto tiedostoksi config.xml ja täytä tiedostoon asetukset:
   - SFTP
      - host
      - port
      - UserName
      - Password
      - sshHostKeyFingerprint
      
      Voit jättää SshPrivateKeyPath kentät tyhjäksi, jos autentikointi tapahtuu salasanalla/lauseella.
   - primusquery
      - host
      - user
      - pass
      
      Luo näitä varten Primuksessa palvelukäyttäjä, joka pääsee vaaditun koulun tietoihin. Rajoituksen saa helpoiten tehtyä valitsemalla tunnukselle kotikouluksi vain tarvitun koulun. Visman ohjeet: https://help.inschool.fi/LU/fi/Tilastot-tiedonsiirrot-ja-jarjestelmayhteydet/PrimusQuery/PrimusQueryn-kayttoonotto.htm
   Testiympäristön asetukset voi jättää tyhjäksi, jos testaamiselle ei ole tarvetta.

4. Tarkasta TraderiaOpiskelijatunnisteet.pq tiedostosta, että aktiivisten opiskelijoiden haku on koululle sopiva. Oletushaku hakee kaikki arkistoimattomat opiskelijat, joilla on täytettynä henkilötunnniste ja joiden aloituspäivä on menneisyydessä.
   Jos jatkossa käytätte opsikelijatunnisteena muuta kenttää, voi query tiedostoa muokata tarpeen mukaan.

5. Siirto käynnistetään suorittamalla komentojono. Ohjelma:
   - hakee primuksesta opiskelijatunnisteet 
   - muotoilee ne kassajärjestelmän vaatimaan muotoon
   - lähettää tiedoston ravintolan palvelimelle
   Ravintolan automaatio poimii palvelimelta tiedostot, yhdistää eri koulujen tunnistetiedostot ja vie ne kassajärjestelmään.
   Siirron voi ajoittaa suoritettavaksi määräajoin, jolloin opiskelijoiden tunnisteet siirtyvät automaattisesti eikä manuaalista työtä tarvitse tehdä esim. lukuvuoden alussa.

   
