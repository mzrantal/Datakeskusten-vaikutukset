# Lähdevertailu: arvio 33 mrd. €:n datakeskusinvestoinnin vaikutuksista

Tässä taulukossa on koottu yhteen eri lähteiden arviot datakeskusinvestointien
vaikutuksista, skaalattuna samalle **33 mrd. €:n investoinnille** (teeman
keskimmäinen, toteutumapainotettu arvio vuosina 2027–2028 valmistuvista
hankkeista), jotta luvut ovat suoraan vertailukelpoisia. Lähteet: oma malli
(teema), oma panos-tuotos-pohjainen vaihtoehtoislaskelma
(`panostuotosmalli.md`), Rambollin/FDCA:n/EK:n alkuperäinen selvitys (2025),
VTT:n Datakeskusteollisuudelle tekemä selvitys (2026), ja Googlen omat
ilmoitukset/Google Finlandin toteutunut data. Deloitten osuus selitetään
erikseen luvun 3 jälkeen, koska se ei tuota itsenäisiä kokonaislukuja.

> **Tulkintaohje.** Eri lähteet mittaavat osin eri asioita (brutto vs. netto,
> tuotantolähestymistapa vs. menoerittely, koko investointi vs. pelkkä
> rakennusosuus). Tarkat skaalausoletukset ja -lähteet on avattu kunkin
> taulukon jälkeen. Älä tulkitse rivien eroja virheiksi, ennen kuin olet
> lukenut kyseisen huomautuksen.

## 1. Rakennusvaihe (kertaluonteinen, koko rakennusajalta)

| Mittari | Oma malli (teema) | Oma panos-tuotos-selvitys | Ramboll (alkuperäinen, skaalattu) | VTT (2026, skaalattu) | Google (oma ilmoitus) |
|---|---|---|---|---|---|
| **Arvonlisäys** | 6,21 mrd. € (3,39–7,90) | 4,64–5,21 mrd. € (suora + välituotteiden epäsuora arvonlisäys, tuotantolähestymistapa) | n. 9,64 mrd. € (bruttoarvonlisäys) | n. 3,0–4,8 mrd. € (kotimainen arvonlisä/liikevaihto) | ei ilmoitettu |
| **Työllisyys** | 40 623 htv (38 161–44 316) | 37 800–52 300 htv | 123 750 htv | ei ilmoitettu selvityksessä | 40 623 htv¹ |
| **Verotulot** | 563 milj. € (395–770) | 634–811 milj. € | n. 4,69 mrd. € | n. 1,4 mrd. € | ei ilmoitettu |

¹ Googlen oma luku (1 231 htv/mrd. €, Googlen 9/2026 ilmoituksesta koko
Suomi-ohjelmalle) on **sama luku, jota oma mallimme käyttää lähtöarvonaan** –
tämä sarake ei siis ole riippumaton tarkistus rakennusvaiheen työllisyydelle,
vaan osoittaa mistä oman mallin luku on peräisin.

**Skaalausperusteet ja huomiot:**
- **Oma malli**: suoraan `datakeskus_vaikutukset.R`:n tuloste investoinnille
  31/33/36 mrd. € (alhainen/keskim/korkea-skenaario).
- **Oma panos-tuotos-selvitys**: ks. `panostuotosmalli.md`. Arvonlisäys
  lasketaan tuotantolähestymistavan mukaisesti (rakennusalan oma
  arvonlisäys + sen ostamien kotimaisten välituotteiden kautta syntyvä
  epäsuora arvonlisäys, summattuna geometrisena sarjana), ei menoerittelyn
  BKT-vaikutus – ei siis suoraan sama käsite kuin oman mallin luku. Vaikka
  välituotteiden arvonlisäys on nyt mukana, oman mallin luku (6 211 milj. €)
  on edelleen selvästi korkeampi – tämä viittaa siihen, että oma malli
  (joka vähentää investoinnista vain tuonnin, ei kotimaisten välituotteiden
  käyttöä) käyttää löyhempää arvonlisäyksen käsitettä kuin kansantalouden
  tilinpidon virallinen määritelmä. Verotulot-rivi **ei sisällä
  kiinteistöveroa** (panos-tuotos-malli ei pysty sitä johtamaan), kun taas
  oman mallin 563 milj. €:n luku sisältää kiinteistöveron (n. 60 milj. €)
  – ilman sitä oman mallin vastaava luku olisi n. 503 milj. €, joka jää
  nyt hieman panos-tuotos-haarukan (634–811 milj. €) alapuolelle.
- **Ramboll**: skaalattu pääasiakirjan "Vertailu Rambollin laskelmiin"
  -taulukon per-mrd.-€-suhdeluvuilla (työllisyys 3 750 htv/mrd. €,
  bruttoarvonlisäys 292 milj. €/mrd. €, verotulot 142 milj. €/mrd. €) × 33.
  Rambollin luvut ovat mallinnettuja **bruttolukuja**, jotka sisältävät
  suorat, epäsuorat ja indusoidut vaikutukset – eivät siis vertailukelpoisia
  netto-käsitteenä oman mallin kanssa.
- **VTT**: VTT:n selvityksen 100 MW:n esimerkkilaskelma (300–480 milj. €
  kotimaisille yrityksille, 146 milj. € valtion verotuloja) skaalattu
  kertoimella 9,9 (= 990 MW / 100 MW, kun 33 mrd. €:n investointi vastaa
  noin 990 MW:n sähkötehoa uudella, VTT:n ja Rambollin IT-osuustiedon
  perusteella korjatulla n. 30 MW/mrd. €:n suhdeluvulla). VTT:n selvityksestä
  ei löytynyt tätä kirjoitettaessa erillistä työllisyyslukua.
- **Google**: ei ole julkisesti ilmoittanut rakennusvaiheen arvonlisäys- tai
  verotuloarviota erikseen, vain työllisyysluvun (ks. ¹).

## 2. Käyttövaihe (vuosittain, pysyvä vaikutus)

| Mittari | Oma malli (teema) | Oma panos-tuotos-selvitys | Ramboll (alkuperäinen, skaalattu) | VTT (2026, skaalattu) | Google / toteutunut |
|---|---|---|---|---|---|
| **Arvonlisäys** | 0,95 mrd. €/v (0,59–1,39) | ei laskettu erikseen² | n. 8,25 mrd. €/v (liikevaihto, ei sama käsite kuin arvonlisäys) | ei ilmoitettu | ei ilmoitettu |
| **Työllisyys** | 6 050 htv/v (2 842–9 900) | 2 870–2 990 htv/v (vain sähkötoimialan epäsuora + suorat)² | 23 925 htv/v | ei ilmoitettu | 2 750 htv/v (suorat, Haminan toteutunut suhde) |
| **Verotulot** | 378 milj. €/v (243–562) | ei laskettu erikseen² | n. 687 milj. €/v (epävarma, ks. huomautus) | n. 153 milj. €/v (vain sähkövero, johdettu VTT:n energialuvusta) | n. 22–38 milj. €/v (vain yhteisövero, Google Finlandin toteutunut, skaalattu) |

² Panos-tuotos-selvitys kattaa käyttövaiheessa vain sähkön toimitusketjun
kautta syntyvän epäsuoran työllisyyden – ei koko Deloitte-kertoimen
laajuutta eikä arvonlisäystä/verotuloja, koska suppea laskelma olisi
antanut harhaanjohtavan alhaisen luvun (ks. `panostuotosmalli.md`, luku 5).

**Skaalausperusteet ja huomiot:**
- **Oma malli**: kuten yllä, käyttövaihe vuositasolla.
- **Ramboll, työllisyys ja liikevaihto**: skaalattu "Vertailu Rambollin
  laskelmiin" -taulukon suhdeluvuilla (725 htv/mrd. €/v, 250 milj. €/mrd. €/v)
  × 33. **Ramboll, verotulot**: ei ole samassa per-mrd.-€-taulukossa – johdettu
  Rambollin toisesta, 2025→2030-erotuslaskelmasta (0,25 mrd. € verovaikutusta
  12 mrd. €:n investoinnin kasvulle, eli n. 20,8 milj. €/mrd. €/v) × 33.
  Tätä lukua tulee pitää epävarmempana kuin muita Ramboll-rivejä, koska se on
  eri laskelmasta kuin työllisyys- ja liikevaihtoluvut.
- **VTT**: VTT:n ilmoittama 100 MW:n keskuksen sähkönkulutus (0,68 TWh/v)
  skaalattu kertoimella 9,9 → 6,73 TWh/v, kerrottuna sähköveron 22,66 €/MWh:n
  verokannalla. Tämä on **oma johdannainen VTT:n energialuvusta**, ei VTT:n
  itsensä ilmoittama verotuloarvio.
- **Google / toteutunut**: Google Finland on raportoinut maksaneensa n.
  3,5–4,5 mrd. €:n Hamina-investoinneilla n. 3–4 milj. €/v yhteisöveroa.
  Skaalattu suoraviivaisesti 33 mrd. €:n tasolle (3/4,5 ... 4/3,5 × 33).
  **Tämä on vain yhteisövero**, ei kokonaisverotulo, eikä suoraviivainen
  skaalaus välttämättä päde (suurempi toiminta voi olla verotuksellisesti
  tehokkaampaa tai tehottomampaa kuin pienempi).

## 3. Deloitte

Deloitte ei ole julkaissut itsenäisiä arvonlisäys-, työllisyys- tai
verotuloarvioita koko investoinnille. Googlen Deloittelta tilaama selvitys
(2024, Haminan laajennus) tuotti ainoastaan **työllisyyden
kerrannaissuhdeluvun**: suora : epäsuora : indusoitu ≈ 1 900 : 1 650 : 640,
eli epäsuora+indusoitu ≈ 1,2 × suora. Tätä suhdelukua käytetään jo
sellaisenaan sekä oman mallin että Googlen työllisyyslukujen sisällä
(ks. taulukoiden ¹-rivit) – se ei siis ole erillinen, kilpaileva
kokonaisarvio, vaan yksi oman mallin ja Googlen omien lukujen
rakennuspalikoista.

## 4. Mitä vertailusta voi päätellä

- **Rakennusvaiheen työllisyys**: oma malli ja panos-tuotos-selvitys ovat
  samaa suuruusluokkaa (~38 000–52 000 htv). Rambollin 123 750 htv on
  noin 3× suurempi – tämä johtuu Rambollin dokumentoimattomasta
  3 750 htv/mrd. €:n bruttoarvioista, joka on tässä projektissa jo aiemmin
  korvattu Googlen omaan ilmoitukseen perustuvalla, matalammalla luvulla.
- **Rakennusvaiheen verotulot**: Ramboll (4,69 mrd. €) ja VTT (1,4 mrd. €)
  ovat molemmat selvästi korkeampia kuin oma malli (563 milj. €) ja oma
  panos-tuotos-selvitys (634–811 milj. €) – jälkimmäiset kaksi ovat
  keskenään samaa suuruusluokkaa, mikä tukee niiden uskottavuutta suhteessa
  Rambollin/VTT:n korkeampiin, osin eri laskentaperustein tehtyihin arvioihin.
- **Rakennusvaiheen arvonlisäys**: oma malli (6,21 mrd. €) on edelleen
  selvästi korkeampi kuin oma panos-tuotos-selvitys (4,64–5,21 mrd. €),
  myös sen jälkeen kun panos-tuotos-malli päivitettiin huomioimaan myös
  välituotteiden (toimitusketjun) tuottama arvonlisäys. Ero näyttää
  johtuvan siitä, että oma malli vähentää investoinnista vain tuonnin,
  ei kotimaisten välituotteiden käyttöä – ks. `panostuotosmalli.md`, luku 4.
- **Käyttövaiheen verotulot**: Google Finlandin toteutunut, empiirinen
  yhteisövero (skaalattuna 22–38 milj. €/v) on samaa suuruusluokkaa kuin
  pääasiakirjan oman illustratiivisen laskelman yhteisöveroarvio
  (ks. "Yhteisöveron laskenta" -luku, 2,8–5,4 milj. €/v per 12 mrd. €, eli
  n. 7,7–14,9 milj. €/v per 33 mrd. €) – samaa suuruusluokkaa, joskin
  Google Finlandin toteutunut luku asettuu haarukan yläpäähän tai sen
  yläpuolelle.
- Yleisesti: **Ramboll ja VTT antavat systemaattisesti korkeampia lukuja**
  kuin oma malli ja oma panos-tuotos-selvitys, jotka puolestaan ovat
  keskenään lähempänä toisiaan – tämä toistuva kuvio antaa lisätukea sille,
  että oman mallin korjaukset (Googlen oma työllisyysluku, VTT:n ja
  Rambollin yhdistetty MW-suhde) ovat olleet oikeansuuntaisia, vaikka
  tarkkaa "oikeaa" lukua ei tietenkään voida varmuudella tietää.
