# =============================================================================
# Shiny-sovellus: datakeskusinvestoinnin vaikutukset Suomen talouteen
#
# Laskenta tulee tiedostosta datakeskus_vaikutukset.R (sama malli kuin
# komentoriviversiossa). Paikallinen ajo repositorion juuresta:
#   shiny::runApp("app")
# =============================================================================

library(shiny)
library(bslib)

# Ladataan laskentamalli ilman komentorivin kysymyksiä. Julkaisussa tiedosto
# kopioidaan app-kansioon, paikallisesti se luetaan repositorion juuresta.
options(datakeskus.vain_funktiot = TRUE)
malli <- if (file.exists("datakeskus_vaikutukset.R")) {
  "datakeskus_vaikutukset.R"
} else {
  "../datakeskus_vaikutukset.R"
}
source(malli, encoding = "UTF-8", local = TRUE)

# Sarjojen värit (alhainen, keskimmäinen, korkea) ja tekstin sävyt
VARIT <- c("#2a78d6", "#eb6834", "#1baf7a")
TEKSTI <- "#0b0b0b"
TEKSTI2 <- "#52514e"
RUUDUKKO <- "#e4e3df"

# -----------------------------------------------------------------------------
# Muokattavat parametrit
# skaala = kerroin syötteestä malliin (prosentit -> osuus)
# -----------------------------------------------------------------------------
SKENAARIOPARAMETRIT <- list(
  kotimainen_osuus  = list(nimi = "Kotimainen osuus investoinnista (%)", skaala = 0.01, askel = 1),
  kayttoaste        = list(nimi = "Käyttöaste (%)", skaala = 0.01, askel = 1),
  sahkon_hinta      = list(nimi = "Sähkön hinta + siirto (€/MWh)", skaala = 1, askel = 5),
  voittolisa        = list(nimi = "Siirtohinnoittelun voittolisä (%)", skaala = 0.01, askel = 0.5),
  tuontisahko_osuus = list(nimi = "Tuontisähkön osuus (%) [O]", skaala = 0.01, askel = 1)
)
YKSITTAISPARAMETRIT <- list(
  sahkovero             = list(nimi = "Sähkövero (€/MWh)", skaala = 1, askel = 0.01),
  kulutus_tuontisisalto = list(nimi = "Kulutuksen tuontisisältö (%) [O]", skaala = 0.01, askel = 1),
  yhteisoveroaste       = list(nimi = "Yhteisöveroaste (%)", skaala = 0.01, askel = 1),
  bkt_taso              = list(nimi = "Suomen BKT (M€) [O]", skaala = 1, askel = 1000),
  tyolliset             = list(nimi = "Työllisten määrä [O]", skaala = 1, askel = 10000)
)

oletusarvo <- function(nimi, skaala) round(P[[nimi]] / skaala, 2)

skenaariosyote <- function(nimi, maar) {
  arvot <- oletusarvo(nimi, maar$skaala)
  tagList(
    tags$label(maar$nimi, class = "form-label small fw-semibold"),
    do.call(layout_columns, c(
      list(col_widths = c(4, 4, 4), gap = "0.4rem"),
      lapply(1:3, function(s) {
        numericInput(paste0(nimi, "_", s), SKENAARIOT[s], value = arvot[s],
                     step = maar$askel, min = 0)
      })
    ))
  )
}

# -----------------------------------------------------------------------------
# Käyttöliittymä
# -----------------------------------------------------------------------------
ui <- page_sidebar(
  title = "Datakeskusinvestoinnin vaikutukset Suomen talouteen",
  theme = bs_theme(version = 5, primary = "#2a78d6", base_font = font_collection(
    "system-ui", "-apple-system", "Segoe UI", "Roboto", "sans-serif")),
  fillable = FALSE,
  tags$head(tags$style(HTML("
    .taulukko table { width: 100%; font-variant-numeric: tabular-nums; }
    .taulukko td:not(:first-child), .taulukko th:not(:first-child) { text-align: right; white-space: nowrap; }
    .taulukko tr.summa td { font-weight: 600; border-top: 1px solid #999; }
    .taulukko td.sisennys { padding-left: 1.5em; color: #52514e; }
    .vaihteluvali { font-size: 0.8rem; opacity: 0.85; }
    .form-group { margin-bottom: 0.5rem; }
  "))),

  sidebar = sidebar(
    width = 340,
    numericInput("investointi", "Investoinnin suuruus (mrd. €)", value = 1,
                 min = 0.01, step = 0.1),
    sliderInput("rakennusvuodet", "Rakennusaika (vuotta)", min = 1, max = 8,
                value = P$rakennusvuodet, step = 1),
    sliderInput("kayttovuodet", "Käyttövuodet kumulatiivisessa tarkastelussa",
                min = 1, max = 30, value = P$kayttovuodet, step = 1),
    accordion(
      open = FALSE,
      accordion_panel(
        "Skenaarioparametrit",
        lapply(names(SKENAARIOPARAMETRIT), function(n) skenaariosyote(n, SKENAARIOPARAMETRIT[[n]]))
      ),
      accordion_panel(
        "Muut parametrit",
        lapply(names(YKSITTAISPARAMETRIT), function(n) {
          m <- YKSITTAISPARAMETRIT[[n]]
          numericInput(n, m$nimi, value = oletusarvo(n, m$skaala)[1], step = m$askel, min = 0)
        })
      )
    ),
    actionButton("palauta", "Palauta oletusarvot", class = "btn-outline-secondary btn-sm"),
    downloadButton("lataa", "Lataa tulokset (CSV)", class = "btn-sm"),
    tags$p(class = "small text-muted mt-2",
           "[O] = laskelman oma oletus, muut arvot muistiosta ",
           tags$em("Datakeskusten vaikutus Suomen talouteen"), " (9/2026).")
  ),

  uiOutput("otsikkotieto"),
  uiOutput("tunnusluvut"),

  layout_columns(
    col_widths = c(7, 5),
    card(
      card_header("BKT-vaikutus vuosittain (M€)"),
      plotOutput("bkt_kuva", height = "320px"),
      card_footer(class = "small text-muted",
                  "Rakennusvaiheen vaikutus on jaettu tasan rakennusvuosille; käyttövaihe alkaa rakentamisen jälkeen.")
    ),
    card(
      card_header("Verotulot käyttövaiheessa (M€ / vuosi, keskimmäinen)"),
      plotOutput("vero_kuva", height = "320px")
    )
  ),

  do.call(layout_columns, c(
    list(col_widths = c(6, 6)),
    lapply(1:6, function(i) {
      card(card_header(textOutput(paste0("otsikko_", i), inline = TRUE)),
           div(class = "taulukko", uiOutput(paste0("taulukko_", i))))
    })
  )),

  card(
    card_header("Vertailu Rambollin bruttolukuihin ja huomioita"),
    uiOutput("huomiot")
  )
)

# -----------------------------------------------------------------------------
# Palvelinlogiikka
# -----------------------------------------------------------------------------
html_taulukko <- function(rivit) {
  summarivit <- c("BKT-vaikutus yhteensä", "BKT-vaikutus / vuosi", "Yhteensä",
                  "Verotulot yhteensä", "Rakennusvaihe yhteensä", "Käyttövaihe / vuosi")
  tags$table(
    class = "table table-sm mb-0",
    tags$thead(tags$tr(tags$th(""), lapply(SKENAARIOT, tags$th))),
    tags$tbody(lapply(names(rivit), function(n) {
      sisennys <- startsWith(n, "  ")
      tags$tr(class = if (n %in% summarivit) "summa",
              tags$td(trimws(n), class = if (sisennys) "sisennys"),
              lapply(rivit[[n]], tags$td))
    }))
  )
}

server <- function(input, output, session) {

  parametrit <- reactive({
    p <- P
    for (n in names(SKENAARIOPARAMETRIT)) {
      arvot <- sapply(1:3, function(s) input[[paste0(n, "_", s)]])
      if (length(arvot) == 3 && all(!is.na(unlist(arvot)))) {
        p[[n]] <- unlist(arvot) * SKENAARIOPARAMETRIT[[n]]$skaala
      }
    }
    for (n in names(YKSITTAISPARAMETRIT)) {
      a <- input[[n]]
      if (!is.null(a) && !is.na(a)) {
        p[[n]] <- rep_len(a * YKSITTAISPARAMETRIT[[n]]$skaala, length(P[[n]]))
      }
    }
    p$rakennusvuodet <- input$rakennusvuodet
    p$kayttovuodet <- input$kayttovuodet
    p
  })

  tulos <- reactive({
    validate(need(!is.na(input$investointi) && input$investointi > 0,
                  "Anna investoinnin suuruus positiivisena lukuna (mrd. €)."))
    p <- parametrit()
    c(tulostaulukot(input$investointi, p), list(p = p, inv = input$investointi))
  })

  observeEvent(input$palauta, {
    for (n in names(SKENAARIOPARAMETRIT)) {
      arvot <- oletusarvo(n, SKENAARIOPARAMETRIT[[n]]$skaala)
      for (s in 1:3) updateNumericInput(session, paste0(n, "_", s), value = arvot[s])
    }
    for (n in names(YKSITTAISPARAMETRIT)) {
      updateNumericInput(session, n, value = oletusarvo(n, YKSITTAISPARAMETRIT[[n]]$skaala)[1])
    }
    updateSliderInput(session, "rakennusvuodet", value = P$rakennusvuodet)
    updateSliderInput(session, "kayttovuodet", value = P$kayttovuodet)
  })

  output$otsikkotieto <- renderUI({
    r <- tulos(); m <- r$t[[2]]
    tags$p(class = "text-muted mb-2",
           sprintf("Investointi %s mrd. € · rakennusaika %d v · sähköteho %s MW · sähkönkulutus %s TWh/v (keskimmäinen skenaario)",
                   fmt(r$inv, 2), r$p$rakennusvuodet, fmt(m$mw), fmt(m$sahko_twh, 2)))
  })

  output$tunnusluvut <- renderUI({
    r <- tulos(); t <- r$t
    laatikko <- function(otsikko, f, yksikko, des = 0) {
      arvot <- sapply(t, f)
      value_box(
        title = otsikko, max_height = "150px",
        value = paste(fmt(arvot[2], des), yksikko),
        tags$span(class = "vaihteluvali",
                  if (diff(range(arvot)) > 0) {
                    sprintf("Vaihteluväli %s–%s", fmt(min(arvot), des), fmt(max(arvot), des))
                  } else "Sama kaikissa skenaarioissa")
      )
    }
    layout_column_wrap(
      width = "200px", fill = FALSE, class = "mb-3",
      laatikko("BKT, rakennusvaihe / vuosi", function(x) x$bkt_rak_v, "M€"),
      laatikko("BKT, käyttövaihe / vuosi", function(x) x$bkt_kaytto, "M€"),
      laatikko("Työllisyys, rakennusvaihe", function(x) x$rak_htv, "htv"),
      laatikko("Työllisyys, käyttövaihe / vuosi", function(x) x$kaytto_htv, "htv"),
      laatikko("Verotulot, rakennusvaihe", function(x) sum(x$vero_rak), "M€"),
      laatikko("Verotulot, käyttövaihe / vuosi", function(x) sum(x$vero_kaytto), "M€")
    )
  })

  output$bkt_kuva <- renderPlot({
    r <- tulos(); v <- r$p$rakennusvuodet; ky <- r$p$kayttovuodet
    vuodet <- seq_len(v + ky)
    sarjat <- lapply(r$t, function(x) c(rep(x$bkt_rak_v, v), rep(x$bkt_kaytto, ky)))
    ymax <- max(unlist(sarjat)) * 1.1

    par(mar = c(3.5, 4.5, 1, 7), family = "sans", col.axis = TEKSTI2, fg = TEKSTI2)
    plot(NA, xlim = c(0.5, max(vuodet) + 0.5), ylim = c(0, ymax), axes = FALSE,
         xlab = "", ylab = "", xaxs = "i", yaxs = "i")
    akseli <- pretty(c(0, ymax))
    abline(h = akseli, col = RUUDUKKO, lwd = 1)
    axis(2, at = akseli, labels = fmt(akseli), las = 1, lwd = 0, cex.axis = 0.85)
    axis(1, at = vuodet, lwd = 0, cex.axis = 0.85, padj = -0.5)
    mtext("Vuosi investoinnin alusta", side = 1, line = 2.2, col = TEKSTI2, cex = 0.85)
    abline(v = v + 0.5, lty = 2, col = TEKSTI2)
    text(v + 0.5, ymax * 0.03, " Käyttövaihe alkaa", adj = c(0, 0), col = TEKSTI2, cex = 0.8)
    for (s in 3:1) {
      lines(vuodet, sarjat[[s]], type = "s", col = VARIT[s], lwd = 2.5)
      points(vuodet, sarjat[[s]], pch = 21, bg = VARIT[s], col = "white", cex = 1.1)
    }
    # Suorat nimilaput oikeaan reunaan, limittäiset erotetaan toisistaan
    loppu <- sapply(sarjat, function(x) tail(x, 1))
    y <- loppu; jarj <- order(y); vali <- ymax * 0.07
    for (i in 2:3) {
      if (y[jarj[i]] - y[jarj[i - 1]] < vali) y[jarj[i]] <- y[jarj[i - 1]] + vali
    }
    par(xpd = TRUE)
    for (s in 1:3) text(max(vuodet) + 0.7, y[s], SKENAARIOT[s], adj = 0, col = TEKSTI, cex = 0.85)
  }, res = 110)

  output$vero_kuva <- renderPlot({
    r <- tulos(); vero <- r$t[[2]]$vero_kaytto
    nimet <- c(Yhteisovero = "Yhteisövero", ALV_netto = "ALV (netto)", Tulovero = "Tulovero",
               Kiinteistovero = "Kiinteistövero", Sahkovero = "Sähkövero")
    jarj <- order(vero)
    arvot <- vero[jarj]
    xmax <- max(arvot) * 1.25

    par(mar = c(2, 8, 1, 1), family = "sans", col.axis = TEKSTI2, fg = TEKSTI2)
    plot(NA, xlim = c(0, xmax), ylim = c(0.4, length(arvot) + 0.6), axes = FALSE,
         xlab = "", ylab = "", xaxs = "i")
    akseli <- pretty(c(0, xmax))
    abline(v = akseli, col = RUUDUKKO)
    axis(1, at = akseli, labels = fmt(akseli), lwd = 0, cex.axis = 0.85, padj = -0.5)
    rect(0, seq_along(arvot) - 0.32, arvot, seq_along(arvot) + 0.32, col = VARIT[1], border = NA)
    axis(2, at = seq_along(arvot), labels = nimet[names(arvot)], las = 1, lwd = 0,
         cex.axis = 0.9, col.axis = TEKSTI)
    text(arvot, seq_along(arvot), paste0(" ", fmt(arvot, 1)), adj = 0, col = TEKSTI, cex = 0.85)
  }, res = 110)

  lapply(1:6, function(i) {
    output[[paste0("otsikko_", i)]] <- renderText(tulos()$taulukot[[i]]$otsikko)
    output[[paste0("taulukko_", i)]] <- renderUI(html_taulukko(tulos()$taulukot[[i]]$rivit))
  })

  output$huomiot <- renderUI({
    r <- tulos(); m <- r$t[[2]]
    tagList(
      tags$p(sprintf("Rakennusvaiheen verotulot: Ramboll %s M€, tämä laskelma %s M€. ",
                     fmt(RAMBOLL$verotulot * r$inv), fmt(sum(m$vero_rak))),
             sprintf("Käyttövaiheen liikevaihto: Ramboll %s M€/v, Suomeen kirjautuva palveluvienti %s M€/v.",
                     fmt(RAMBOLL$liikevaihto * r$inv), fmt(m$X)),
             "Ero johtuu siitä, ettei tämä laskelma huomioi ALV-palautuksia bruttona ja siirtohinnoittelun vuoksi Suomen tytäryhtiölle kirjautuu vain kulut + voittolisä."),
      tags$ul(
        tags$li("Sähkövero on käyttövaiheen suurin verotulo. Jos datakeskukset verotetaan alemmassa sähköveroluokassa, muuta sähköveron arvoa kohdassa Muut parametrit."),
        tags$li("ALV-palautukset eivät ole valtion tappio, sillä ne palauttavat jo tilitetyn veron; laskelmassa käytetään netto-ALV:tä."),
        tags$li("Kantaverkon vahvistuskustannuksia (Fingrid) ja sähkön hintavaikutusta kotitalouksien kulutukseen ei ole kvantifioitu."),
        tags$li("Laitteiston uusimisinvestoinnit (3–5 v sykli) ovat lähes kokonaan tuontia, eikä niitä ole otettu BKT-vaikutukseen mukaan."),
        tags$li("Muistion 12 mrd. € luvut skaalataan lineaarisesti; pienissä hankkeissa mittakaavaedut ja kiinteät kustannukset voivat muuttaa suhdelukuja.")
      )
    )
  })

  output$lataa <- downloadHandler(
    filename = function() sprintf("datakeskus_vaikutukset_%s_mrd.csv", format(input$investointi)),
    content = function(file) {
      r <- tulos()
      rivit <- do.call(rbind, lapply(r$taulukot, function(tb) {
        do.call(rbind, lapply(names(tb$rivit), function(n) {
          data.frame(taulukko = tb$otsikko, rivi = trimws(n),
                     t(setNames(tb$rivit[[n]], SKENAARIOT)), check.names = FALSE)
        }))
      }))
      write.csv2(rivit, file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  )
}

shinyApp(ui, server)
