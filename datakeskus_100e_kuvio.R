# Mita 100 euron datakeskusinvestoinnista jaa Suomeen?
#
# Yksinkertainen, yleistajuinen kuvio Taloudellisen katsauksen boksiin:
# jakaa 100 euron rakennusvaiheen investoinnin kotimaiseen (jaa Suomeen)
# ja tuotuun (ei kasvata Suomen BKT:ta) osaan, keskimmaisessa skenaariossa.
# Tyontekijoiden palkoista syntyva nettokulutus (lisaa viela n. 1,9 e)
# esitetaan erillisena lisahuomiona, koska se on investoinnista erillista,
# palkkojen synnyttamaa lisavaikutusta, ei osa samasta 100 eurosta.
#
# Kaytto:
#   Rscript datakeskus_100e_kuvio.R
#
# Riippuvuudet: ggplot2, scales
#   install.packages(c("ggplot2", "scales"))

alkuperainen_onnistui <- suppressWarnings(Sys.setlocale("LC_ALL", "C.utf8"))
if (isFALSE(alkuperainen_onnistui)) {
  varalla_onnistui <- suppressWarnings(Sys.setlocale("LC_ALL", "en_US.UTF-8"))
  if (isFALSE(varalla_onnistui)) {
    warning("UTF-8-lokaalia (C.utf8 / en_US.UTF-8) ei loytynyt - skandimerkit ja eurosymboli saattavat nakya puutteellisina kuviossa.")
  }
}

library(ggplot2)
library(scales)

skriptin_kansio <- function() {
  args <- commandArgs(trailingOnly = FALSE)
  polku <- sub("^--file=", "", args[grepl("^--file=", args)])
  if (length(polku) == 1) dirname(normalizePath(polku)) else "."
}

options(datakeskus.vain_funktiot = TRUE)
source(file.path(skriptin_kansio(), "datakeskus_vaikutukset.R"))

# Keskimmainen skenaario (s = 2), 100 M e = suhteutettuna 100 e:oon
p <- P
p$rakennusvuodet <- 1
t <- laske(0.1, 2, p)

kotim_inv   <- t$I - t$M_inv            # kotimainen rakennus-/asennustyo
tuonti_inv  <- t$M_inv                  # tuotu IT-laitteisto ym.
nettokulutus <- t$C_rak - t$M_C_rak     # tyontekijoiden kulutuksen nettovaikutus (lisa)
tuonti_kulutus <- t$M_C_rak             # kulutuksen tuontisisalto (lisan vuotava osa)
yhteensa    <- t$bkt_rak                # kotim_inv + nettokulutus

data <- data.frame(
  osa = factor(
    c("Tuotu IT-/palvelininfrastruktuuri\n(ei kasvata Suomen BKT:tä)",
      "Kotimainen rakennus- ja asennustyö\n(jää Suomeen)"),
    levels = c("Tuotu IT-/palvelininfrastruktuuri\n(ei kasvata Suomen BKT:tä)",
               "Kotimainen rakennus- ja asennustyö\n(jää Suomeen)")
  ),
  maara = c(tuonti_inv, kotim_inv),
  y = "100 € investointi"
)

varit <- c(
  "Tuotu IT-/palvelininfrastruktuuri\n(ei kasvata Suomen BKT:tä)" = "#c6dbef",
  "Kotimainen rakennus- ja asennustyö\n(jää Suomeen)" = "#08306b"
)

TEKSTI <- "#1a1a1a"
TEKSTI2 <- "#52514e"

kuvio <- ggplot(data, aes(x = y, y = maara, fill = osa)) +
  geom_col(width = 0.5, color = "white", linewidth = 0.4) +
  geom_text(
    aes(label = sprintf("%.0f €", maara)),
    position = position_stack(vjust = 0.5),
    color = c("#1a1a1a", "white"), size = 5, fontface = "bold"
  ) +
  coord_flip() +
  scale_fill_manual(values = varit, name = NULL) +
  scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
  labs(
    title = "Mitä 100 euron datakeskusinvestoinnista jää Suomeen?",
    subtitle = "Rakennusvaihe, keskimmäinen skenaario",
    x = NULL, y = NULL,
    caption = sprintf(
      paste0(
        "Lisäksi työntekijöiden palkoista syntyvä kulutus tuo Suomeen vielä noin %.1f €\n",
        "(ja %.1f € valuu tuontina) - yhteensä Suomeen jää noin %.1f € / 100 € investoinnista.\n",
        "Lähde: datakeskus_vaikutukset.R (Datakeskusten_vaikutus_Suomen_talouteenV3.docx)"
      ),
      nettokulutus, tuonti_kulutus, yhteensa
    )
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", color = TEKSTI),
    plot.subtitle = element_text(color = TEKSTI2),
    plot.caption = element_text(hjust = 0, color = TEKSTI2, size = 10, lineheight = 1.2,
                                margin = margin(t = 14)),
    axis.text.y = element_text(size = 13, color = TEKSTI),
    axis.text.x = element_blank(),
    panel.grid = element_blank(),
    legend.position = "bottom",
    legend.text = element_text(size = 10),
    plot.margin = margin(t = 10, r = 20, b = 10, l = 10)
  ) +
  guides(fill = guide_legend(reverse = TRUE, nrow = 2))

print(kuvio)

ulostulo <- file.path(skriptin_kansio(), "datakeskus_100e_kuvio.png")
ggsave(ulostulo, kuvio, width = 8.5, height = 4.5, dpi = 150, bg = "white", device = png, type = "cairo")
cat(sprintf("\nKuvio tallennettu: %s\n", ulostulo))
cat(sprintf("Kotimainen rakennustyo: %.2f e, Tuotu IT-laitteisto: %.2f e\n", kotim_inv, tuonti_inv))
cat(sprintf("Nettokulutus (lisa): %.2f e, Kulutuksen tuontisisalto: %.2f e\n", nettokulutus, tuonti_kulutus))
cat(sprintf("Yhteensa Suomeen jaava BKT-vaikutus: %.2f e / 100 e\n", yhteensa))
