# Vaihtoehtoislaskelma panos-tuotos-mallilla

Tämä muistio täydentää teemaluonnosta (`Datakeskusteema luonnos.md`) ja R-mallia
(`datakeskus_vaikutukset.R`) tarjoamalla **riippumattoman, panos-tuotos-tyyppiseen
menetelmään perustuvan vertailulaskelman** samoille muuttujille: työllisyys,
arvonlisäys ja verotulot rakennus- ja käyttövaiheessa. Laskelma koskee samaa
33 mrd. €:n keskimmäistä skenaariota kuin teema, jotta luvut ovat suoraan
vertailukelpoisia.

> **Luonteesta.** Tämä on *suuntaa-antava vertailu*, ei tarkka korvaava
> laskelma. Katso luku 2, miksi.

> **Päivitys.** Tämän muistion rakennusvaiheen havainto - että
> pääasiakirjan "vain suorat työntekijät" -tulovero saattaa aliarvioida
> todellista verokertymää - on sittemmin **toteutettu**: sekä pääasiakirja
> että teema laskevat tulon nyt koko työllisyyspohjalta (suorat +
> aliurakoitsijaketjun epäsuorat työntekijät). Alla olevat
> "pääasiakirjan malli" -luvut on päivitetty vastaamaan tätä muutosta.

## 1. Menetelmäero pääasiakirjan malliin

Pääasiakirjan malli perustuu Googlen oman Hamina-laajennuksen ilmoitettuun
työllisyyteen ja MW-tehoon sekä yhtiön Deloitte-selvityksen suora/epäsuora+
indusoitu-suhdelukuun (1 : 1,2), ja BKT lasketaan menoerittelyllä
(I + C − M rakennusvaiheessa, X + C − M käyttövaiheessa).

Panos-tuotos-malli (tässä muistiossa) laskee saman asian toisin: se lähtee
siitä, kuinka paljon kotimaista lopputuotekysyntää (rakennusurakoiden
laskutus, sähkönostot) investointi synnyttää tietyillä toimialoilla, ja
soveltaa näihin toimialakohtaisia **tuotos-, arvonlisäys- ja
työpanoskertoimia** Leontief-tyyppisesti: suora vaikutus (ko. toimiala) +
epäsuora vaikutus (toimialan kotimainen hankintaketju). Indusoitua
(palkkojen kulutuksen aiheuttamaa) vaikutusta ei lasketa tässä
systemaattisesti mukaan, koska luotettavaa kerrointa sille ei ollut
saatavilla (ks. luku 2).

**Päivitys (arvonlisäys).** Epäsuora arvonlisäys lasketaan nyt **auki
kirjoitettuna geometrisena sarjana** (ks. luku 4) sen sijaan, että
käytettäisiin yhtä kirjallisuudesta poimittua "Tyyppi I -kerrointa"
(1,3-1,8×) läpinäkymättömänä kokonaislukuna arvonlisäykselle. Uusi laskenta
erittelee rakennusalan oman arvonlisäyksen, sen ostamien välituotteiden
kotimaisen osuuden, ja toimitusketjun (upstream-toimialojen) oman
arvonlisäysosuuden - ja summaa näistä syntyvän kerrannaisvaikutuksen
äärettömänä (suppenevana) sarjana. Tämä on läpinäkyvämpi ja paremmin
auditoitavissa, vaikka perustuukin edelleen yleisiin suuruusluokka-arvioihin
eikä Suomen virallisiin toimialakertoimiin. **Työllisyyden** laskennassa
käytetään toistaiseksi edelleen yksinkertaisempaa Tyyppi I -kerrointa
(1,3-1,8×) - sitä ei ole tässä päivityksessä muutettu.

Huomaa myös käsite-ero: panos-tuotos-malli tuottaa **arvonlisäyksen**
(tuotantolähestymistapa), pääasiakirja **BKT:n menoerittelyllä**. Nämä ovat
kansantalouden tilinpidossa sama asia samassa taloudessa, mutta tässä
lasketut osittaiset arvonlisäysluvut eivät kata koko investoinnin
BKT-vaikutusta samalla tavalla kuin pääasiakirjan laskelma - vertailu on siksi
suuntaa-antava, ei täysin yhteismitallinen.

## 2. Tietolähteiden saatavuusrajoitus

Tarkoitus oli hakea Tilastokeskuksen viralliset panos-tuotoskertoimet
(Tarjonta-, käyttö- ja panos-tuotostaulukot 2022, taulukot **14yq**, **14yr**,
**14yt**, StatFin-tietokanta, 64 × 64 toimialaa) suoraan tästä
pilviympäristöstä. Tämä ei onnistunut: `stat.fi`- ja `pxdata.stat.fi`
-verkko-osoitteet eivät resolvoidu tämän istunnon verkkoympäristöstä
(DNS-tason esto ympäristön verkkoasetuksissa, ei vain yksittäisen sivun
saavuttamattomuus). Hakukoneen kautta löytyi vain hajanaisia esimerkkilukuja
julkaisujen tiivistelmistä (mm. elintarviketeollisuuden kokonaistuotos­kerroin
2,25 vuodelta 2015, palvelutoimialojen kokonaistyöpanoskertoimet välillä
1,1-28,7 työllistä/milj. € vuodelta 2022), mutta ei rakennusalan tai
tietojenkäsittelypalvelujen toimialakohtaisia kertoimia.

Tästä seuraa, että osa alla käytetyistä kertoimista on **virallisesta
lähteestä** ja osa **yleiseen panos-tuotos-kirjallisuuteen ja
asiantuntija-arvioon perustuvia suuruusluokkia**, joita ei ole vahvistettu
tämän istunnon aikana Suomen tai kyseisen toimialan osalta. Jokainen luku on
merkitty alla:

- **[PT-lähde]** = suoraan viralliseen, nimettyyn tilastoon perustuva luku.
- **[PT-oletus]** = yleinen kirjallisuus-/asiantuntija-arvio, ei
  toimiala/Suomi-kohtaisesti vahvistettu tässä istunnossa.

## 3. Käytetyt oletukset

| Muuttuja | Arvo | Status | Huomio |
|---|---|---|---|
| Rakennusalan (TOL F) suora työpanoskerroin | 4 230 htv / mrd. € tuotosta (2022) | **[PT-lähde]** Tilastokeskus 14yn/14yq - sama luku on jo aiemmin viitattu pääasiakirjan R-mallissa | Koko toimialan keskiarvo; ei datakeskusrakentamiselle räätälöity |
| Rakentamisen Tyyppi I -kerroin (suora+epäsuora/suora), **vain työllisyydelle** | 1,3-1,8 | **[PT-oletus]** | Pienen avotalouden (Suomi) rakennusalan tyypillinen vaihteluväli kansainvälisessä kirjallisuudessa; tuontivaltaiset panokset (koneet, osa materiaaleista) rajoittavat kotimaista kerrannaisvaikutusta. Arvonlisäykselle ei enää käytetä tätä kerrointa, ks. seuraavat kaksi riviä ja luku 4 |
| Rakentamisen (va0) arvonlisäysosuus tuotoksesta | 35-42 % (piste 38 %) | **[PT-oletus]** | Yleisesti tunnettu suuruusluokka rakennusalalle. Loppuosa (58-65 %) menee välituoteostoihin (materiaalit, konevuokraus, alihankinta, suunnittelu) |
| Toimitusketjun (upstream-toimialojen, va1) arvonlisäysosuus tuotoksesta | 25-35 % (piste 30 %) | **[PT-oletus]** | Rakennusalan välituotteiden toimittajien (betoni, teräs, konevuokraus = matalampi VA-osuus; suunnittelu, logistiikka = korkeampi) arvioitu keskiarvo. Ei vahvistettu Suomen toimialakohtaisista taulukoista |
| Toimintaylijäämän (voiton) osuus arvonlisäyksestä, rakentaminen | 27 % | **[PT-oletus]** | Käytetty yhteisöveron arviointiin (koskee koko arvonlisäystä, suora+epäsuora) |
| Sähkötoimialan (D) suora työpanoskerroin | 300-600 htv / mrd. € tuotosta | **[PT-oletus]** | Pääomavaltainen toimiala; ei vahvistettu tarkkaa Suomen lukua |
| Keskipalkka, tulovero/työntekijä | 45 000 €/v, 10 286,89 €/työntekijä | **[M/O]** peritty pääasiakirjan mallista (2026 veroasteikko) | Käytetty sellaisenaan vertailukelpoisuuden vuoksi |
| Suomalaisten/kotimaisten työntekijöiden osuus | 60 % (keskim.) | **[M]** peritty pääasiakirjan mallista | - |
| Kotimainen osuus investoinnista, tuontisisältö (d) | 2 500/12 000 ≈ 20,8 %; 20 % | **[M]** peritty pääasiakirjan mallista | Sama lähtökohta kuin pääasiakirjassa. d = 1 - 20 % = 80 % kotimaisten välituoteostojen osuudeksi - oletettu samaksi jokaisella toimitusketjun kierroksella (yksinkertaistus) |
| ALV:n osuus palkkojen kulutuksesta, joka on ALV:llista | 70 % | **[PT-oletus]** | Karkea oletus: osa kulutuksesta on ALV-vapaata tai yritysten välistä, vähennyskelpoista. Ei ollut aiemmin tässä taulukossa, vaikka sitä käytettiin luvun 4 laskennassa |

Kiinteistövero jätetään kokonaan pois panos-tuotos-laskelmasta: se riippuu
rakennusten verotusarvosta, joka ei ole toimialakertoimilla johdettavissa
suure. Sähkövero jätetään ennallaan pääasiakirjan luvusta (se on
kulutusmäärään sidottu valmistevero, ei toimialakerroin-riippuvainen) ja
toistetaan vain vertailun täydellisyyden vuoksi.

## 4. Rakennusvaihe (33 mrd. €, keskimmäinen skenaario)

Kotimainen rakennusurakoiden laskutus = 33 mrd. € × 20,8 % ≈ **6 875 milj. €**
(sama lähtökohta kuin pääasiakirjassa).

**Työllisyys.** Suora työllisyys toimialakeskiarvolla: 6,875 mrd. € ×
4 230 htv/mrd. € ≈ **29 100 htv**. Tyyppi I -kokonaisvaikutus (kerroin
1,3-1,8): **37 800-52 300 htv**.

**Arvonlisäys.** Lasketaan nyt auki kirjoitettuna, kaksivaiheisena
laskelmana, joka huomioi myös rakennusalan ostamien **välituotteiden**
(materiaalit, konevuokraus, alihankinta) kautta syntyvän arvonlisäyksen
toimitusketjun aiemmilla kierroksilla - ei enää yhtenä kirjallisuudesta
poimittuna kokonaiskertoimena:

1. **Suora arvonlisäys** (rakennusalan oma palkka+voitto): 6 875 milj. € ×
   va0 (35-42 %) = **2 406-2 888 milj. €**
2. **Välituoteostot** (loppuosa laskutuksesta, joka menee materiaaleihin ja
   alihankintaan): 6 875 × (1 − va0) = 3 987-4 469 milj. €, josta kotimaisia
   (d = 80 %): 3 190-3 575 milj. €
3. **Epäsuora arvonlisäys** (toimitusketjun oma palkka+voitto, summattuna
   äärettömänä geometrisena sarjana toistuvien kierrosten yli, suhdeluvulla
   q = (1 − va1) × d): kotimaiset välituoteostot × va1 / (1 − q) =
   **2 234-2 326 milj. €**
4. **Yhteensä: 2 406 + 2 234 = 4 641 milj. € ... 2 888 + 2 326 = 5 214
   milj. €, eli n. 4 640-5 210 milj. €**

(Vanha, pelkkään Tyyppi I -kertoimeen 1,3-1,8× perustunut arvio oli
3 130-5 200 milj. € - uusi laskelma antaa kapeamman ja etenkin alarajaltaan
korkeamman haarukan, koska se tunnistaa eksplisiittisesti, että myös
toimitusketjun ensimmäisen kierroksen alihankkijat tuottavat arvonlisäystä,
sen sijaan että luottaisi yhteen yleiseen kirjallisuuskertoimeen.)

**Verotulot** (ei sisällä kiinteistöveroa):
- Tulovero (koko Tyyppi I -työllisyydelle, 60 % kotimaisia, 10 286,89
  €/työntekijä): **233-323 milj. €** (ei muuttunut - ei riipu
  arvonlisäyksestä)
- Yhteisövero (27 % arvonlisäyksestä voittona, 20 % yhteisöverokanta,
  uudella arvonlisäysluvulla): 4 640×0,27×0,20 ... 5 210×0,27×0,20 =
  **251-281 milj. €**
- Arvonlisävero (karkea arvio palkkojen kulutusosasta): **107-148 milj. €**
  (ei muuttunut - ei riipu arvonlisäyksestä)
- **Yhteensä: n. 591-753 milj. €**

### Vertailu pääasiakirjaan

| | Pääasiakirjan malli | Panos-tuotos-vaihtoehto |
|---|---|---|
| Työllisyys (kok.) | 40 600 htv | 37 800-52 300 htv |
| joista kotimaisia/verotettavia | 18 400 (suorat) | 22 700-31 400 (60 % Tyyppi I:stä) |
| Arvonlisäys/BKT-vaikutus | 6 140 milj. € (BKT, menoerittely) | 4 640-5 210 milj. € (arvonlisäys, tuotantolähestymistapa, välituotteiden arvonlisäys mukaan lukien - eri käsite, ks. luku 1) |
| Verotulot (ilman kiinteistöveroa) | 456,9 milj. € | 591-753 milj. € |

**Havainto.** Kokonaistyöllisyysarvio on samaa suuruusluokkaa molemmilla
menetelmillä - panos-tuotos-haarukka asettuu pääasiakirjan luvun (40 600)
molemmin puolin. Pääasiakirja on sittemmin päivitetty laskemaan tuloveron
koko työllisyyspohjalta (suorat + aliurakoitsijaketjun epäsuorat
työntekijät) tämän muistion alkuperäisen havainnon pohjalta - ks. yllä oleva
päivityshuomautus. Tämän jälkeen pääasiakirjan verotuloarvio (456,9 milj. €)
jää hieman panos-tuotos-haarukan (591-753 milj. €) alapuolelle, eli
menetelmät tukevat nyt toisiaan huomattavasti paremmin kuin ennen
päivitystä (jolloin pääasiakirjan luku oli vain 320 milj. €), vaikkakaan
eivät enää osu yhtä tarkasti yksiin kuin ennen arvonlisäyksen
välituotelaskennan päivitystä (ks. yllä, luku 4).

Sen sijaan **arvonlisäys-rivillä pääasiakirjan luku (6 140 milj. €) on
edelleen selvästi korkeampi** kuin panos-tuotos-mallin päivitetty arvio
(4 640-5 210 milj. €) - myös sen jälkeen, kun panos-tuotos-malli nyt
huomioi eksplisiittisesti myös toimitusketjun (välituotteiden) tuottaman
arvonlisäyksen. Tämä viittaa siihen, että ero ei ole (enää) siitä, että
panos-tuotos-malli unohtaisi epäsuoran arvonlisäyksen, vaan siitä, että
pääasiakirjan oma BKT-laskenta (I - M_inv, eli investoinnista vähennetään
vain tuonti) vastaa löyhempää arvonlisäyksen käsitettä kuin kansantalouden
tilinpidon virallinen tuotos miinus välituotekäyttö -määritelmä, jota
panos-tuotos-malli noudattaa tarkemmin. Pääasiakirjan 6 140 milj. €:n luku
saattaa siis yliarvioida rakennusvaiheen BKT-vaikutuksen lievästi.

## 5. Käyttövaihe (vuodessa, 33 mrd. €, keskimmäinen skenaario)

Datakeskuksen kotimainen sähkönosto (energia + siirto, tuontisähkön osuus
vähennettynä) pääasiakirjan mallista: **398,1 milj. €/v** (pienentynyt,
koska pääasiakirjan sähkötehosuhde on sittemmin korjattu 100:sta noin
30 MW/mrd. €:oon - ks. VTT:n ja Rambollin selvityksiin perustuva
korjaus). Tätä käsitellään tässä lopputuotekysyntänä sähkötoimialalle
(TOL D).

**Työllisyys.** Datakeskuksen oma suora henkilöstö (sama kuin
pääasiakirjassa, ei I-O-johdettu): 2 750 htv/v. Epäsuora työllisyys
sähköntuotannon/-jakelun toimitusketjussa (kerroin 300-600 htv/mrd. €):
**119-239 htv/v**. **Yhteensä: n. 2 870-2 990 htv/v.**

### Vertailu pääasiakirjaan

| | Pääasiakirjan malli | Panos-tuotos-vaihtoehto |
|---|---|---|
| Työllisyys (kok.) | 6 050 htv/v (suorat 2 750 + epäsuora+indusoitu 3 300, Deloitte-kerroin 1,2×) | 2 870-2 990 htv/v (suorat 2 750 + vain sähkötoimialan epäsuora työllisyys) |

**Havainto.** Panos-tuotos-haarukka jää selvästi pääasiakirjan lukua
matalammaksi, mutta tämä **ei tarkoita, että pääasiakirjan luku olisi
liioiteltu** - kyse on siitä, että tässä lasketaan vain yksi, kapea
kerrannaisreitti (sähkön toimitusketju). Pääasiakirjan Deloitte-kerroin
(1,2×) kattaa laajemman joukon epäsuoria ja indusoituja vaikutuksia
(ylläpito- ja huoltosopimukset, paikalliset palvelut, henkilöstön palkkojen
kulutuksen synnyttämät työpaikat muualla taloudessa) - vaikutuksia, joita
tämä suppea panos-tuotos-laskelma ei yritä kattaa kokonaisuudessaan (ks. luku
7). Luvut eivät siis ole ristiriidassa vaan mittaavat eri asioita; tätä kahta
lukua ei pidä laskea yhteen, koska ne osin päällekkäiset.

Verotuloja ei lasketa tälle osiolle erikseen panos-tuotos-mallilla: koska
kyse on vain osittaisesta (sähkötoimialan) kerrannaisvaikutuksesta eikä koko
käyttövaiheen epäsuorasta vaikutuksesta, karkea verotulolaskelma antaisi
harhaanjohtavan alhaisen luvun ilman todellista lisäarvoa pääasiakirjan omaan
arvioon (378,1 milj. €/v) nähden.

## 6. Yhteenveto

- **Rakennusvaiheen työllisyys**: samaa suuruusluokkaa molemmilla
  menetelmillä (37 800-52 300 vs. 40 600 htv) - ei anna syytä epäillä
  pääasiakirjan lukua liioitelluksi.
- **Rakennusvaiheen verotulot**: panos-tuotos-mallin havainto siitä, että
  pääasiakirjan aiempi "vain suorat työntekijät" -rajaus tuloverossa saattoi
  aliarvioida todellista verokertymää, on johtanut pääasiakirjan ja teeman
  päivittämiseen - tulovero lasketaan nyt koko työllisyyspohjalta. Luvut
  ovat tämän jälkeen huomattavasti lähempänä toisiaan (456,9 vs.
  591-753 milj. €).
- **Rakennusvaiheen arvonlisäys**: tämän, nyt välituotteiden arvonlisäyksen
  huomioivan laskelman (4 640-5 210 milj. €) jälkeenkin pääasiakirjan oma
  luku (6 140 milj. €) on selvästi korkeampi. Tämä viittaa siihen, että
  pääasiakirjan BKT-laskentatapa (investoinnista vähennetään vain tuonti,
  ei kotimaisten välituotteiden käyttöä) vastaa löyhempää arvonlisäyksen
  käsitettä kuin kansantalouden tilinpidon virallinen määritelmä - ei
  siihen, että panos-tuotos-malli unohtaisi jonkin kerrannaisvaikutuksen.
- **Käyttövaiheen työllisyys**: menetelmät eivät ole suoraan vertailukelpoisia,
  koska panos-tuotos-laskelma kattaa vain sähkön toimitusketjun, ei koko
  Deloitte-kertoimen laajuutta.
- Kaikki panos-tuotos-luvut ovat **suuntaa-antavia**: suurin osa kertoimista
  (työllisyyden Tyyppi I -kerroin, arvonlisäysosuudet va0/va1,
  toimintaylijäämäosuus, sähkötoimialan työpanoskerroin) on yleisiä
  kirjallisuusarvioita, ei Suomi/toimiala-kohtaisesti vahvistettuja
  virallisista taulukoista tämän istunnon aikana. Arvonlisäyksen laskenta
  on päivitetty läpinäkyvämmäksi (auki kirjoitettu geometrinen sarja
  yhden kirjallisuuskertoimen sijaan, ks. luku 4), mutta työllisyyden
  laskenta käyttää vielä vanhaa, yksinkertaisempaa Tyyppi I -kerrointa.

## 7. Mitä tarkempi laskelma vaatisi

1. Suora pääsy Tilastokeskuksen StatFin-tietokannan taulukoihin 14yq/14yr/14yt
   (2022, 64 × 64 toimialaa) - tässä ympäristössä estetty verkkotasolla.
2. Toimialakohtaisten kertoimien hakeminen juuri rakentamiselle (TOL F) ja
   tietojenkäsittelypalveluille/sähköntuotannolle (TOL D, J62-63) sen sijaan,
   että käytetään yleisiä kirjallisuusarvioita.
3. Huomio, ettei 64 toimialan taso erittele datakeskusrakentamista tai
   -operointia omaksi riviksi - koko toimialan keskiarvo voi poiketa
   merkittävästi pääomavaltaisesta, modulaarisesta datakeskusrakentamisesta
   tai -käytöstä.
4. Tyyppi II (indusoitu, palkkojen kulutuksen kautta syntyvä) -kertoimien
   sisällyttäminen kattavammin käyttövaiheen vertailuun, jotta se olisi
   yhteismitallinen pääasiakirjan Deloitte-kertoimen kanssa.
5. Kiinteistövero ja sähkövero jäävät joka tapauksessa panos-tuotos-mallin
   ulkopuolelle - ne on laskettava pääasiakirjan tapaan erikseen.
6. Työllisyyden laskenta käyttää vielä yhtä, yksinkertaista Tyyppi I
   -kerrointa (1,3-1,8×) eikä samaa auki kirjoitettua, välituotteiden kautta
   etenevää geometrista laskentaa kuin arvonlisäys (ks. luku 4) - tämä voisi
   tehdä myös työllisyysarviosta läpinäkyvämmän, joskin vaatisi oman
   oletuksen toimitusketjun työpanoskertoimelle (joka voi poiketa
   rakennusalan omasta, esim. koneellisempi/pääomavaltaisempi tuotanto
   materiaaliteollisuudessa).
