# Datakeskusinvestoinnit 2027-2028 vaiheittain
#
# Lukee Dataikkuna_2_11_2026_imputoitu_claude.xlsx:n Taul1-valilehden,
# suodattaa Teema == "Datakeskus" ja Valmistuminen %in% c(2027, 2028), ja
# piirtaa pylvaskuvion, jossa kunkin vuoden investointisumma (mrd. e) on
# jaettu hankkeen Vaihe-sarakkeen mukaisiin osiin (pinottu pylvaskuvio).
#
# Kaytto:
#   Rscript datakeskus_investoinnit_vaiheittain.R
# tai RStudiossa: source("datakeskus_investoinnit_vaiheittain.R")
#
# Riippuvuudet: readxl, dplyr, ggplot2, scales
#   install.packages(c("readxl", "dplyr", "ggplot2", "scales"))

# HUOM lokaalista: monet R-ajoymparistot kaynnistyvat C-lokaalissa, jossa
# skandimerkkien (a/o) ja euro-merkin vertailu ja PIIRTAMINEN ei toimi
# luotettavasti - merkit voivat nakya pisteina kuviossa tai merkkijono-
# vertailut (==, factor()) voivat palauttaa vaaria tuloksia ilman
# virheilmoitusta. "C.utf8"-lokaali korjaa taman (Windowsilla tama
# todennakoisesti ei ole edes tarpeen, mutta ei haittaa - jos kumpikaan
# lokaali ei loydy, skripti vain varoittaa eika kaadu).
alkuperainen_onnistui <- suppressWarnings(Sys.setlocale("LC_ALL", "C.utf8"))
if (isFALSE(alkuperainen_onnistui)) {
  varalla_onnistui <- suppressWarnings(Sys.setlocale("LC_ALL", "en_US.UTF-8"))
  if (isFALSE(varalla_onnistui)) {
    warning("UTF-8-lokaalia (C.utf8 / en_US.UTF-8) ei loytynyt - skandimerkit ja eurosymboli saattavat nakya puutteellisina kuviossa.")
  }
}

library(readxl)
library(dplyr)
library(ggplot2)
library(scales)

skriptin_kansio <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  polku <- sub("^--file=", "", args[grepl("^--file=", args)])
  if (length(polku) == 1) dirname(normalizePath(polku)) else "."
}

tiedosto <- file.path(skriptin_kansio(), "Dataikkuna_2_11_2026_imputoitu_claude.xlsx")
data <- read_excel(tiedosto, sheet = "Taul1")

# Aineistossa esiintyy sama vaihe eri kirjainkoolla ("3. Käynnistys" ja
# "3. käynnistys") - yhdenmukaistetaan nämä yhdeksi luokaksi.
data$Vaihe[tolower(data$Vaihe) == "3. käynnistys"] <- "3. Käynnistys"

vaihe_jarjestys <- c(
  "0. Esiselvitys",
  "1. Suunnittelu",
  "2. Investointipäätös",
  "3. Käynnistys",
  "4. Valmis",
  "5. Keskeytetty"
)

datakeskukset_2027_2028 <- data %>%
  filter(Teema == "Datakeskus", Valmistuminen %in% c(2027, 2028)) %>%
  mutate(
    Vaihe = factor(Vaihe, levels = vaihe_jarjestys),
    Valmistuminen = factor(Valmistuminen, levels = c(2027, 2028))
  )

yhteenveto <- datakeskukset_2027_2028 %>%
  group_by(Valmistuminen, Vaihe, .drop = FALSE) %>%
  summarise(Investointi_mrd = sum(`Summa (M€)`, na.rm = TRUE) / 1000, .groups = "drop") %>%
  filter(Investointi_mrd > 0)

cat("Investoinnit vaiheittain (mrd. e):\n")
print(yhteenveto)

vuosisummat <- yhteenveto %>%
  group_by(Valmistuminen) %>%
  summarise(Yhteensa = sum(Investointi_mrd), .groups = "drop")
cat("\nVuosisummat (mrd. e):\n")
print(vuosisummat)

# Sininen, suunnitteluasteen mukaan tummeneva vari-ilme: mita pidemmalla
# hanke on, sita tummempi/varmempi vari.
vaihe_varit <- c(
  "0. Esiselvitys"        = "#c6dbef",
  "1. Suunnittelu"        = "#6baed6",
  "2. Investointipäätös"  = "#08519c",
  "3. Käynnistys"         = "#08306b",
  "4. Valmis"             = "#041a36",
  "5. Keskeytetty"        = "#969696"
)

kuvio <- ggplot(yhteenveto, aes(x = Valmistuminen, y = Investointi_mrd, fill = Vaihe)) +
  geom_col(width = 0.6, color = "white", linewidth = 0.3) +
  geom_text(
    aes(label = sprintf("%.1f", Investointi_mrd)),
    position = position_stack(vjust = 0.5),
    color = "white", size = 3.5, fontface = "bold"
  ) +
  geom_text(
    data = vuosisummat,
    aes(x = Valmistuminen, y = Yhteensa, label = sprintf("Yhteensä %.1f mrd. €", Yhteensa)),
    inherit.aes = FALSE, vjust = -0.6, fontface = "bold", size = 4
  ) +
  scale_fill_manual(values = vaihe_varit, drop = TRUE, name = "Hankkeen vaihe") +
  scale_y_continuous(
    labels = label_number(suffix = " mrd. €", decimal.mark = ","),
    expand = expansion(mult = c(0, 0.12))
  ) +
  labs(
    title = "Suomen datakeskusinvestoinnit valmistumisvuoden ja vaiheen mukaan",
    subtitle = "Ilmoitetut ja imputoidut hankkeet, valmistuminen 2027-2028",
    x = "Valmistumisvuosi",
    y = "Investointi (mrd. €)",
    caption = "Lähde: Dataikkuna_2_11_2026_imputoitu_claude.xlsx (Taul1)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "right"
  )

print(kuvio)

ulostulo <- file.path(skriptin_kansio(), "datakeskus_investoinnit_vaiheittain.png")
ggsave(ulostulo, kuvio, width = 9.5, height = 6, dpi = 150, bg = "white", device = png, type = "cairo")
cat(sprintf("\nKuvio tallennettu: %s\n", ulostulo))