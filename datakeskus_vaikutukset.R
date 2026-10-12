#!/usr/bin/env Rscript
# =============================================================================
# Datakeskusinvestoinnin vaikutukset Suomen BKT:hen, työllisyyteen ja
# julkiseen talouteen
#
# Laskelma perustuu muistioon "Datakeskusten vaikutus Suomen talouteen"
# (päivitetty 9/2026, tiedosto lahteet/Datakeskusten_vaikutus_Suomen_talouteen.docx).
# Muistion luvut on esitetty pääosin Rambollin/FDCA:n
# 12 mrd. euron investointikokonaisuudelle, joten ne skaalataan tässä
# lineaarisesti käyttäjän antamaan investoinnin suuruuteen.
#
# BKT lasketaan menetelmän mukaan: BKT = C + I + G + (X - M).
# Jokainen euro lasketaan vain kerran (ks. muistion "korjattu kaavio"):
#   - Investointi (I) kasvattaa BKT:tä vain kotimaisen arvonlisän osalta,
#     koska IT-laitteet ym. tuodaan ulkomailta (tuonti M kumoaa ne).
#   - Käyttövaiheessa datakeskus myy palvelunsa ulkomaiselle emoyhtiölle
#     (siirtohinnoittelu: kulut + voittolisä) -> palveluvienti X.
#   - Palkoista syntyvä kulutus (C) sisältää epäsuorat ja indusoidut
#     vaikutukset, eikä kerrointa lisätä erikseen päälle.
#   - Verotulot ovat julkisen talouden tuloja, eivät julkista kulutusta (G),
#     joten G = 0.
#
# Käyttö:
#   Rscript datakeskus_vaikutukset.R          # kysyy investoinnin suuruuden
#   Rscript datakeskus_vaikutukset.R 12       # investointi 12 mrd. €
#   Rscript datakeskus_vaikutukset.R 12 5     # investointi 12 mrd. €, rakennusaika 5 v
#   tai RStudiossa: source("datakeskus_vaikutukset.R")
#
# Kaikki rahamäärät miljoonina euroina (M€), ellei toisin mainita.
# Parametrit annetaan muodossa c(alhainen, keskimmäinen, korkea).
# =============================================================================

SKENAARIOT <- c("Alhainen", "Keskimmäinen", "Korkea")

# Rambollin/FDCA:n laskelman investointikokonaisuus, johon muistion luvut
# suhteutetaan (mrd. €)
PERUSINVESTOINTI_MRD <- 12

# Tallennetaanko tulokset CSV-tiedostoon työhakemistoon
TALLENNA_CSV <- FALSE

# -----------------------------------------------------------------------------
# PARAMETRIT
# [M] = muistiosta, [O] = laskelman oma oletus (ei muistiossa)
# -----------------------------------------------------------------------------
P <- list(

  # --- Rakennusvaihe: pääomarakenne ja tuonti --------------------------------
  # Kotimaisen toimitusketjun laskutus osuutena investoinnista [M]
  # (keskiarvo 2 500 M€ / 12 000 M€; vaihteluväli investointierien taulukosta:
  #  maanrakennus 10-15 % pääosin kotimaista, talotekniikasta vain asennus)
  kotimainen_osuus      = c(0.12, 2500 / 12000, 0.23),
  # Kotimaisten urakoiden tuontisisältö (materiaalit, komponentit) [O]
  kotim_tuontisisalto   = c(0.25, 0.20, 0.15),
  # Oletusrakennusaika vuosina [O] (Rambollin 12 mrd. kokonaisuus 2025-2030)
  rakennusvuodet        = 3,

  # --- Rakennusvaihe: työllisyys ja kulutus ---------------------------------
  # Työllisyys 3 750 htv / mrd. € (suora + epäsuora) [M, Ramboll]
  rak_htv_per_mrd       = c(3750, 3750, 3750),
  # Keskipalkka rakennusvaiheessa, € / htv [M]
  rak_keskipalkka       = c(45000, 45000, 45000),
  # Suomessa asuvien työntekijöiden osuus [M, Hukkanen & Syväkuru]
  suomalaisten_osuus    = c(0.50, 0.60, 0.70),
  # Osuus palkoista, joka päätyy kulutukseen verojen jälkeen [M]
  kulutusosuus          = c(0.60, 0.625, 0.65),
  # Yksityisen kulutuksen tuontisisältö [O]
  kulutus_tuontisisalto = c(0.30, 0.30, 0.30),

  # --- Rakennusvaihe: verotulot (M€ per 12 mrd. €) --------------------------
  rak_yhteisovero_12    = c(25, 42, 60),    # urakoitsijat, toimittajat [M]
  rak_alv_12            = c(20, 33, 45),    # nettona, työntekijöiden kulutus [M]
  rak_tulovero_12       = c(210, 315, 420), # valtio + kunnat [M]
  rak_tulovero_valtio   = c(2/3, 2/3, 2/3), # valtion osuus tuloverosta [M]
  # Rakennusaikainen kiinteistövero = osuus käyttövaiheen vuosiverosta [M]
  rak_kiinteistovero_os = 0.5,

  # --- Käyttövaihe: työllisyys ----------------------------------------------
  # Kokonaistyöllisyys (suora + epäsuora) htv / mrd. € / vuosi [M]
  # (7 500 htv / 12 mrd. = 625; 9 900 htv / 12 mrd. = 825)
  kaytto_htv_per_mrd    = c(625, 725, 825),
  # Suorat työntekijät (henkilöstö ja ylläpito) per 12 mrd. € [M]
  kaytto_suorat_12      = c(500, 1000, 1500),
  # Henkilöstö- ja ylläpitokulu, € / htv (1 000 htv = 100 M€) [M]
  henkilostokulu_htv    = c(100000, 100000, 100000),
  # Palkkasummat käyttövaiheessa, M€ / v per 12 mrd. € [M]
  kaytto_palkat_suorat_12   = c(72, 84, 96),
  kaytto_palkat_epasuor_12  = c(405, 450, 495),

  # --- Käyttövaihe: sähkö ja liiketoiminta ----------------------------------
  # Sähköteho MW / mrd. € (1 215 MW / 12 mrd. €) [M]
  mw_per_mrd            = c(1215, 1215, 1215) / 12,
  # Käyttöaste [M]
  kayttoaste            = c(0.75, 0.85, 0.90),
  # Sähköenergia + kantaverkon siirtomaksu, € / MWh [M]
  sahkon_hinta          = c(50, 60, 70),
  # Siirtohinnoittelun voittolisä kuluista [M]
  voittolisa            = c(0.06, 0.07, 0.08),
  # Tuontisähkön osuus kulutetusta sähköstä [O]
  tuontisahko_osuus     = c(0.15, 0.10, 0.05),

  # --- Käyttövaihe: verotulot -----------------------------------------------
  yhteisoveroaste       = 0.20,                # [M]
  yhteisovero_kunnat    = 1 / 3,               # kuntien jako-osuus [M]
  kaytto_alv_12         = c(3, 7, 11),         # M€ / v per 12 mrd. [M]
  kaytto_tulovero_12    = c(8, 20.1, 36.5),    # suorat työntekijät [M]
  kaytto_tulovero_valtio = c(5.9 / 8, 15.3 / 20.1, 28.2 / 36.5), # [M]
  # Kiinteistöjen verotusarvo per 12 mrd. € (M€) ja veroprosentti [M]
  verotusarvo_12        = c(1500, 1750, 2000),
  kiinteistoveropros    = c(0.012, 0.0125, 0.013),
  # Sähkövero huoltovarmuusmaksu mukaan lukien, € / MWh (1.7.2026 alkaen) [M]
  sahkovero             = c(22.66, 22.66, 22.66),

  # --- Vertailutasot --------------------------------------------------------
  bkt_taso              = 280000,   # Suomen nimellinen BKT, M€ [O]
  tyolliset             = 2600000,  # Työllisten määrä [O]
  kayttovuodet          = 10        # Kumulatiivisen tarkastelun käyttövuodet [O]
)

# Rambollin bruttoluvut per mrd. € vertailua varten [M]
RAMBOLL <- list(rak_htv = 3750, verotulot = 142, liikevaihto = 250, mw = 101)

# -----------------------------------------------------------------------------
# APUFUNKTIOT
# -----------------------------------------------------------------------------
fmt <- function(x, des = 0) {
  formatC(x, format = "f", digits = des, big.mark = " ", decimal.mark = ",")
}

STDIN <- NULL
lue_rivi <- function(kehote) {
  if (interactive()) {
    readline(kehote)
  } else {
    cat(kehote)
    if (is.null(STDIN)) STDIN <<- file("stdin", open = "r")
    rivi <- readLines(STDIN, n = 1, warn = FALSE)
    if (length(rivi) == 0) "" else rivi
  }
}

jasenna_luku <- function(teksti) {
  teksti <- gsub("[[:space:]]", "", teksti)
  teksti <- sub(",", ".", teksti, fixed = TRUE)
  suppressWarnings(as.numeric(teksti))
}

kysy_investointi <- function() {
  repeat {
    vastaus <- lue_rivi("Anna datakeskusinvestoinnin suuruus (mrd. €, esim. 1,5): ")
    arvo <- jasenna_luku(vastaus)
    if (!is.na(arvo) && arvo > 0) return(arvo)
    if (!interactive() && vastaus == "") stop("Investoinnin suuruutta ei annettu.")
    cat("Virheellinen arvo. Anna positiivinen luku miljardeina euroina.\n")
  }
}

kysy_rakennusaika <- function(oletus) {
  vastaus <- lue_rivi(sprintf("Anna rakennusaika vuosina [oletus %d]: ", oletus))
  arvo <- jasenna_luku(vastaus)
  if (is.na(arvo) || arvo < 1) oletus else round(arvo)
}

# -----------------------------------------------------------------------------
# LASKENTA
# inv = investointi mrd. €, s = skenaarion indeksi (1-3)
# -----------------------------------------------------------------------------
laske <- function(inv, s, p = P) {
  k <- inv / PERUSINVESTOINTI_MRD   # skaalauskerroin muistion 12 mrd. lukuihin
  v <- p$rakennusvuodet

  # --- Rakennusvaihe (koko rakennusajalta) ---------------------------------
  I       <- inv * 1000
  kotim   <- I * p$kotimainen_osuus[s]
  M_inv   <- (I - kotim) + kotim * p$kotim_tuontisisalto[s]

  rak_htv      <- inv * p$rak_htv_per_mrd[s]
  rak_palkat   <- rak_htv * p$rak_keskipalkka[s] / 1e6
  C_rak        <- rak_palkat * p$kulutusosuus[s] * p$suomalaisten_osuus[s]
  M_C_rak      <- C_rak * p$kulutus_tuontisisalto[s]
  bkt_rak      <- I + C_rak - M_inv - M_C_rak

  # --- Käyttövaihe (vuodessa) ------------------------------------------------
  mw           <- inv * p$mw_per_mrd[s]
  sahko_mwh    <- mw * p$kayttoaste[s] * 8760
  sahkokulut   <- sahko_mwh * p$sahkon_hinta[s] / 1e6
  suorat_htv   <- k * p$kaytto_suorat_12[s]
  henkilosto   <- suorat_htv * p$henkilostokulu_htv[s] / 1e6
  opex         <- sahkokulut + henkilosto
  X            <- opex * (1 + p$voittolisa[s])       # palveluvienti emoyhtiölle
  M_sahko      <- sahkokulut * p$tuontisahko_osuus[s]
  palkat_k     <- k * (p$kaytto_palkat_suorat_12[s] + p$kaytto_palkat_epasuor_12[s])
  C_kaytto     <- palkat_k * p$kulutusosuus[s]
  M_C_kaytto   <- C_kaytto * p$kulutus_tuontisisalto[s]
  bkt_kaytto   <- X + C_kaytto - M_sahko - M_C_kaytto
  kaytto_htv   <- inv * p$kaytto_htv_per_mrd[s]

  # --- Julkinen talous -------------------------------------------------------
  kiinteistovero_v <- k * p$verotusarvo_12[s] * p$kiinteistoveropros[s]

  vero_rak <- c(
    Yhteisovero    = k * p$rak_yhteisovero_12[s],
    ALV_netto      = k * p$rak_alv_12[s],
    Tulovero       = k * p$rak_tulovero_12[s],
    Kiinteistovero = kiinteistovero_v * p$rak_kiinteistovero_os * v,
    Sahkovero      = 0
  )
  vero_kaytto <- c(
    Yhteisovero    = opex * p$voittolisa[s] * p$yhteisoveroaste,
    ALV_netto      = k * p$kaytto_alv_12[s],
    Tulovero       = k * p$kaytto_tulovero_12[s],
    Kiinteistovero = kiinteistovero_v,
    Sahkovero      = sahko_mwh * p$sahkovero[s] / 1e6
  )

  # Jako valtion ja kuntien kesken
  kunnat_rak <- vero_rak["Yhteisovero"] * p$yhteisovero_kunnat +
    vero_rak["Tulovero"] * (1 - p$rak_tulovero_valtio[s]) +
    vero_rak["Kiinteistovero"]
  kunnat_kaytto <- vero_kaytto["Yhteisovero"] * p$yhteisovero_kunnat +
    vero_kaytto["Tulovero"] * (1 - p$kaytto_tulovero_valtio[s]) +
    vero_kaytto["Kiinteistovero"]

  list(
    I = I, M_inv = M_inv, C_rak = C_rak, M_C_rak = M_C_rak,
    bkt_rak = bkt_rak, bkt_rak_v = bkt_rak / v,
    rak_htv = rak_htv, rak_htv_v = rak_htv / v,
    rak_htv_suomi = rak_htv * p$suomalaisten_osuus[s],
    mw = mw, sahko_twh = sahko_mwh / 1e6, opex = opex, X = X,
    M_sahko = M_sahko, C_kaytto = C_kaytto, M_C_kaytto = M_C_kaytto,
    bkt_kaytto = bkt_kaytto, kaytto_htv = kaytto_htv, suorat_htv = suorat_htv,
    vero_rak = vero_rak, vero_kaytto = vero_kaytto,
    kunnat_rak = unname(kunnat_rak), kunnat_kaytto = unname(kunnat_kaytto)
  )
}

# -----------------------------------------------------------------------------
# TULOSTUS
# -----------------------------------------------------------------------------
tulosta_taulukko <- function(otsikko, rivit) {
  # Tasaus merkkien (ei tavujen) mukaan, jotta ä, ö ja € eivät siirrä sarakkeita
  vasen  <- function(x, w) paste0(x, strrep(" ", pmax(0, w - nchar(x))))
  oikea  <- function(x, w = 14) paste0(strrep(" ", pmax(0, w - nchar(x))), x)
  cat("\n", otsikko, "\n", strrep("-", nchar(otsikko)), "\n", sep = "")
  leveys <- max(nchar(names(rivit)))
  cat(vasen("", leveys), oikea(SKENAARIOT), "\n")
  for (nimi in names(rivit)) {
    cat(vasen(nimi, leveys), oikea(rivit[[nimi]]), "\n")
  }
}

aja_laskelma <- function(inv, rakennusvuodet = P$rakennusvuodet) {
  P$rakennusvuodet <<- rakennusvuodet
  t <- lapply(1:3, function(s) laske(inv, s))
  g <- function(f, des = 0) sapply(t, function(x) fmt(f(x), des))
  pros <- function(f, taso, des = 2) sapply(t, function(x) paste0(fmt(100 * f(x) / taso, des), " %"))
  ky <- P$kayttovuodet

  cat("\n=====================================================================\n")
  cat(sprintf(" DATAKESKUSINVESTOINTI %s MRD. € - VAIKUTUKSET SUOMEN TALOUTEEN\n", fmt(inv, 2)))
  cat("=====================================================================\n")
  cat(sprintf("Rakennusaika %d v, kumulatiivinen tarkastelu %d käyttövuotta.\n",
              P$rakennusvuodet, ky))
  cat(sprintf("Sähköteho %s MW, sähkönkulutus %s TWh/v (keskimmäinen skenaario).\n",
              fmt(t[[2]]$mw), fmt(t[[2]]$sahko_twh, 2)))

  tulosta_taulukko("1. BKT-VAIKUTUS, RAKENNUSVAIHE (M€, koko rakennusaika)", list(
    "Investoinnit (I)"                = g(function(x) x$I),
    "Tuonti: laitteet ja materiaalit (-M)" = g(function(x) -x$M_inv),
    "Yksityinen kulutus (C)"          = g(function(x) x$C_rak),
    "Kulutuksen tuontisisältö (-M)"   = g(function(x) -x$M_C_rak),
    "BKT-vaikutus yhteensä"           = g(function(x) x$bkt_rak),
    "BKT-vaikutus / vuosi"            = g(function(x) x$bkt_rak_v),
    "  % BKT:sta / vuosi"             = pros(function(x) x$bkt_rak_v, P$bkt_taso, 3),
    "BKT-vaikutus / investoitu €"     = g(function(x) x$bkt_rak / x$I, 2)
  ))

  tulosta_taulukko("2. BKT-VAIKUTUS, KÄYTTÖVAIHE (M€ / vuosi)", list(
    "Palveluvienti emoyhtiölle (X)"   = g(function(x) x$X),
    "  josta toimintakulut"           = g(function(x) x$opex),
    "Tuontisähkö (-M)"                = g(function(x) -x$M_sahko),
    "Yksityinen kulutus (C)"          = g(function(x) x$C_kaytto),
    "Kulutuksen tuontisisältö (-M)"   = g(function(x) -x$M_C_kaytto),
    "BKT-vaikutus / vuosi"            = g(function(x) x$bkt_kaytto),
    "  % BKT:sta"                     = pros(function(x) x$bkt_kaytto, P$bkt_taso, 3)
  ))

  tulosta_taulukko("3. TYÖLLISYYS (henkilötyövuotta, suora + epäsuora)", list(
    "Rakennusvaihe yhteensä"          = g(function(x) x$rak_htv),
    "  josta Suomessa asuvat"         = g(function(x) x$rak_htv_suomi),
    "Rakennusvaihe / vuosi"           = g(function(x) x$rak_htv_v),
    "  % työllisistä / vuosi"              = pros(function(x) x$rak_htv_v, P$tyolliset, 3),
    "Käyttövaihe / vuosi"             = g(function(x) x$kaytto_htv),
    "  josta suorat"                  = g(function(x) x$suorat_htv),
    "  % työllisistä"                 = pros(function(x) x$kaytto_htv, P$tyolliset, 3)
  ))

  verorivit <- function(kentta) {
    nimet <- c(Yhteisovero = "Yhteisövero", ALV_netto = "ALV (netto)",
               Tulovero = "Tulovero", Kiinteistovero = "Kiinteistövero",
               Sahkovero = "Sähkövero")
    r <- lapply(names(nimet), function(n) g(function(x) x[[kentta]][n], 1))
    names(r) <- nimet
    r[["Yhteensä"]] <- g(function(x) sum(x[[kentta]]), 1)
    r
  }

  rak <- verorivit("vero_rak")
  rak[["  josta valtio"]] <- g(function(x) sum(x$vero_rak) - x$kunnat_rak, 1)
  rak[["  josta kunnat"]] <- g(function(x) x$kunnat_rak, 1)
  tulosta_taulukko("4. JULKISEN TALOUDEN TULOT, RAKENNUSVAIHE (M€, koko rakennusaika)", rak)

  kay <- verorivit("vero_kaytto")
  kay[["  josta valtio"]] <- g(function(x) sum(x$vero_kaytto) - x$kunnat_kaytto, 1)
  kay[["  josta kunnat"]] <- g(function(x) x$kunnat_kaytto, 1)
  tulosta_taulukko("5. JULKISEN TALOUDEN TULOT, KÄYTTÖVAIHE (M€ / vuosi)", kay)

  tulosta_taulukko(sprintf("6. KUMULATIIVISET VEROTULOT (rakennus + %d käyttövuotta, M€)", ky), list(
    "Verotulot yhteensä"              = g(function(x) sum(x$vero_rak) + ky * sum(x$vero_kaytto)),
    "  % investoinnista"              = pros(function(x) sum(x$vero_rak) + ky * sum(x$vero_kaytto), inv * 1000, 1),
    "  josta sähkövero"               = g(function(x) ky * x$vero_kaytto["Sahkovero"])
  ))

  m <- t[[2]]
  cat("\n7. VERTAILU RAMBOLLIN BRUTTOLUKUIHIN (keskimmäinen skenaario)\n")
  cat("--------------------------------------------------------------\n")
  cat(sprintf("Rakennusvaiheen verotulot: Ramboll %s M€, tämä laskelma %s M€\n",
              fmt(RAMBOLL$verotulot * inv), fmt(sum(m$vero_rak))))
  cat(sprintf("Käyttövaiheen liikevaihto: Ramboll %s M€/v, Suomeen kirjautuva palveluvienti %s M€/v\n",
              fmt(RAMBOLL$liikevaihto * inv), fmt(m$X)))
  cat("Ero johtuu siitä, ettei tämä laskelma huomioi ALV-palautuksia bruttona ja\n")
  cat("siirtohinnoittelun vuoksi Suomen tytäryhtiölle kirjautuu vain kulut + voittolisä.\n")

  cat("\nHUOMIOITA\n---------\n")
  cat("- Sähkövero on käyttövaiheen suurin verotulo (n. 80 %). Jos datakeskukset\n")
  cat("  verotetaan alemmassa sähköveroluokassa, muuta parametria P$sahkovero.\n")
  cat("- ALV-palautukset (brutto n. 75 M€ / mrd. €) eivät ole valtion tappio, sillä ne\n")
  cat("  palauttavat jo tilitetyn veron; laskelmassa käytetään netto-ALV:tä.\n")
  cat("- Kantaverkon vahvistuskustannuksia (Fingrid) ja sähkön hintavaikutusta\n")
  cat("  kotitalouksien kulutukseen ei ole kvantifioitu.\n")
  cat("- Laitteiston uusimisinvestoinnit (3-5 v sykli) ovat lähes kokonaan tuontia,\n")
  cat("  eikä niitä ole otettu BKT-vaikutukseen mukaan.\n")
  cat("- Muistion 12 mrd. € luvut skaalataan lineaarisesti; pienissä hankkeissa\n")
  cat("  mittakaavaedut ja kiinteät kustannukset voivat muuttaa suhdelukuja.\n")

  if (TALLENNA_CSV) {
    tulokset <- data.frame(
      skenaario = SKENAARIOT,
      investointi_mrd = inv,
      bkt_rakennus_yht = sapply(t, `[[`, "bkt_rak"),
      bkt_rakennus_v = sapply(t, `[[`, "bkt_rak_v"),
      bkt_kaytto_v = sapply(t, `[[`, "bkt_kaytto"),
      htv_rakennus_yht = sapply(t, `[[`, "rak_htv"),
      htv_kaytto_v = sapply(t, `[[`, "kaytto_htv"),
      verot_rakennus_yht = sapply(t, function(x) sum(x$vero_rak)),
      verot_kaytto_v = sapply(t, function(x) sum(x$vero_kaytto))
    )
    tiedosto <- "datakeskus_vaikutukset_tulokset.csv"
    write.csv2(tulokset, tiedosto, row.names = FALSE)
    cat(sprintf("\nTulokset tallennettu tiedostoon %s\n", tiedosto))
  }

  invisible(t)
}

# -----------------------------------------------------------------------------
# AJO
# -----------------------------------------------------------------------------
argumentit <- commandArgs(trailingOnly = TRUE)
if (length(argumentit) >= 1) {
  investointi <- jasenna_luku(argumentit[1])
  if (is.na(investointi) || investointi <= 0) stop("Investoinnin on oltava positiivinen luku (mrd. €).")
  rakennusaika <- if (length(argumentit) >= 2) round(jasenna_luku(argumentit[2])) else P$rakennusvuodet
} else {
  investointi <- kysy_investointi()
  rakennusaika <- kysy_rakennusaika(P$rakennusvuodet)
}

tulokset <- aja_laskelma(investointi, rakennusaika)
