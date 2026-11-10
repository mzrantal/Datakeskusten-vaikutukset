# =============================================================================
# Datakeskusinvestointien vaikutukset 2027-2028: investointilajit,
# sähköverkkoinvestoinnit, BKT-vaikutus ja julkisen talouden verotulot
#
# Yhdistää:
#   - Dataikkuna_2_11_2026_imputoitu_claude.xlsx: toteutuneet/ilmoitetut
#     datakeskusinvestoinnit valmistumisvuoden mukaan
#   - Datakeskusten_vaikutus_Suomen_talouteenV3.docx: investoinnin
#     pääomarakenne, BKT- ja verotulomalli (malli on koodattu valmiiksi
#     tiedostoon datakeskus_vaikutukset.R, jota tämä skripti käyttää
#     suoraan - parametreja ei toisinneta tänne)
#
# Tuottaa konsolitulostuksen lisäksi kolme kuviota (PNG):
#   datakeskus_investointilajit_2027_2028.png
#   datakeskus_bkt_vaikutus_2027_2028.png
#   datakeskus_verotulot_2027_2028.png
#
# HUOM RAJAUKSISTA:
#  - Kaikki BKT- ja verotulovaikutukset koskevat RAKENNUSVAIHETTA (kyseisen
#    vuoden investointikohortin kertaluonteinen vaikutus: bkt_rak / vero_rak
#    datakeskus_vaikutukset.R:ssä), EI jo valmistuneiden konesalien
#    KÄYTTÖVAIHEEN jatkuvia vuosittaisia vaikutuksia (bkt_kaytto / vero_kaytto).
#  - Dataikkunan "Valmistuminen"-vuosi on hankkeen valmistumisvuosi, ei
#    rakentamisen ajoitus - koko hankkeen summa on kohdistettu tässä
#    valmistumisvuodelle (rakennusvuodet = 1 per vuosikohortti). Todellinen
#    rakennustyö on voinut tapahtua osin jo aiempina vuosina.
#  - Investointilaji- ja sähköverkko-osuudet ovat muistion yleisistä
#    prosenttiosuuksista johdettuja karkeita arvioita, ei tarkkoja,
#    vuosikohtaisia tilastolukuja - ks. merkinnät [M] (suoraan muistiosta)
#    ja [O] (oma, muistiosta johdettu tai siitä riippumaton oletus).
#
# Käyttö:
#   Rscript datakeskus_ohjelma_2027_2028.R
# Riippuvuudet: readxl, dplyr, ggplot2, scales
# =============================================================================

Sys.setlocale("LC_ALL", "C.utf8")

library(readxl)
library(dplyr)
library(ggplot2)
library(scales)

skriptin_kansio <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  polku <- sub("^--file=", "", args[grepl("^--file=", args)])
  if (length(polku) == 1) dirname(normalizePath(polku)) else "."
}
KANSIO <- skriptin_kansio()

fmt <- function(x, des = 0) formatC(x, format = "f", digits = des, big.mark = " ", decimal.mark = ",")
VUODET <- c(2027, 2028)
SKENAARIOT <- c("Alhainen", "Keskimmäinen", "Korkea")

# =============================================================================
# 1. VUOSIEN 2027 JA 2028 DATAKESKUSINVESTOINNIT DATAIKKUNASTA
# =============================================================================
data <- read_excel(file.path(KANSIO, "Dataikkuna_2_11_2026_imputoitu_claude.xlsx"), sheet = "Taul1")

investointi_vuodelle <- data %>%
  filter(Teema == "Datakeskus", Valmistuminen %in% VUODET) %>%
  group_by(Valmistuminen) %>%
  summarise(Summa_mrd = sum(`Summa (M€)`, na.rm = TRUE) / 1000, .groups = "drop")

INV <- setNames(investointi_vuodelle$Summa_mrd, investointi_vuodelle$Valmistuminen)

cat("=====================================================================\n")
cat(" DATAKESKUSINVESTOINNIT DATAIKKUNASTA (valmistumisvuoden mukaan)\n")
cat("=====================================================================\n")
for (v in VUODET) cat(sprintf("%d: %s mrd. €\n", v, fmt(INV[[as.character(v)]], 2)))

# =============================================================================
# 2. INVESTOINTILAJIT (kansantalouden tilinpidon P51K-luokitus)
# =============================================================================
# Muistion taulukko "Datakeskushankkeen pääomamenoista" [M]:
#   IT- ja palvelininfrastruktuuri            n. 65-75 %  (koneet/laitteet)
#   Talotekniikka ja sähköinfrastruktuuri      n. 15-20 %  (koneet/laitteet)
#   Maanrakennus, perustus ja kuorirakenteet   n. 10-15 %  (rakennusinvestoinnit)
# "T&K-investoinnit" ja "Asejärjestelmät" eivät kuulu tähän fyysiseen
# konesali-investointiin [O] - asetettu nollaan.
# Maanrakennus-erä jaetaan edelleen Maa ja vesi / Rakennukset -suhteella
# n. 37,5 % / 62,5 % [O, johdettu muistion rakennuskustannuserittelystä].
OSUUS_IT            <- c(0.75, 0.70, 0.65)
OSUUS_TALOTEKNIIKKA  <- c(0.15, 0.175, 0.20)
OSUUS_MAANRAKENNUS   <- c(0.10, 0.125, 0.15)
MAA_JA_VESI_OSUUS    <- 0.375

laske_investointilajit <- function(inv_mrd) {
  koneet_laitteet <- inv_mrd * (OSUUS_IT + OSUUS_TALOTEKNIIKKA)
  rakennus_yht    <- inv_mrd * OSUUS_MAANRAKENNUS
  maa_ja_vesi     <- rakennus_yht * MAA_JA_VESI_OSUUS
  muut_talorak    <- rakennus_yht - maa_ja_vesi
  list(
    koneet_laitteet = setNames(koneet_laitteet, SKENAARIOT),
    rakennus_yht    = setNames(rakennus_yht, SKENAARIOT),
    maa_ja_vesi     = setNames(maa_ja_vesi, SKENAARIOT),
    muut_talorak    = setNames(muut_talorak, SKENAARIOT)
  )
}

investointilajit <- lapply(VUODET, function(v) laske_investointilajit(INV[[as.character(v)]]))
names(investointilajit) <- VUODET

cat("\n=====================================================================\n")
cat(" INVESTOINTILAJIT (P51K-luokitus), mrd. € - keskimmäinen skenaario\n")
cat("=====================================================================\n")
for (v in VUODET) {
  il <- investointilajit[[as.character(v)]]
  cat(sprintf("\n--- %d (investointi %s mrd. €) ---\n", v, fmt(INV[[as.character(v)]], 2)))
  cat(sprintf("  Rakennusinvestoinnit yht.:            %s mrd. €\n", fmt(il$rakennus_yht["Keskimmäinen"], 2)))
  cat(sprintf("    Muut talorakennukset kuin asuinrak.: %s mrd. €\n", fmt(il$muut_talorak["Keskimmäinen"], 2)))
  cat(sprintf("    Maa ja vesi:                          %s mrd. €\n", fmt(il$maa_ja_vesi["Keskimmäinen"], 2)))
  cat(sprintf("  Koneet, laitteet, kuljetusvälineet:    %s mrd. €\n", fmt(il$koneet_laitteet["Keskimmäinen"], 2)))
  cat(sprintf("  T&K-investoinnit / Asejärjestelmät:    0 mrd. €\n"))
}

# =============================================================================
# 3. SÄHKÖVERKKOINVESTOINNIT (Fingrid, erillään datakeskusyhtiöiden omasta
#    investoinnista - EI osa Dataikkunan summista)
# =============================================================================
# [M] Fingrid 2025-2028 yhteensä n. 2,0 mrd. €, investointitahti kiihtyy,
#     80 % asiakastarvepohjaista, yli puolet liityntäkyselyistä datakeskuksia.
# [O] Vuosijakauma (kiihtyvä tahti) ja datakeskusosuus - ei muistion valmis luku.
FINGRID_2025_2028_MRD <- 2.0
FINGRID_VUOSIPAINOT <- c("2025" = 0.15, "2026" = 0.20, "2027" = 0.30, "2028" = 0.35)
FINGRID_DC_OSUUS <- setNames(c(0.36, 0.40, 0.44), SKENAARIOT)

sahkoverkko <- lapply(VUODET, function(v) {
  kokonaisinvestointi <- FINGRID_2025_2028_MRD * FINGRID_VUOSIPAINOT[[as.character(v)]]
  setNames(kokonaisinvestointi * FINGRID_DC_OSUUS, SKENAARIOT)
})
names(sahkoverkko) <- VUODET

cat("\n=====================================================================\n")
cat(" SÄHKÖVERKKOINVESTOINNIT (Fingrid) - datakeskusten arvioitu osuus, mrd. €\n")
cat(" KARKEA OMA ARVIO - ei suoraan muistiosta, ks. skriptin kommentit\n")
cat("=====================================================================\n")
for (v in VUODET) {
  sv <- sahkoverkko[[as.character(v)]]
  cat(sprintf("%d: Alhainen %s | Keskimmäinen %s | Korkea %s (mrd. €)\n",
              v, fmt(sv["Alhainen"], 2), fmt(sv["Keskimmäinen"], 2), fmt(sv["Korkea"], 2)))
}

# =============================================================================
# 4. BKT- JA VEROTULOVAIKUTUS (RAKENNUSVAIHE), käyttäen suoraan
#    datakeskus_vaikutukset.R:n valmista mallia
# =============================================================================
options(datakeskus.vain_funktiot = TRUE)
source(file.path(KANSIO, "datakeskus_vaikutukset.R"))

laske_vuosi <- function(inv_mrd) {
  p <- P
  p$rakennusvuodet <- 1  # kyseisen vuoden investointi = oma 1 vuoden kohortti
  t <- lapply(1:3, function(s) laske(inv_mrd, s, p))
  names(t) <- SKENAARIOT
  t
}

tulokset <- lapply(VUODET, function(v) laske_vuosi(INV[[as.character(v)]]))
names(tulokset) <- VUODET

cat("\n=====================================================================\n")
cat(" BKT-VAIKUTUS JA JULKISEN TALOUDEN VEROTULOT (RAKENNUSVAIHE)\n")
cat("=====================================================================\n")
for (v in VUODET) {
  t <- tulokset[[as.character(v)]]
  bkt <- sapply(t, function(x) x$bkt_rak)
  verot <- sapply(t, function(x) sum(x$vero_rak))
  cat(sprintf("\n--- %d (investointi %s mrd. €) ---\n", v, fmt(INV[[as.character(v)]], 2)))
  cat(sprintf("BKT-vaikutus (M€):   Alhainen %s | Keskimmäinen %s | Korkea %s\n",
              fmt(bkt[1]), fmt(bkt[2]), fmt(bkt[3])))
  cat(sprintf("Verotulot yht. (M€): Alhainen %s | Keskimmäinen %s | Korkea %s\n",
              fmt(verot[1], 1), fmt(verot[2], 1), fmt(verot[3], 1)))
}

# =============================================================================
# 5. KUVIOT
# =============================================================================
TEEMA <- theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    plot.caption = element_text(hjust = 0, color = "#555555"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "right"
  )

tallenna <- function(nimi, kuvio, leveys = 9, korkeus = 6) {
  polku <- file.path(KANSIO, nimi)
  ggsave(polku, kuvio, width = leveys, height = korkeus, dpi = 150, bg = "white", device = png, type = "cairo")
  cat(sprintf("Kuvio tallennettu: %s\n", polku))
}

# --- Kuvio 1: Investointilajit vuosittain (keskimmäinen skenaario) ---------
il_df <- bind_rows(lapply(VUODET, function(v) {
  il <- investointilajit[[as.character(v)]]
  data.frame(
    Vuosi = factor(v, levels = VUODET),
    Laji = factor(
      c("Koneet, laitteet, kuljetusvälineet", "Muut talorakennukset kuin asuinrak.", "Maa ja vesi"),
      levels = c("Maa ja vesi", "Muut talorakennukset kuin asuinrak.", "Koneet, laitteet, kuljetusvälineet")
    ),
    Mrd = c(il$koneet_laitteet["Keskimmäinen"], il$muut_talorak["Keskimmäinen"], il$maa_ja_vesi["Keskimmäinen"])
  )
}))
il_yhteensa <- il_df %>% group_by(Vuosi) %>% summarise(Yht = sum(Mrd), .groups = "drop")

kuvio1 <- ggplot(il_df, aes(x = Vuosi, y = Mrd, fill = Laji)) +
  geom_col(width = 0.6, color = "white", linewidth = 0.3) +
  geom_text(aes(label = fmt(Mrd, 1)), position = position_stack(vjust = 0.5),
            color = "white", size = 3.5, fontface = "bold") +
  geom_text(data = il_yhteensa, aes(x = Vuosi, y = Yht, label = sprintf("Yhteensä %s mrd. €", fmt(Yht, 1))),
            inherit.aes = FALSE, vjust = -0.6, fontface = "bold", size = 4) +
  scale_fill_manual(values = c(
    "Maa ja vesi" = "#c6dbef",
    "Muut talorakennukset kuin asuinrak." = "#6baed6",
    "Koneet, laitteet, kuljetusvälineet" = "#08519c"
  ), name = "Investointilaji") +
  scale_y_continuous(labels = label_number(suffix = " mrd. €", decimal.mark = ","),
                      expand = expansion(mult = c(0, 0.12))) +
  labs(
    title = "Datakeskusinvestointien jakautuminen investointilajeihin",
    subtitle = "Keskimmäinen skenaario - T&K-investoinnit ja asejärjestelmät: 0",
    x = "Valmistumisvuosi", y = "Investointi (mrd. €)",
    caption = "Lähde: Dataikkuna (xlsx) + Datakeskusten_vaikutus_Suomen_talouteenV3 (docx)"
  ) +
  TEEMA
tallenna("datakeskus_investointilajit_2027_2028.png", kuvio1, leveys = 9.5)

# --- Kuvio 2: BKT-vaikutus vuosittain, skenaarioiden vaihteluväli ----------
bkt_df <- bind_rows(lapply(VUODET, function(v) {
  t <- tulokset[[as.character(v)]]
  data.frame(
    Vuosi = factor(v, levels = VUODET),
    Alhainen = t$Alhainen$bkt_rak / 1000,
    Keskimmäinen = t$Keskimmäinen$bkt_rak / 1000,
    Korkea = t$Korkea$bkt_rak / 1000
  )
}))

kuvio2 <- ggplot(bkt_df, aes(x = Vuosi, y = Keskimmäinen)) +
  geom_col(width = 0.5, fill = "#08519c") +
  geom_errorbar(aes(ymin = Alhainen, ymax = Korkea), width = 0.15, linewidth = 0.8, color = "#333333") +
  geom_text(aes(label = sprintf("%s mrd. €", fmt(Keskimmäinen, 2))), vjust = -1.6, fontface = "bold", size = 4) +
  geom_text(aes(y = Korkea, label = sprintf("(%s-%s)", fmt(Alhainen, 1), fmt(Korkea, 1))),
            vjust = -0.8, size = 3, color = "#555555") +
  scale_y_continuous(labels = label_number(suffix = " mrd. €", decimal.mark = ","),
                      expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "Datakeskusinvestointien BKT-vaikutus (rakennusvaihe)",
    subtitle = "Pylväs = keskimmäinen skenaario, jana = alhainen-korkea -vaihteluväli",
    x = "Valmistumisvuosi", y = "BKT-vaikutus (mrd. €)",
    caption = "Rakennusvaiheen kertaluonteinen vaikutus (I + C - M) - ei käyttövaiheen jatkuvia vaikutuksia.\nLähde: datakeskus_vaikutukset.R (Datakeskusten_vaikutus_Suomen_talouteenV3.docx)"
  ) +
  TEEMA
tallenna("datakeskus_bkt_vaikutus_2027_2028.png", kuvio2, leveys = 8.5)

# --- Kuvio 3: Verotulot vuosittain, valtio/kunnat, skenaarioiden vaihteluväli
vero_df <- bind_rows(lapply(VUODET, function(v) {
  t <- tulokset[[as.character(v)]]
  bind_rows(lapply(SKENAARIOT, function(s) {
    x <- t[[s]]
    valtio <- sum(x$vero_rak) - x$kunnat_rak
    kunnat <- x$kunnat_rak
    data.frame(Vuosi = v, Skenaario = s, Saaja = c("Valtio", "Kunnat"), Milj = c(valtio, kunnat))
  }))
}))
vero_df$Vuosi <- factor(vero_df$Vuosi, levels = VUODET)
vero_df$Saaja <- factor(vero_df$Saaja, levels = c("Kunnat", "Valtio"))

vero_keskimm <- vero_df %>% filter(Skenaario == "Keskimmäinen")
vero_ala_korkea <- vero_df %>%
  group_by(Vuosi, Skenaario) %>% summarise(Yht = sum(Milj), .groups = "drop") %>%
  tidyr::pivot_wider(names_from = Skenaario, values_from = Yht)
vero_keskimm_yht <- vero_keskimm %>% group_by(Vuosi) %>% summarise(Yht = sum(Milj), .groups = "drop") %>%
  left_join(vero_ala_korkea, by = "Vuosi")

kuvio3 <- ggplot(vero_keskimm, aes(x = Vuosi, y = Milj, fill = Saaja)) +
  geom_col(width = 0.5, color = "white", linewidth = 0.3) +
  geom_text(aes(label = fmt(Milj, 0)), position = position_stack(vjust = 0.5),
            color = "white", size = 3.5, fontface = "bold") +
  geom_errorbar(data = vero_keskimm_yht, aes(x = Vuosi, y = Yht, ymin = Alhainen, ymax = Korkea),
                inherit.aes = FALSE, width = 0.15, linewidth = 0.8, color = "#333333") +
  geom_text(data = vero_keskimm_yht, aes(x = Vuosi, y = Korkea, label = sprintf("Yht. %s M€ (%s-%s)",
            fmt(Yht, 0), fmt(Alhainen, 0), fmt(Korkea, 0))),
            inherit.aes = FALSE, vjust = -0.6, fontface = "bold", size = 3.3) +
  scale_fill_manual(values = c("Kunnat" = "#6baed6", "Valtio" = "#08306b"), name = "Saaja") +
  scale_y_continuous(labels = label_number(suffix = " M€", decimal.mark = ","),
                      expand = expansion(mult = c(0, 0.18))) +
  labs(
    title = "Datakeskusinvestointien julkisen talouden verotulot (rakennusvaihe)",
    subtitle = "Pylväät = keskimmäinen skenaario, jana = alhainen-korkea -vaihteluväli",
    x = "Valmistumisvuosi", y = "Verotulot (milj. €)",
    caption = "Rakennusvaiheen kertaluonteinen verotulo (yhteisövero, netto-ALV, tulovero, kiinteistövero) -\nei käyttövaiheen jatkuvaa sähköveroa ym. Lähde: datakeskus_vaikutukset.R"
  ) +
  TEEMA
tallenna("datakeskus_verotulot_2027_2028.png", kuvio3, leveys = 8.5)

cat("\nValmis. Kaikki kolme kuviota tallennettu skriptin kansioon.\n")
