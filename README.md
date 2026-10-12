# Datakeskusinvestoinnin vaikutukset Suomen talouteen

`datakeskus_vaikutukset.R` laskee datakeskusinvestoinnin vaikutuksen Suomen BKT:hen,
työllisyyteen ja julkisen talouden tuloihin muistion *Datakeskusten vaikutus Suomen
talouteen* (9/2026, [`lahteet/Datakeskusten_vaikutus_Suomen_talouteen.docx`](lahteet/Datakeskusten_vaikutus_Suomen_talouteen.docx)) lukujen pohjalta. Käyttäjältä kysytään investoinnin suuruus
(mrd. €) ja rakennusaika; muistion 12 mrd. € luvut skaalataan lineaarisesti.

```sh
Rscript datakeskus_vaikutukset.R          # kysyy investoinnin suuruuden
Rscript datakeskus_vaikutukset.R 12 5     # 12 mrd. €, rakennusaika 5 vuotta
```

Tai R/RStudio: `source("datakeskus_vaikutukset.R")`. Vain base R, ei lisäpaketteja.

## Verkkosovellus (Shiny)

Kansiossa `app/` on Shiny-sovellus, jossa parametrit annetaan lomakkeella ja tulokset
näytetään tunnuslukuina, kuvina ja taulukoina (myös CSV-lataus). Sovellus käyttää samaa
laskentamallia kuin komentoriviskripti.

- Julkaistu versio: <https://mzrantal.github.io/Datakeskusten-vaikutukset/>
- Paikallinen ajo repositorion juuresta: `shiny::runApp("app")` (vaatii paketit `shiny` ja `bslib`)

Julkaisu tehdään automaattisesti GitHub Actionsilla (`.github/workflows/shinylive.yml`)
aina, kun sovellus tai malli muuttuu. Shinylive ajaa R:n käyttäjän selaimessa, joten
palvelinta ei tarvita. Ensimmäisellä kerralla GitHub Pages pitää ottaa käyttöön:
*Settings → Pages → Build and deployment → Source: GitHub Actions*.

## Tulokset

Tulokset esitetään kolmessa skenaariossa (alhainen / keskimmäinen / korkea):

1. BKT-vaikutus rakennusvaiheessa (C + I − M: tuodut IT-laitteet eivät kasvata BKT:tä)
2. BKT-vaikutus käyttövaiheessa (palveluvienti emoyhtiölle siirtohinnoittelulla + kulutus − tuonti)
3. Työllisyys (htv, suora + epäsuora)
4.–6. Verotulot verolajeittain (yhteisövero, netto-ALV, tulovero, kiinteistövero,
   sähkövero), jako valtion ja kuntien kesken sekä kumulatiivinen kertymä
7. Vertailu Rambollin/FDCA:n bruttolukuihin

Parametrit ovat skriptin alussa listassa `P`. Merkintä `[M]` = muistiosta,
`[O]` = laskelman oma oletus (BKT- ja työllisten taso, tuontisisällöt, tuontisähkön osuus).

Huom. muistion yhteenvedossa käyttövaiheen kiinteistövero on 10 M€/v, mutta
kiinteistöverotaulukon mukaan 18–26 M€/v (12 mrd. €); skripti käyttää taulukon arvoja.
