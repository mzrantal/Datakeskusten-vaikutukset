# Vaihtoehtoislaskelma panos-tuotos-mallilla

Tämä muistio täydentää teemaluonnosta (`Datakeskusteema luonnos.md`) ja R-mallia
(`datakeskus_vaikutukset.R`) tarjoamalla **riippumattoman, panos-tuotos-tyyppiseen
menetelmään perustuvan vertailulaskelman** samoille muuttujille: työllisyys,
arvonlisäys ja verotulot rakennus- ja käyttövaiheessa. Laskelma koskee samaa
33 mrd. €:n keskimmäistä skenaariota kuin teema, jotta luvut ovat suoraan
vertailukelpoisia.

> **Luonteesta.** Tämä on *suuntaa-antava vertailu*, ei tarkka korvaava
> laskelma. Katso luku 2, miksi.

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
epäsuora vaikutus (toimialan kotimainen hankintaketju, ns. Tyyppi I).
Indusoitua (palkkojen kulutuksen aiheuttamaa) vaikutusta ei lasketa tässä
systemaattisesti mukaan, koska luotettavaa kerrointa sille ei ollut
saatavilla (ks. luku 2).

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
| Rakentamisen Tyyppi I -kerroin (suora+epäsuora/suora) | 1,3-1,8 | **[PT-oletus]** | Pienen avotalouden (Suomi) rakennusalan tyypillinen vaihteluväli kansainvälisessä kirjallisuudessa; tuontivaltaiset panokset (koneet, osa materiaaleista) rajoittavat kotimaista kerrannaisvaikutusta |
| Rakentamisen arvonlisäysosuus tuotoksesta | 35-42 % (piste 38 %) | **[PT-oletus]** | Yleisesti tunnettu suuruusluokka rakennusalalle |
| Toimintaylijäämän (voiton) osuus arvonlisäyksestä, rakentaminen | 27 % | **[PT-oletus]** | Käytetty yhteisöveron arviointiin |
| Sähkötoimialan (D) suora työpanoskerroin | 300-600 htv / mrd. € tuotosta | **[PT-oletus]** | Pääomavaltainen toimiala; ei vahvistettu tarkkaa Suomen lukua |
| Keskipalkka, tulovero/työntekijä | 45 000 €/v, 10 286,89 €/työntekijä | **[M/O]** peritty pääasiakirjan mallista (2026 veroasteikko) | Käytetty sellaisenaan vertailukelpoisuuden vuoksi |
| Suomalaisten/kotimaisten työntekijöiden osuus | 60 % (keskim.) | **[M]** peritty pääasiakirjan mallista | - |
| Kotimainen osuus investoinnista, tuontisisältö | 2 500/12 000 ≈ 20,8 %; 20 % | **[M]** peritty pääasiakirjan mallista | Sama lähtökohta kuin pääasiakirjassa |

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

**Arvonlisäys.** Suora: 6 875 milj. € × 38 % ≈ **2 610 milj. €**. Tyyppi I
-kokonaisvaikutus: **3 130-5 200 milj. €**.

**Verotulot** (ei sisällä kiinteistöveroa):
- Tulovero (koko Tyyppi I -työllisyydelle, 60 % kotimaisia, 10 286,89
  €/työntekijä): **233-323 milj. €**
- Yhteisövero (27 % arvonlisäyksestä voittona, 20 % yhteisöverokanta):
  **169-281 milj. €**
- Arvonlisävero (karkea arvio palkkojen kulutusosasta): **107-148 milj. €**
- **Yhteensä: n. 509-752 milj. €**

### Vertailu pääasiakirjaan

| | Pääasiakirjan malli | Panos-tuotos-vaihtoehto |
|---|---|---|
| Työllisyys (kok.) | 40 600 htv | 37 800-52 300 htv |
| joista kotimaisia/verotettavia | 18 400 (suorat) | 22 700-31 400 (60 % Tyyppi I:stä) |
| Arvonlisäys/BKT-vaikutus | 6 140 milj. € (BKT, menoerittely) | 3 130-5 200 milj. € (arvonlisäys, tuotantolähestymistapa - eri käsite, ks. luku 1) |
| Verotulot (ilman kiinteistöveroa) | 320 milj. € | 509-752 milj. € |

**Havainto.** Kokonaistyöllisyysarvio on samaa suuruusluokkaa molemmilla
menetelmillä - panos-tuotos-haarukka asettuu pääasiakirjan luvun (40 600)
molemmin puolin. Verotulot ovat panos-tuotos-mallilla selvästi
**korkeammat**, koska se verottaa tuloverolla koko Tyyppi I -työllisyyden
(myös aliurakoitsijoiden ja toimitusketjun työntekijät), kun taas
pääasiakirja laskee tuloveron tietoisesti vain Googlen omasta
suorasta työllisyydestä (ks. teeman alaviite). Jos aliurakoitsijaketjun
työntekijät todella ovat Suomessa verovelvollisia - mikä on todennäköistä -
pääasiakirjan nykyinen tulovero-arvio saattaa olla **varovainen
alakanttiin**-arvio, ei yläkanttiin.

## 5. Käyttövaihe (vuodessa, 33 mrd. €, keskimmäinen skenaario)

Datakeskuksen kotimainen sähkönosto (energia + siirto, tuontisähkön osuus
vähennettynä) pääasiakirjan mallista: **1 343,6 milj. €/v**. Tätä käsitellään
tässä lopputuotekysyntänä sähkötoimialalle (TOL D).

**Työllisyys.** Datakeskuksen oma suora henkilöstö (sama kuin
pääasiakirjassa, ei I-O-johdettu): 2 750 htv/v. Epäsuora työllisyys
sähköntuotannon/-jakelun toimitusketjussa (kerroin 300-600 htv/mrd. €):
**400-810 htv/v**. **Yhteensä: n. 3 150-3 560 htv/v.**

### Vertailu pääasiakirjaan

| | Pääasiakirjan malli | Panos-tuotos-vaihtoehto |
|---|---|---|
| Työllisyys (kok.) | 6 050 htv/v (suorat 2 750 + epäsuora+indusoitu 3 300, Deloitte-kerroin 1,2×) | 3 150-3 560 htv/v (suorat 2 750 + vain sähkötoimialan epäsuora työllisyys) |

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
arvioon (723 milj. €/v) nähden.

## 6. Yhteenveto

- **Rakennusvaiheen työllisyys**: samaa suuruusluokkaa molemmilla
  menetelmillä (37 800-52 300 vs. 40 600 htv) - ei anna syytä epäillä
  pääasiakirjan lukua liioitelluksi.
- **Rakennusvaiheen verotulot**: panos-tuotos-malli viittaa siihen, että
  pääasiakirjan nykyinen, tietoisen varovainen "vain suorat työntekijät"
  -rajaus tuloverossa saattaa aliarvioida todellista verokertymää, jos
  aliurakoitsijaketjun työntekijät ovat Suomessa verovelvollisia.
- **Käyttövaiheen työllisyys**: menetelmät eivät ole suoraan vertailukelpoisia,
  koska panos-tuotos-laskelma kattaa vain sähkön toimitusketjun, ei koko
  Deloitte-kertoimen laajuutta.
- Kaikki panos-tuotos-luvut ovat **suuntaa-antavia**: suurin osa kertoimista
  (Tyyppi I -kerroin, arvonlisäysosuus, toimintaylijäämäosuus, sähkötoimialan
  työpanoskerroin) on yleisiä kirjallisuusarvioita, ei Suomi/toimiala-
  kohtaisesti vahvistettuja virallisista taulukoista tämän istunnon aikana.

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
