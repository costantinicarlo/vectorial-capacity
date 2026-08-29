# Vectorial Capacity & Reproduction Number Explorer
# Classical Garrett-Jones / Ross-Macdonald educational model.
#
#   C = m * a^2 * p^n / mu
#   R = C * b * c * D
#   HBR = m * a
#   mu = -ln(p)
#
# `a` is the human blood-feeding rate per mosquito per day; it is not HBR.
# The generic symbol R is used because intervention and immunity-inspired
# scenarios are not all valid interpretations of the basic reproduction number R0.

library(shiny)

ui <- fluidPage(
  withMathJax(),
  tags$head(
    tags$style(HTML("\
      .scenario-button {\
        white-space: normal;\
        height: auto;\
        min-height: 3.4em;\
        line-height: 1.2;\
        margin-bottom: 0.65em;\
        padding-left: 0.5em;\
        padding-right: 0.5em;\
      }\
      .app-footer {\
        color: #666;\
        font-size: 0.9em;\
        margin: 1.5em 0 1em;\
        text-align: center;\
      }\
      .citation {\
        background: #f7f7f7;\
        border-left: 4px solid #bbb;\
        margin: 0.75em 0;\
        padding: 0.8em 1em;\
      }\
    "))
  ),
  titlePanel("Vectorial Capacity & Reproduction Number Explorer"),

  sidebarLayout(
    sidebarPanel(
      h4("Vector & parasite parameters"),
      sliderInput(
        "p", HTML("Daily mosquito survival probability, \\(p\\)"),
        min = 0.5, max = 0.99, value = 0.8, step = 0.01
      ),
      sliderInput(
        "h", HTML(paste0(
          "Effective probability of a human blood meal per ",
          "gonotrophic cycle, \\(h\\)"
        )),
        min = 0, max = 1, value = 0.5, step = 0.05
      ),
      sliderInput(
        "g", HTML("Gonotrophic-cycle duration, \\(g\\) (days)"),
        min = 1, max = 6, value = 2.5, step = 0.5
      ),
      sliderInput(
        "n", HTML("Parasite extrinsic incubation period, \\(n\\) (days)"),
        min = 8, max = 50, value = 12, step = 1
      ),
      hr(),
      h4("Human & infection parameters"),
      sliderInput(
        "D", HTML(paste0(
          "Effective duration of human infectiousness to mosquitoes, ",
          "\\(D\\) (days)"
        )),
        min = 0, max = 200, value = 80, step = 5
      ),
      sliderInput(
        "b", HTML(paste0(
          "Probability of mosquito → human infection per infectious bite, ",
          "\\(b\\)"
        )),
        min = 0, max = 1, value = 0.3, step = 0.05
      ),
      sliderInput(
        "c", HTML(paste0(
          "Probability of human → mosquito infection per bite, ",
          "\\(c\\)"
        )),
        min = 0, max = 1, value = 0.5, step = 0.05
      ),
      hr(),
      h4("Current scenario"),
      sliderInput(
        "m_current", HTML(paste0(
          "Current adult mosquito density, \\(m\\) ",
          "(mosquitoes per human)"
        )),
        min = 0, max = 200, value = 10, step = 1
      ),
      hr(),
      h4("Illustrative presets"),
      p(tags$small(
        "Teaching examples only: parameter values are not empirical intervention-effect estimates."
      )),
      fluidRow(
        column(
          width = 6,
          actionButton(
            "preset_baseline", "Illustrative high transmission",
            class = "scenario-button", width = "100%"
          ),
          actionButton(
            "preset_suppression", "Vector-density suppression",
            class = "scenario-button", width = "100%"
          ),
          actionButton(
            "preset_immunity", "Host-immunity-inspired",
            class = "scenario-button", width = "100%"
          )
        ),
        column(
          width = 6,
          actionButton(
            "preset_irs", "IRS-inspired",
            class = "scenario-button", width = "100%"
          ),
          actionButton(
            "preset_llin", "LLIN-inspired",
            class = "scenario-button", width = "100%"
          )
        )
      )
    ),

    mainPanel(
      tabsetPanel(
        type = "tabs",

        tabPanel(
          "Instructions",
          br(),
          img(src = "Anopheles.jpg", width = 50, alt = "Anopheles mosquito"),
          h3("Overview"),
          p(
            "This educational explorer implements a deliberately classical Garrett-Jones / Ross-Macdonald framework for malaria transmission. It is a sensitivity tool, not a fitted transmission model."
          ),
          p(
            strong("Preset warning: "),
            "the five presets are illustrative teaching examples. They are not empirical estimates of LLIN, IRS, immunity, genetic-control, larval-control, or other intervention effects."
          ),

          h3("Vectorial capacity"),
          p("The classical vectorial-capacity expression used here is:"),
          "\\[C = \\frac{m a^2 p^n}{\\mu}\\]",
          tags$ul(
            tags$li(HTML("\\(m\\): adult mosquito density (mosquitoes per human)")),
            tags$li(HTML(paste0(
              "\\(a\\): human blood-feeding rate ",
              "(per mosquito per day)"
            ))),
            tags$li(HTML("\\(p\\): daily mosquito survival probability")),
            tags$li(HTML(paste0(
              "\\(n\\): parasite extrinsic incubation period (days)"
            ))),
            tags$li(HTML(paste0(
              "\\(\\mu = -\\ln(p)\\): constant mosquito mortality hazard ",
              "(day\\(^{-1}\\))"
            )))
          ),
          p(HTML(paste0(
            "Vectorial capacity has units of \\(\\mathrm{day}^{-1}\\) and ",
            "represents transmission potential generated by mosquitoes feeding ",
            "on a fully infectious human under the model assumptions. It is not ",
            "the entomological inoculation rate (EIR)."
          ))),

          h3("Human blood feeding and HBR"),
          "\\[a = \\frac{h}{g}, \\qquad \\mathrm{HBR} = m a\\]",
          p(HTML(paste0(
            "Here \\(a\\) is a per-mosquito human blood-feeding rate. The human ",
            "biting rate is \\(\\mathrm{HBR}=ma\\), in bites per human per day. ",
            "The derivation assumes one successful blood meal per gonotrophic ",
            "cycle and does not represent interrupted or repeated feeding attempts."
          ))),

          h3("Scenario reproduction number"),
          "\\[R = C \\, b \\, c \\, D\\]",
          p(HTML(paste0(
            "The app uses the generic symbol \\(R\\). Under an uncontrolled, ",
            "fully susceptible baseline this corresponds to the classical basic ",
            "reproduction number \\(R_0\\). Under control it is more appropriately ",
            "interpreted as a controlled or scenario reproduction number. The ",
            "host-immunity-inspired preset is phenomenological and should not be ",
            "interpreted as a dynamically modelled effective reproduction number."
          ))),
          h4("Threshold principle"),
          tags$ul(
            tags$li(HTML(
              "\\(R < 1\\): infections decline near the disease-free state"
            )),
            tags$li(HTML("\\(R = 1\\): critical transmission threshold")),
            tags$li(HTML(paste0(
              "\\(R > 1\\): sustained transmission is possible under the ",
              "model assumptions"
            )))
          ),
          p(HTML(paste0(
            "\\(R=1\\) is a critical threshold, not a general statement that ",
            "an endemic system is at equilibrium."
          ))),

          h3(HTML("Human infectiousness parameter \\(D\\)")),
          p(HTML(paste0(
            "\\(D\\) is the effective duration of human infectiousness to ",
            "mosquitoes. The default value of 80 days is retained as a historical ",
            "teaching value associated with classical Macdonald-era malaria theory; ",
            "it is not a universal contemporary estimate. Gametocyte carriage, ",
            "gametocyte density, and actual mosquito infectivity are distinct quantities."
          ))),

          h3("Vector mortality"),
          p(HTML(paste0(
            "The app assumes constant exponential mortality: ",
            "\\(S(t)=p^t\\) and \\(\\mu=-\\ln(p)\\). Real mosquito mortality ",
            "and competence may depend on age; the constant-hazard approximation ",
            "is retained because it is part of the classical framework explored here."
          ))),

          h3("References"),
          tags$ol(
            tags$li("Garrett-Jones, C. & Grab, B. (1964). Bull. World Health Organ. 31:71–86."),
            tags$li("Macdonald, G. (1955). Proc. R. Soc. Med. 48(4):295–302."),
            tags$li("Smith, D.L., et al. (2012). PLoS Pathog. 8(4):e1002588."),
            tags$li("Brady, O.J., et al. (2016). Trans. R. Soc. Trop. Med. Hyg. 110(2):107–117.")
          ),

          h3("Source code and citation"),
          p(
            "The source code is available from the ",
            tags$a(
              "Vectorial Capacity GitHub repository",
              href = "https://github.com/costantinicarlo/vectorial-capacity",
              target = "_blank",
              rel = "noopener noreferrer"
            ),
            "."
          ),
          p("If you use this application in your work, please cite it as:"),
          div(
            class = "citation",
            "Costantini, Carlo (2026). ",
            tags$em("Vectorial Capacity & Reproduction Number Explorer"),
            " (Version 1.0) [Shiny web application]. ",
            tags$a(
              "https://carlo-costantini.shinyapps.io/Vectorial_Capacity/",
              href = "https://carlo-costantini.shinyapps.io/Vectorial_Capacity/",
              target = "_blank",
              rel = "noopener noreferrer"
            ),
            ". Source code: ",
            tags$a(
              "https://github.com/costantinicarlo/vectorial-capacity",
              href = "https://github.com/costantinicarlo/vectorial-capacity",
              target = "_blank",
              rel = "noopener noreferrer"
            ),
            "."
          ),
          p(tags$small(
            "Please add the date on which you accessed the application. The app, ",
            "documentation, and original mosquito image are licensed under ",
            tags$a(
              "CC BY 4.0",
              href = "https://creativecommons.org/licenses/by/4.0/",
              target = "_blank",
              rel = "noopener noreferrer"
            ),
            "."
          ))
        ),

        tabPanel(
          "Vectorial Capacity & R",
          br(),
          img(src = "Anopheles.jpg", width = 50, alt = "Anopheles mosquito"),
          h3("Definition of vectorial capacity"),
          div(
            "The vectorial capacity of a malaria vector population is the expected rate of future potentially infectious bites generated by mosquitoes feeding on a fully infectious human, under the classical Garrett-Jones assumptions."
          ),
          em(
            "— adapted from Garrett-Jones & Grab (1964), Bull. World Health Organ. 31:71–86."
          ),
          br(),
          h3("Critical threshold and scenario reproduction number"),
          div(HTML(paste0(
            "The explorer calculates \\(R=CbcD\\). The condition \\(R=1\\) ",
            "is the critical threshold. When parameters describe an uncontrolled, ",
            "fully susceptible system, this corresponds to the classical \\(R_0\\). ",
            "Intervention and immunity-inspired presets should instead be interpreted ",
            "as controlled or scenario reproduction numbers."
          ))),
          fluidRow(
            column(
              width = 7,
              plotOutput("CPlot", height = "450px"),
              p(uiOutput("criticalM")),
              p(uiOutput("criticalHBR")),
              p(uiOutput("e"))
            ),
            column(
              width = 5,
              h4(HTML("Current \\(C\\), HBR, \\(R\\), and parameters")),
              p(uiOutput("C_current")),
              p(uiOutput("HBR_current")),
              p(uiOutput("R_current")),
              p(uiOutput("R_regime")),
              uiOutput("summaryTable")
            )
          )
        ),

        tabPanel(
          "Survivorship",
          br(),
          img(src = "Anopheles.jpg", width = 50, alt = "Anopheles mosquito"),
          h3("Vector survivorship under constant exponential mortality"),
          p(HTML(paste0(
            "This plot shows the probability that a mosquito survives \\(t\\) ",
            "days after emergence under \\(S(t)=p^t\\)."
          ))),
          plotOutput("Survivorship"),
          p(uiOutput("life_expect")),
          br(),
          h4("Interpretation"),
          tags$ul(
            tags$li(HTML(
              "The mortality hazard \\(\\mu=-\\ln(p)\\) is constant over time."
            )),
            tags$li("The model has no senescence or other age dependence."),
            tags$li(HTML(paste0(
              "The conditional remaining lifespan after any age is \\(1/\\mu\\) ",
              "because of the memoryless exponential model."
            ))),
            tags$li(
              "Real mosquitoes may show age-dependent mortality and transmission competence; those processes are outside this v1.0 model."
            )
          )
        )
      )
    )
  ),
  div(
    class = "app-footer",
    "Source: ",
    tags$a(
      "GitHub",
      href = "https://github.com/costantinicarlo/vectorial-capacity",
      target = "_blank",
      rel = "noopener noreferrer"
    ),
    " · © 2026 Carlo Costantini · ",
    tags$a(
      "CC BY 4.0",
      href = "https://creativecommons.org/licenses/by/4.0/",
      target = "_blank",
      rel = "noopener noreferrer"
    )
  )
)

server <- function(input, output, session) {
  math_output <- function(content) {
    withMathJax(HTML(content))
  }

  critical_vector_density <- function(mu, D, b, c, a, p, n) {
    mu / (D * b * c * a^2 * p^n)
  }

  critical_hbr <- function(mu, D, b, c, a, p, n) {
    mu / (D * b * c * a * p^n)
  }

  vectorial_capacity <- function(m, a, p, n, mu) {
    (m * a^2 * p^n) / mu
  }

  scenario_reproduction_number <- function(C, b, c, D) {
    C * b * c * D
  }

  params <- reactive({
    p <- input$p
    h <- input$h
    g <- input$g
    n <- input$n
    D <- input$D
    b <- input$b
    c <- input$c

    if (
      is.null(p) || is.null(h) || is.null(g) || is.null(n) ||
        is.null(D) || is.null(b) || is.null(c) ||
        p <= 0 || p >= 1 || g <= 0
    ) {
      return(NULL)
    }

    list(
      p = p,
      h = h,
      g = g,
      n = n,
      a = h / g,
      D = D,
      b = b,
      c = c,
      mu = -log(p)
    )
  })

  set_preset <- function(p, h, g, n, D, b, c, m) {
    updateSliderInput(session, "p", value = p)
    updateSliderInput(session, "h", value = h)
    updateSliderInput(session, "g", value = g)
    updateSliderInput(session, "n", value = n)
    updateSliderInput(session, "D", value = D)
    updateSliderInput(session, "b", value = b)
    updateSliderInput(session, "c", value = c)
    updateSliderInput(session, "m_current", value = m)
  }

  # Illustrative teaching presets; these are not empirical efficacy estimates.
  observeEvent(input$preset_baseline, {
    set_preset(0.90, 0.90, 2.5, 10, 80, 0.30, 0.50, 50)
  })
  observeEvent(input$preset_llin, {
    set_preset(0.85, 0.25, 2.5, 10, 80, 0.30, 0.50, 25)
  })
  observeEvent(input$preset_irs, {
    set_preset(0.75, 0.90, 2.5, 10, 80, 0.30, 0.50, 25)
  })
  observeEvent(input$preset_immunity, {
    set_preset(0.90, 0.90, 2.5, 10, 20, 0.20, 0.40, 50)
  })
  observeEvent(input$preset_suppression, {
    set_preset(0.90, 0.90, 2.5, 10, 80, 0.30, 0.50, 5)
  })

  output$criticalM <- renderUI({
    x <- params()
    if (is.null(x)) {
      return("Choose valid parameters.")
    }
    if (x$a <= 0) {
      return(math_output(paste0(
        "With \\(a=0\\) there is no human blood feeding and \\(R=0\\), ",
        "so no finite critical mosquito density exists."
      )))
    }
    if (x$b <= 0 || x$c <= 0 || x$D <= 0) {
      return(math_output(paste0(
        "With \\(b=0\\), \\(c=0\\), or \\(D=0\\), there is no ",
        "transmission (\\(R=0\\)), so no finite critical mosquito density exists."
      )))
    }

    M <- critical_vector_density(x$mu, x$D, x$b, x$c, x$a, x$p, x$n)
    math_output(sprintf(
      paste0(
        "Critical mosquito density for \\(R=1\\): ",
        "\\(m^*=%.2f\\) mosquitoes per human"
      ),
      M
    ))
  })

  output$criticalHBR <- renderUI({
    x <- params()
    if (is.null(x)) {
      return("")
    }
    if (x$a <= 0) {
      return(math_output(
        "Critical HBR is undefined when \\(a=0\\) (\\(R=0\\))."
      ))
    }
    if (x$b <= 0 || x$c <= 0 || x$D <= 0) {
      return(math_output(paste0(
        "Critical HBR is undefined when \\(b=0\\), \\(c=0\\), or ",
        "\\(D=0\\) (\\(R=0\\))."
      )))
    }

    HBR <- critical_hbr(x$mu, x$D, x$b, x$c, x$a, x$p, x$n)
    math_output(sprintf(
      paste0(
        "Critical human biting rate for \\(R=1\\): ",
        "\\(\\mathrm{HBR}^*=%.2f\\) bites per human per day"
      ),
      HBR
    ))
  })

  output$e <- renderUI({
    x <- params()
    if (is.null(x)) {
      return("")
    }
    math_output(sprintf(
      paste0(
        "Expected infectious life per mosquito at emergence, ",
        "\\(p^n/\\mu\\): %.2f days"
      ),
      x$p^x$n / x$mu
    ))
  })

  output$life_expect <- renderUI({
    x <- params()
    if (is.null(x)) {
      return("")
    }
    math_output(sprintf(
      "Expected lifespan at emergence, \\(1/\\mu\\): %.1f days",
      1 / x$mu
    ))
  })

  output$CPlot <- renderPlot({
    x <- params()
    if (is.null(x)) {
      return()
    }

    if (x$a <= 0) {
      par(bty = "n")
      plot.new()
      title(main = "Vectorial capacity as a function of mosquito density")
      text(
        0.5, 0.5,
        expression(italic(C) == 0~"because the human blood-feeding rate is zero")
      )
      return()
    }

    m <- 10^seq(-2, 3, length.out = 500)
    C <- vectorial_capacity(m, x$a, x$p, x$n, x$mu)
    Cpos <- C[C > 0 & is.finite(C)]
    ymin <- min(Cpos, na.rm = TRUE) * 0.8
    ymax <- max(Cpos, na.rm = TRUE) * 1.2

    if (x$b > 0 && x$c > 0 && x$D > 0) {
      Ccrit <- 1 / (x$b * x$c * x$D)
      M <- critical_vector_density(x$mu, x$D, x$b, x$c, x$a, x$p, x$n)
    } else {
      Ccrit <- NA_real_
      M <- NA_real_
    }

    par(bty = "n", las = 1)
    plot(
      log10(m), C,
      type = "l",
      col = "darkgray",
      log = "y",
      ylim = c(ymin, ymax),
      main = "Vectorial capacity as a function of mosquito density",
      ylab = expression("Vectorial capacity " * italic(C)~
        (day^{-1} * ", log scale")),
      xlab = expression("Mosquitoes per human " * (log[10] * " scale"))
    )

    if (!is.na(Ccrit) && Ccrit > 0) {
      abline(h = Ccrit, col = "red", lty = 2)
      text(
        min(log10(m)) + 0.5,
        Ccrit,
        labels = expression(italic(R) == 1~"threshold"),
        col = "red",
        pos = 3,
        offset = 0.6
      )

      if (
        is.finite(M) && M >= min(m) && M <= max(m) &&
          Ccrit >= ymin && Ccrit <= ymax
      ) {
        arrows(
          x0 = log10(M), y0 = Ccrit,
          x1 = log10(M), y1 = ymin,
          col = "blue", lty = 3
        )
      }
    }

    if (input$m_current > 0) {
      abline(v = log10(input$m_current), col = "orange", lwd = 2)
      text(
        log10(input$m_current), ymax * 0.8,
        labels = expression("current " * italic(m)), col = "orange", pos = 4
      )
    }
  })

  output$Survivorship <- renderPlot({
    x <- params()
    if (is.null(x)) {
      return()
    }

    t <- 0:30
    S <- x$p^t
    par(bty = "n", las = 1)
    plot(
      t, S,
      type = "n",
      ylim = c(0, 1),
      main = "Survivorship",
      xlab = expression("Days after emergence, " * italic(t)),
      ylab = expression("Survival probability, " * italic(S)(italic(t)))
    )
    lines(t, S, col = "darkgray", lwd = 2)
  })

  c_current <- reactive({
    x <- params()
    if (is.null(x)) {
      return(NA_real_)
    }
    vectorial_capacity(input$m_current, x$a, x$p, x$n, x$mu)
  })

  hbr_current <- reactive({
    x <- params()
    if (is.null(x)) {
      return(NA_real_)
    }
    input$m_current * x$a
  })

  r_current <- reactive({
    x <- params()
    C <- c_current()
    if (is.null(x) || is.na(C)) {
      return(NA_real_)
    }
    scenario_reproduction_number(C, x$b, x$c, x$D)
  })

  output$C_current <- renderUI({
    C <- c_current()
    if (is.na(C)) {
      return(math_output(
        "Choose valid parameters to compute \\(C\\) and \\(R\\)."
      ))
    }
    math_output(sprintf(
      "Current vectorial capacity: \\(C=%.3f\\;\\mathrm{day}^{-1}\\).",
      C
    ))
  })

  output$HBR_current <- renderUI({
    HBR <- hbr_current()
    if (is.na(HBR)) {
      return("")
    }
    math_output(sprintf(
      paste0(
        "Current human biting rate: \\(\\mathrm{HBR}=%.3f\\) ",
        "bites per human per day."
      ),
      HBR
    ))
  })

  output$R_current <- renderUI({
    R <- r_current()
    if (is.na(R)) {
      return("")
    }
    math_output(sprintf(
      "Current scenario reproduction number: \\(R=%.2f\\)",
      R
    ))
  })

  output$R_regime <- renderUI({
    R <- r_current()
    if (is.na(R)) {
      return("")
    }

    if (R <= 0) {
      math_output(
        "Regime: \\(R=0\\) → no transmission under the selected parameters"
      )
    } else if (R < 1) {
      math_output(
        "Regime: \\(R<1\\) → infections decline near the disease-free state"
      )
    } else if (abs(R - 1) < 1e-8) {
      math_output("Regime: \\(R=1\\) → critical transmission threshold")
    } else {
      math_output(paste0(
        "Regime: \\(R>1\\) → sustained transmission is possible under ",
        "the model assumptions"
      ))
    }
  })

  output$summaryTable <- renderUI({
    x <- params()
    if (is.null(x)) {
      return(NULL)
    }

    C <- c_current()
    HBR <- hbr_current()
    R <- r_current()

    quantities <- c(
      "Daily survival probability, \\(p\\)",
      "Human-meal probability, \\(h\\)",
      "Gonotrophic-cycle duration, \\(g\\)",
      "Extrinsic incubation period, \\(n\\)",
      "Human blood-feeding rate, \\(a=h/g\\)",
      "Effective infectious duration, \\(D\\)",
      "Current mosquito density, \\(m\\)",
      "Current human biting rate, \\(\\mathrm{HBR}=ma\\)",
      "Current vectorial capacity, \\(C\\)",
      "Current scenario reproduction number, \\(R\\)"
    )

    values <- c(
      round(x$p, 3),
      round(x$h, 3),
      round(x$g, 2),
      round(x$n, 1),
      round(x$a, 3),
      round(x$D, 1),
      round(input$m_current, 1),
      signif(HBR, 3),
      signif(C, 3),
      signif(R, 3)
    )

    units <- c(
      "probability",
      "probability",
      "days",
      "days",
      "human blood meals per mosquito per day",
      "days",
      "mosquitoes per human",
      "bites per human per day",
      "\\(\\mathrm{day}^{-1}\\)",
      "dimensionless"
    )

    rows <- lapply(seq_along(values), function(i) {
      tags$tr(
        tags$td(HTML(quantities[[i]])),
        tags$td(format(values[[i]], trim = TRUE, scientific = FALSE)),
        tags$td(HTML(units[[i]]))
      )
    })

    withMathJax(
      tags$table(
        class = "table table-condensed table-hover",
        tags$thead(
          tags$tr(
            tags$th("Quantity"),
            tags$th("Value"),
            tags$th("Units")
          )
        ),
        tags$tbody(rows)
      )
    )
  })
}

shinyApp(ui = ui, server = server)
