# Datakeskusinvestointien jakautuminen investointilajeihin, sähköverkko-
# investoinnit erikseen, sekä julkisen talouden verotulo- ja BKT-vaikutukset
# vuosille 2027 ja 2028.
#
# Lahteet:
#   - Dataikkuna_2_11_2026_imputoitu_claude.xlsx: toteutuneet/ilmoitetut
#     datakeskusinvestoinnit (Summa, M€) valmistumisvuoden mukaan.
#   - Datakeskusten_vaikutus_Suomen_talouteenV3.docx: investoinnin
#     paaomarakenne (IT-laitteisto / talotekniikka-sahkoinfra / maanrakennus-
#     perustus-kuori), Fingridin sahkoverkkoinvestoinnit, seka BKT- ja
#     verotulomalli (tama osa on jo koodattu datakeskus_vaikutukset.R:aan,
#     jota tama skripti kayttaa suoraan - EI toisintoa).
#
# HUOM MERKITTAVISTA OLETUKSISTA (merkitty [O] alla, [M] = suoraan
# muistiosta): investointilaji-erittely ja sahkoverkon datakeskusosuus eivat
# ole muistion omia valmiita lukuja vuosille 2027/2028 nimenomaisesti, vaan
# tama skripti soveltaa muistion YLEISIA, koko hankekokonaisuutta koskevia
# prosenttiosuuksia kunkin vuoden toteutuneeseen/ilmoitettuun
# investointisummaan. Tulokset ovat siis suuntaa-antava, karkea arvio -
# ei tarkka tilastollinen laskelma.
#
# Kaytto: Rscript investointilajit_ja_vaikutukset_2027_2028.R

Sys.setlocale("LC_ALL", "C.utf8")

library(readxl)
library(dplyr)

skriptin_kansio <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  polku <- sub("^--file=", "", args[grepl("^--file=", args)])
  if (length(polku) == 1) dirname(normalizePath(polku)) else "."
}
KANSIO <- skriptin_kansio()

fmt <- function(x, des = 0) formatC(x, format = "f", digits = des, big.mark = " ", decimal.mark = ",")

# =============================================================================
# 1. VUOSIEN 2027 JA 2028 DATAKESKUSINVESTOINNIT DATAIKKUNASTA
# =============================================================================
data <- read_excel(file.path(KANSIO, "Dataikkuna_2_11_2026_imputoitu_claude.xlsx"), sheet = "Taul1")

investointi_vuodelle <- data %>%
  filter(Teema == "Datakeskus", Valmistuminen %in% c(2027, 2028)) %>%
  group_by(Valmistuminen) %>%
  summarise(Summa_mrd = sum(`Summa (M€)`, na.rm = TRUE) / 1000, .groups = "drop")

INV_2027 <- investointi_vuodelle$Summa_mrd[investointi_vuodelle$Valmistuminen == 2027]
INV_2028 <- investointi_vuodelle$Summa_mrd[investointi_vuodelle$Valmistuminen == 2028]

cat("=====================================================================\n")
cat(" DATAKESKUSINVESTOINNIT DATAIKKUNASTA (valmistumisvuoden mukaan)\n")
cat("=====================================================================\n")
cat(sprintf("2027: %s mrd. €\n", fmt(INV_2027, 2)))
cat(sprintf("2028: %s mrd. €\n", fmt(INV_2028, 2)))
cat("(HUOM: koko hankkeen ilmoitettu/imputoitu summa on kohdistettu tässä\n")
cat(" kokonaisuudessaan valmistumisvuodelle, vaikka rakentaminen todellisuudessa\n")
cat(" jakautuu useammalle vuodelle ennen valmistumista - yksinkertaistus, koska\n")
cat(" aineistossa ei ole rakentamisen aloitusvuotta.)\n")

# =============================================================================
# 2. INVESTOINTILAJIEN JAKAUTUMINEN (kansantalouden tilinpidon P51K-luokitus)
# =============================================================================
# Muistion taulukko "Datakeskushankkeen pääomamenoista" [M]:
#   IT- ja palvelininfrastruktuuri            n. 65-75 %  (lähes 0 € kotimaista,
#                                                           tuodaan ulkomailta)
#   Talotekniikka ja sähköinfrastruktuuri      n. 15-20 %  (laitteet ulkomailta,
#                                                           Suomeen asennustyö)
#   Maanrakennus, perustus ja kuorirakenteet   n. 10-15 %  (pääosin kotimaista)
#
# Kansantalouden tilinpidossa (P51K):
#   - IT-laitteisto + talotekniikan/sähköinfran LAITTEET (UPS:t, generaattorit,
#     jäähdytyskoneet, kytkinlaitteet) luokitellaan "Koneet, laitteet,
#     kuljetusvälineet" -omaisuuslajiin (eivät rakennuksia)
#   - Maanrakennus, perustukset ja kuorirakenteet (hallit, betonityöt) ovat
#     "Rakennusinvestointeja" (talonrakennukset + maa ja vesi)
#   - "T&K-investoinnit" (kasv.varat, henkiset omaisuustuotteet) ja
#     "Asejärjestelmät" eivät kuulu tämän tyyppiseen fyysiseen konesali-
#     investointiin - ei havaittua perustaa näiden arvioimiseksi muistiosta,
#     joten molemmat on asetettu nollaan [O]. Jos Google/muu toimija
#     kirjaa osan investoinnista ohjelmisto-/T&K-menoiksi, sitä ei ole
#     eroteltu tässä aineistossa.
#
# "Maanrakennus, perustus ja kuorirakenteet" -erä jaetaan edelleen Maa ja vesi
# / Muut talorakennukset -luokkiin muistion tarkemman rakennuskustannusten
# erittelyn suhteella [O, johdettu M:stä]:
#   Tontti, maarakennus, esivalmistelu   5-10 % rakentamisesta -> "Maa ja vesi"
#   Rungon rakenne (perustukset, seinät,
#     laatat)                           10-15 % rakentamisesta -> "Rakennukset"
#   => suhde n. 37,5 % / 62,5 %

SKENAARIOT <- c("Alhainen", "Keskimmäinen", "Korkea")

# Osuudet investoinnista (summa 100 % jokaisessa skenaariossa) [M]
OSUUS_IT            <- c(0.75, 0.70, 0.65)  # koneet/laitteet: IT-infra
OSUUS_TALOTEKNIIKKA <- c(0.15, 0.175, 0.20) # koneet/laitteet: sähkö/jäähdytys
OSUUS_MAANRAKENNUS  <- c(0.10, 0.125, 0.15) # rakennusinvestoinnit yhteensä
MAA_JA_VESI_OSUUS_MAANRAK <- 0.375           # [O] ks. yllä

laske_investointilajit <- function(inv_mrd) {
  koneet_laitteet   <- inv_mrd * (OSUUS_IT + OSUUS_TALOTEKNIIKKA)
  rakennus_yht      <- inv_mrd * OSUUS_MAANRAKENNUS
  maa_ja_vesi       <- rakennus_yht * MAA_JA_VESI_OSUUS_MAANRAK
  muut_talorak      <- rakennus_yht - maa_ja_vesi
  data.frame(
    Skenaario = SKENAARIOT,
    Rakennusinvestoinnit_yht = rakennus_yht,
    Muut_talorakennukset = muut_talorak,
    Maa_ja_vesi = maa_ja_vesi,
    Koneet_laitteet_kuljetusvalineet_asejarjestelmat = koneet_laitteet,
    Koneet_laitteet_kuljetusvalineet = koneet_laitteet,
    Asejarjestelmat = 0,
    TK_investoinnit = 0,
    Yhteensa = rakennus_yht + koneet_laitteet
  )
}

tulosta_investointilajit <- function(vuosi, inv_mrd) {
  tt <- laske_investointilajit(inv_mrd)
  cat(sprintf("\n--- %d: investointi %s mrd. € jaettuna investointilajeihin (mrd. €) ---\n",
              vuosi, fmt(inv_mrd, 2)))
  tulostettava <- data.frame(
    Investointilaji = c(
      "Rakennusinvestoinnit yht.",
      "  Muut talorakennukset kuin asuinrak.",
      "  Maa ja vesi",
      "Koneet, laitteet, kuljetusvälineet ja asejärjestelmät",
      "  Koneet, laitteet, kuljetusvälineet",
      "  Asejärjestelmät",
      "T&K-investoinnit (kasv.varat & henkiset om.)",
      "YHTEENSÄ"
    ),
    Alhainen = fmt(c(tt$Rakennusinvestoinnit_yht[1], tt$Muut_talorakennukset[1], tt$Maa_ja_vesi[1],
                      tt$Koneet_laitteet_kuljetusvalineet_asejarjestelmat[1], tt$Koneet_laitteet_kuljetusvalineet[1],
                      tt$Asejarjestelmat[1], tt$TK_investoinnit[1], tt$Yhteensa[1]), 2),
    Keskimmäinen = fmt(c(tt$Rakennusinvestoinnit_yht[2], tt$Muut_talorakennukset[2], tt$Maa_ja_vesi[2],
                      tt$Koneet_laitteet_kuljetusvalineet_asejarjestelmat[2], tt$Koneet_laitteet_kuljetusvalineet[2],
                      tt$Asejarjestelmat[2], tt$TK_investoinnit[2], tt$Yhteensa[2]), 2),
    Korkea = fmt(c(tt$Rakennusinvestoinnit_yht[3], tt$Muut_talorakennukset[3], tt$Maa_ja_vesi[3],
                      tt$Koneet_laitteet_kuljetusvalineet_asejarjestelmat[3], tt$Koneet_laitteet_kuljetusvalineet[3],
                      tt$Asejarjestelmat[3], tt$TK_investoinnit[3], tt$Yhteensa[3]), 2),
    check.names = FALSE
  )
  print(tulostettava, row.names = FALSE)
  invisible(tt)
}

cat("\n=====================================================================\n")
cat(" 1. INVESTOINTILAJIT (P51K-luokitus), mrd. €\n")
cat("=====================================================================\n")
tt_2027 <- tulosta_investointilajit(2027, INV_2027)
tt_2028 <- tulosta_investointilajit(2028, INV_2028)

# =============================================================================
# 3. SÄHKÖVERKKOINVESTOINNIT (erillinen tarkastelu - Fingrid, ei osa
#    datakeskusyhtiöiden omasta investoinnista Dataikkunassa)
# =============================================================================
# Muistiosta [M]:
#  - Fingrid investoi 2025-2028 n. 2,0 mrd. €, josta n. 0,6 mrd. € jo sidottu
#    olemassa oleviin sopimuksiin (30.9.2025).
#  - Investointitahti kiihtyy ("yhä kiihtyvällä tahdilla").
#  - 80 % investointiohjelmasta perustuu asiakastarpeisiin/alueellisiin
#    tuotanto- ja kulutusmuutoksiin (ei kunnossapitoon).
#  - Yli puolet liityntäkyselyiden volyymista liittyy datakeskushankkeisiin.
#
# [O] Koska muistio ei anna valmista vuosi- tai datakeskuskohtaista jakoa
# 2027/2028:lle, tehdään tässä seuraavat OMAT, selvästi karkeat oletukset:
#  - Vuosijakauma 2025-2028: kiihtyvä tahti -> painot 15/20/30/35 %
#    (2025/2026/2027/2028) 2,0 mrd. €:sta.
#  - Datakeskusten osuus asiakastarvepohjaisesta investoinnista: 45-55 %
#    (yli puolet liityntäkyselyistä, mutta ei kaikki toteudu) x 80 %
#    asiakastarveosuus = n. 36-44 % koko investoinnista.

FINGRID_2025_2028_MRD <- 2.0
FINGRID_VUOSIPAINOT <- c("2025" = 0.15, "2026" = 0.20, "2027" = 0.30, "2028" = 0.35)
FINGRID_DC_OSUUS <- c(Alhainen = 0.36, Keskimmäinen = 0.40, Korkea = 0.44)  # [O]

fingrid_2027 <- FINGRID_2025_2028_MRD * FINGRID_VUOSIPAINOT["2027"]
fingrid_2028 <- FINGRID_2025_2028_MRD * FINGRID_VUOSIPAINOT["2028"]

cat("\n=====================================================================\n")
cat(" 2. SÄHKÖVERKKOINVESTOINNIT (Fingrid, erillään datakeskusyhtiöiden\n")
cat("    omasta investoinnista) - KARKEA OMA ARVIO, ei suoraan muistiosta\n")
cat("=====================================================================\n")
cat(sprintf("Fingridin koko investointi 2027: %s mrd. €, josta datakeskusten osuus:\n",
            fmt(fingrid_2027, 2)))
cat(sprintf("  Alhainen %s mrd. € | Keskimmäinen %s mrd. € | Korkea %s mrd. €\n",
            fmt(fingrid_2027 * FINGRID_DC_OSUUS["Alhainen"], 2),
            fmt(fingrid_2027 * FINGRID_DC_OSUUS["Keskimmäinen"], 2),
            fmt(fingrid_2027 * FINGRID_DC_OSUUS["Korkea"], 2)))
cat(sprintf("Fingridin koko investointi 2028: %s mrd. €, josta datakeskusten osuus:\n",
            fmt(fingrid_2028, 2)))
cat(sprintf("  Alhainen %s mrd. € | Keskimmäinen %s mrd. € | Korkea %s mrd. €\n",
            fmt(fingrid_2028 * FINGRID_DC_OSUUS["Alhainen"], 2),
            fmt(fingrid_2028 * FINGRID_DC_OSUUS["Keskimmäinen"], 2),
            fmt(fingrid_2028 * FINGRID_DC_OSUUS["Korkea"], 2)))
cat("(Nämä summat EIVÄT sisälly Dataikkunan datakeskusinvestointeihin eivätkä\n")
cat(" kohdan 1 investointilaji-erittelyyn - Fingrid on eri investoija.\n")
cat(" Kansantalouden tilinpidossa tämä olisi omana rivinään 'Sähkö-, kaasu-\n")
cat(" ja lämpöhuolto' -toimialan koneet/laitteet- ja rakennusinvestointina.)\n")

# =============================================================================
# 4. BKT- JA VEROTULOVAIKUTUKSET VUOSILLE 2027 JA 2028
#    (käyttää suoraan datakeskus_vaikutukset.R:n valmista mallia -
#     ei toisintoa parametreista)
# =============================================================================
options(datakeskus.vain_funktiot = TRUE)
source(file.path(KANSIO, "datakeskus_vaikutukset.R"))

# Kummankin vuoden koko investointisumma käsitellään omana, yhden vuoden
# "rakennusvaiheenaan" (rakennusvuodet = 1), koska Dataikkunan luvut on jo
# kohdistettu nimenomaiselle valmistumisvuodelle (ks. kohta 1 yllä).
laske_vuosi <- function(vuosi, inv_mrd) {
  p <- P
  p$rakennusvuodet <- 1
  t <- lapply(1:3, function(s) laske(inv_mrd, s, p))
  names(t) <- SKENAARIOT
  t
}

tulokset_2027 <- laske_vuosi(2027, INV_2027)
tulokset_2028 <- laske_vuosi(2028, INV_2028)

tulosta_vuosi <- function(vuosi, inv_mrd, tulokset) {
  cat(sprintf("\n--- %d: investointi %s mrd. € ---\n", vuosi, fmt(inv_mrd, 2)))
  bkt <- sapply(tulokset, function(x) x$bkt_rak)
  verot <- sapply(tulokset, function(x) sum(x$vero_rak))
  valtio <- sapply(tulokset, function(x) sum(x$vero_rak) - x$kunnat_rak)
  kunnat <- sapply(tulokset, function(x) x$kunnat_rak)
  htv <- sapply(tulokset, function(x) x$rak_htv)

  cat("BKT-vaikutus (M€):          ",
      sprintf("Alhainen %s | Keskimmäinen %s | Korkea %s\n",
              fmt(bkt[1]), fmt(bkt[2]), fmt(bkt[3])))
  cat("  % investoinnista:         ",
      sprintf("%s %% | %s %% | %s %%\n",
              fmt(100 * bkt[1] / (inv_mrd * 1000), 1),
              fmt(100 * bkt[2] / (inv_mrd * 1000), 1),
              fmt(100 * bkt[3] / (inv_mrd * 1000), 1)))
  cat("Julkisen talouden tulot yht. (M€): ",
      sprintf("Alhainen %s | Keskimmäinen %s | Korkea %s\n",
              fmt(verot[1], 1), fmt(verot[2], 1), fmt(verot[3], 1)))
  cat("  josta valtio (M€):        ",
      sprintf("%s | %s | %s\n", fmt(valtio[1], 1), fmt(valtio[2], 1), fmt(valtio[3], 1)))
  cat("  josta kunnat (M€):        ",
      sprintf("%s | %s | %s\n", fmt(kunnat[1], 1), fmt(kunnat[2], 1), fmt(kunnat[3], 1)))
  cat("Työllisyys, htv (suora+epäsuora): ",
      sprintf("%s | %s | %s\n", fmt(htv[1]), fmt(htv[2]), fmt(htv[3])))
}

cat("\n=====================================================================\n")
cat(" 3. BKT-VAIKUTUS (rakennusvaihe, kyseisen vuoden investoinnit)\n")
cat(" 4. JULKISEN TALOUDEN VEROTULOT (rakennusvaihe, kyseisen vuoden investoinnit)\n")
cat("=====================================================================\n")
tulosta_vuosi(2027, INV_2027, tulokset_2027)
tulosta_vuosi(2028, INV_2028, tulokset_2028)

cat("\n=====================================================================\n")
cat(" YHTEENVETO 2027-2028 (keskimmäinen skenaario)\n")
cat("=====================================================================\n")
cat(sprintf("Datakeskusinvestoinnit yhteensä:      %s mrd. €\n", fmt(INV_2027 + INV_2028, 2)))
cat(sprintf("  - josta koneet/laitteet (IT ym.):   %s mrd. €\n",
            fmt(tt_2027$Koneet_laitteet_kuljetusvalineet[2] + tt_2028$Koneet_laitteet_kuljetusvalineet[2], 2)))
cat(sprintf("  - josta rakennusinvestoinnit:        %s mrd. €\n",
            fmt(tt_2027$Rakennusinvestoinnit_yht[2] + tt_2028$Rakennusinvestoinnit_yht[2], 2)))
cat(sprintf("BKT-vaikutus yhteensä:                 %s mrd. €\n",
            fmt((tulokset_2027$Keskimmäinen$bkt_rak + tulokset_2028$Keskimmäinen$bkt_rak) / 1000, 2)))
cat(sprintf("Julkisen talouden tulot yhteensä:      %s milj. €\n",
            fmt(sum(tulokset_2027$Keskimmäinen$vero_rak) + sum(tulokset_2028$Keskimmäinen$vero_rak), 1)))
cat(sprintf("Fingridin datakeskusosuus (sähköverkko, erillään): %s mrd. €\n",
            fmt((fingrid_2027 + fingrid_2028) * FINGRID_DC_OSUUS["Keskimmäinen"], 2)))
