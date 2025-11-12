#
# Vectorial capacity & R0 – Garrett-Jones / Macdonald playground
#
# Biological background (Macdonald, Garrett-Jones):
# - Vectorial capacity (C) summarizes the per-capita daily potential for transmission by the vector population:
#     C = m * a^2 * p^n / μ # nolint: commented_code_linter.
#   where:
#     m  = number of vectors per host (vectors/host),
#     a  = human biting rate per vector per day (bites/vector/day),
#     p  = daily probability of vector survival (dimensionless),
#     n  = duration of the parasite extrinsic incubation period (days),
#     μ  = per-day mortality rate of vectors = -ln(p) (1/day).
#   Interpretation: m counts how many vectors are available; a^2 captures two bites needed
#   for transmission (host infecting the vector and then vector infecting the host); p^n is the probability a vector
#   survives the incubation; 1/μ is expected remaining life once infectious.
#
# - Basic reproduction number:
#     R0 = C * b * c * D # nolint
#   where:
#     b = probability that a bite by an infectious mosquito infects a human,
#     c = probability that a bite on an infectious human infects a mosquito,
#     D = duration of human infectiousness (gametocytaemia) in days.
#   Threshold: transmission cannot persist when R0 < 1, and is sustained when R0 > 1.
#
# - Derived quantities:
#     a = h / g, where h is the probability of feeding on the target host per gonotrophic cycle
#     and g is the cycle length (days). This yields the per-day human biting rate per vector.
#     caveat: this assumes all blood meals are successful and no more than one blood meal per cycle.
#     Expectation of infective life: E_infective = p^n / μ (days).
#     Expectation of lifespan at emergence: 1 / μ (days).
#
# This Shiny app lets you explore how entomological parameters (p, h, g, n, m)
# and human/parasite parameters (b, c, D) shape C and R0, the threshold for R0=1,
# and survivorship under an exponential mortality model.
#

library(shiny)

ui <- fluidPage(
   # Application title
   titlePanel("Vectorial Capacity & R0"),

   # Sidebar with sliders
   sidebarLayout(
      sidebarPanel(
         h4("Vector & parasite parameters"),
         # p: daily survival probability (0–1). Small changes can have large effects (via p^n and μ = -ln p).
         sliderInput("p",
            "Daily probability of survival (p)",
            min   = 0.5,
            max   = 0.99,
            value = 0.8,
            step  = 0.01
         ),
         # h: probability that a blood meal is on the focal host (e.g., human) per gonotrophic cycle.
         sliderInput("h",
            "Probability of feeding on host per gonotrophic cycle (h)",
            min   = 0,
            max   = 1,
            value = 0.5,
            step  = 0.05
         ),
         # g: length of the gonotrophic cycle in days. a = h/g, so shorter cycles increase daily biting.
         sliderInput("g",
            "Duration of gonotrophic cycle (days, g)",
            min   = 1,
            max   = 6,
            value = 2.5,
            step  = 0.5
         ),
         # n: extrinsic incubation period (EIP) in days. p^n is the survival to infectiousness.
         sliderInput("n",
            "Duration of parasite extrinsic incubation period (days, n)",
            min   = 8,
            max   = 50,
            value = 12,
            step  = 1
         ),
         hr(),
         h4("Human & infection parameters"),
         # D: duration of human infectiousness (gametocytaemia) in days; affects R0 linearly.
         sliderInput("D",
            "Duration of infective gametocytaemia (days, D)",
            min   = 0,
            max   = 200,
            value = 80,
            step  = 5
         ),
         # b: infection probability mosquito -> human per infectious bite.
         sliderInput("b",
            "Prob. mosquito → human infection per infectious bite (b)",
            min   = 0,
            max   = 1,
            value = 0.3,
            step  = 0.05
         ),
         # c: infection probability human -> mosquito per bite.
         sliderInput("c",
            "Prob. human → mosquito infection per bite (c)",
            min   = 0,
            max   = 1,
            value = 0.5,
            step  = 0.05
         ),
         hr(),
         h4("Current scenario"),
         # m_current: current vector density (vectors per host) for point estimates of C and R0.
         sliderInput("m_current",
            "Current vector density (m, vectors/host)",
            min   = 0,
            max   = 200,
            value = 10,
            step  = 1
         ),
         hr(),
         h4("Presets"),
         fluidRow(
            column(6, actionButton("preset_baseline", "Baseline high transmission")),
            column(6, actionButton("preset_llin", "LLINs"))
         ),
         fluidRow(
            column(6, actionButton("preset_irs", "IRS")),
            column(6, actionButton("preset_immunity", "Partial immunity"))
         ),
         fluidRow(
            column(12, actionButton(
               "preset_suppression",
               "Genetic / larval suppression"
            ))
         )
      ),

      # Main panel with tabs
      mainPanel(
         tabsetPanel(
            type = "tabs",

            # Tab 1: Instructions (README content)
            tabPanel(
               "Instructions",
               br(),
               h3("Overview"),
               p("This educational tool allows you to explore the Macdonald-Garrett-Jones framework of malaria transmission dynamics,
                 focusing on vectorial capacity and the basic reproduction number (R₀)."),
               h3("Biological & Mathematical Background"),
               h4("Vectorial Capacity (C)"),
               p("The vectorial capacity represents the daily rate at which future inoculations arise from a single infectious case:"),
               withMathJax("$$C = \\frac{ma^2p^n}{\\mu}$$"),
               tags$ul(
                  tags$li(strong("m:"), "vector density (vectors per host)"),
                  tags$li(strong("a:"), "human biting rate per vector per day"),
                  tags$li(strong("p:"), "daily probability of vector survival"),
                  tags$li(strong("n:"), "extrinsic incubation period (EIP) – days for parasite to develop in mosquito"),
                  tags$li(strong("μ:"), "per-day mortality rate = -ln(p)")
               ),
               h4("Basic Reproduction Number (R₀)"),
               p("R₀ represents the expected number of secondary infections arising from one primary infection:"),
               withMathJax("$$R_0 = C \\times b \\times c \\times D$$"),
               tags$ul(
                  tags$li(strong("b:"), "probability that a bite by an infectious mosquito infects a human"),
                  tags$li(strong("c:"), "probability that a bite on an infectious human infects a mosquito"),
                  tags$li(strong("D:"), "duration of human infectiousness (gametocytaemia) in days")
               ),
               h4("Threshold Principle"),
               tags$ul(
                  tags$li(strong("R₀ < 1:"), "Transmission cannot be sustained (each case produces <1 secondary case)"),
                  tags$li(strong("R₀ = 1:"), "Threshold – transmission at equilibrium"),
                  tags$li(strong("R₀ > 1:"), "Transmission can be sustained (epidemic potential)")
               ),
               h3("Using the App"),
               h4("Parameters"),
               p(strong("Vector & Parasite Parameters:")),
               tags$ul(
                  tags$li(strong("p:"), "Daily survival probability – small changes have large effects"),
                  tags$li(strong("h:"), "Probability of feeding on humans per cycle"),
                  tags$li(strong("g:"), "Gonotrophic cycle length (1-6 days)"),
                  tags$li(strong("n:"), "Extrinsic incubation period (8-50 days)")
               ),
               p(strong("Human & Infection Parameters:")),
               tags$ul(
                  tags$li(strong("D:"), "Duration of gametocytaemia (20-200 days)"),
                  tags$li(strong("b:"), "Mosquito → human transmission probability"),
                  tags$li(strong("c:"), "Human → mosquito transmission probability")
               ),
               h4("Preset Scenarios"),
               p("Five intervention scenarios based on real-world malaria control strategies:"),
               tags$ol(
                  tags$li(strong("Baseline High Transmission:"), "Representative of holoendemic areas with Anopheles gambiae"),
                  tags$li(strong("LLINs:"), "Long-Lasting Insecticidal Nets – reduced host contact + modest mortality"),
                  tags$li(strong("IRS:"), "Indoor Residual Spraying – strong mortality increase"),
                  tags$li(strong("Partial Immunity:"), "Shorter infectious period + reduced transmission efficiency"),
                  tags$li(strong("Genetic/Larval Suppression:"), "Dramatic reduction in vector density")
               ),
               h3("References"),
               tags$ol(
                  tags$li("Garrett-Jones, C. & Grab, B. (1964). Bull. Wld. Hlth. Org. 31:71-86."),
                  tags$li("Macdonald, G. (1955). Proc. Roy. Soc. Med. 48:295-301."),
                  tags$li("Smith, D.L., et al. (2012). PLoS Pathogens, 8(4):e1002588.")
               )
            ),

            # Tab 2: Main Analysis (vectorial capacity plot and metrics)
            tabPanel(
               "Vectorial Capacity & R₀",
               br(),
               # Decorative image
               img(src = "Anopheles.jpg", width = 50),
               h3("Definition of vectorial capacity"),
               div("The vectorial capacity of a malaria vector population is defined as the average number of inoculations
                 with a specified (Plasmodium) parasite, originating from one case of malaria in unit time,
                 that the population would distribute to humans if all the vectors biting the case became infected."),
               em("---Garrett-Jones, C. & Grab, B. (1964) Bull. Wld. Hlth. Org. 31:71-86."),
               br(),
               h3("Critical threshold and basic reproduction number R₀"),
               div("In the Macdonald framework, the basic reproduction number satisfies
                 R₀ = C × b × c × D, where C is the vectorial capacity and D is the duration
                 of infective gametocytaemia. Endemic transmission disappears when R₀ = 1,
                 i.e. when C = 1/(b × c × D). For non-immune persons infected with P. falciparum,
                 D is often taken to be about 80 days."),
               em("---Macdonald, G. (1955) Proc. Roy. Soc. Med. 48:295-301."),
               # Plot: C as a function of m. Shows threshold horizontal line for R0=1 and critical m.
               plotOutput("CPlot"),
               # Text outputs for critical density m at R0=1, critical ma, and expectation of infective life.
               p(textOutput("criticalM")),
               p(textOutput("criticalMA")),
               p(textOutput("e")),
               br(),
               h3("Current C and R₀ for the chosen m"),
               # Point estimates at m_current
               p(textOutput("C_current")),
               p(textOutput("R0_current")),
               p(textOutput("R0_regime")),
               tableOutput("summaryTable")
            ),

            # Tab 3: Survivorship
            tabPanel(
               "Survivorship",
               br(),
               h3("Vector Survivorship Under Exponential Mortality"),
               p("This plot shows the probability that a vector survives t days after emergence,
                 assuming a constant daily survival probability p and exponential mortality model."),
               p("The survivorship function is S(t) = p^t, where p is the daily survival probability."),
               # Survivorship curve under exponential mortality (S(t) = p^t).
               plotOutput("Survivorship"),
               p(textOutput("life_expect")),
               br(),
               h4("Interpretation"),
               p("Under the exponential mortality model:"),
               tags$ul(
                  tags$li("The mortality rate (μ = -ln(p)) is constant over time"),
                  tags$li("There is no senescence – vectors do not 'age'"),
                  tags$li("The probability of dying is the same each day regardless of current age"),
                  tags$li("This is a simplification: real mosquito populations show age-dependent mortality")
               )
            )
         )
      )
   )
)

server <- function(input, output, session) {
   # Helper function for critical vector density (snake_case)
   critical_vector_density <- function(mu, D, b, c, a, p, n) {
      mu / (D * b * c * a^2 * p^n)
   }

   # Collect and derive parameters in one place
   params <- reactive({
      p <- input$p
      # Guardrail: p must be strictly between 0 and 1 to define μ = -ln p and probabilities.
      if (p <= 0 || p >= 1) {
         return(NULL)
      }
      h <- input$h
      g <- input$g
      n <- input$n
      # a: human biting rate per vector per day = probability of biting the focal host per cycle / cycle length
      a <- h / g # human biting rate per vector per day
      D <- input$D
      b <- input$b
      c <- input$c
      # Exponential mortality: if daily survival is p, then μ = -ln p per day (constant hazard).
      mu <- -log(p) # exponential mortality rate (1/day)

      list(
         p = p, h = h, g = g, n = n,
         a = a, D = D, b = b, c = c, mu = mu
      )
   })

   # Preset scenarios --------------------------------------------------------
   # 1) High transmission baseline (An. gambiae-ish)
   observeEvent(input$preset_baseline, {
      updateSliderInput(session, "p", value = 0.90)
      updateSliderInput(session, "h", value = 0.90)
      updateSliderInput(session, "g", value = 2.5)
      updateSliderInput(session, "n", value = 10)
      updateSliderInput(session, "D", value = 80)
      updateSliderInput(session, "b", value = 0.30)
      updateSliderInput(session, "c", value = 0.50)
      updateSliderInput(session, "m_current", value = 50)
   })

   # 2) LLINs (reduced host feeding + slightly lower survival)
   observeEvent(input$preset_llin, {
      updateSliderInput(session, "p", value = 0.85)
      updateSliderInput(session, "h", value = 0.25)
      updateSliderInput(session, "g", value = 2.5)
      updateSliderInput(session, "n", value = 10)
      updateSliderInput(session, "D", value = 80)
      updateSliderInput(session, "b", value = 0.30)
      updateSliderInput(session, "c", value = 0.50)
      updateSliderInput(session, "m_current", value = 25)
   })

   # 3) IRS (strong reduction in survival)
   observeEvent(input$preset_irs, {
      updateSliderInput(session, "p", value = 0.75)
      updateSliderInput(session, "h", value = 0.90)
      updateSliderInput(session, "g", value = 2.5)
      updateSliderInput(session, "n", value = 10)
      updateSliderInput(session, "D", value = 80)
      updateSliderInput(session, "b", value = 0.30)
      updateSliderInput(session, "c", value = 0.50)
      updateSliderInput(session, "m_current", value = 25)
   })

   # 4) Partial immunity (shorter infectious period + slightly lower b, c)
   observeEvent(input$preset_immunity, {
      updateSliderInput(session, "p", value = 0.90)
      updateSliderInput(session, "h", value = 0.90)
      updateSliderInput(session, "g", value = 2.5)
      updateSliderInput(session, "n", value = 10)
      updateSliderInput(session, "D", value = 20)
      updateSliderInput(session, "b", value = 0.20)
      updateSliderInput(session, "c", value = 0.40)
      updateSliderInput(session, "m_current", value = 50)
   })

   # 5) Genetic / larval suppression (strong reduction in m)
   observeEvent(input$preset_suppression, {
      updateSliderInput(session, "p", value = 0.90)
      updateSliderInput(session, "h", value = 0.90)
      updateSliderInput(session, "g", value = 2.5)
      updateSliderInput(session, "n", value = 10)
      updateSliderInput(session, "D", value = 80)
      updateSliderInput(session, "b", value = 0.30)
      updateSliderInput(session, "c", value = 0.50)
      updateSliderInput(session, "m_current", value = 5)
   })

   # Critical vector density m for R0 = 1
   # From R0 = (m a^2 p^n / μ) * b c D, set R0 = 1 and solve for m:
   #   m* = μ / (D * b * c * a^2 * p^n)
   output$criticalM <- renderText({
      par <- params()
      if (is.null(par)) {
         return("Choose a daily survival probability strictly between 0 and 1.")
      }
      if (par$b <= 0 || par$c <= 0) {
         return("With b = 0 or c = 0 there is no transmission (R₀ = 0), so no finite critical vector density.")
      }
      M <- critical_vector_density(par$mu, par$D, par$b, par$c, par$a, par$p, par$n)
      paste("Critical density for R₀ = 1 (blue arrow) =", round(M, 2), "vectors/host")
   })

   # Critical human biting rate ma for R0 = 1 (text only)
   # Using R0 = (m a^2 p^n / μ) * b c D, set MA = m a => R0 = (MA * a * p^n / μ)*b c D,
   # then solve for MA: MA* = μ / (D * b * c * a * p^n)
   output$criticalMA <- renderText({
      par <- params()
      if (is.null(par)) {
         return("")
      }
      if (par$b <= 0 || par$c <= 0) {
         return("Critical human biting rate is undefined when b = 0 or c = 0 (R₀ = 0).")
      }
      MA <- par$mu / (par$D * par$b * par$c * par$a * par$p^par$n)
      paste(
         "Critical human biting rate for R₀ = 1 =",
         round(MA, 2), "bites/host/day"
      )
   })

   # Expectation of infective life
   # Once infectious (after n days), remaining expected life under exponential mortality is 1/μ.
   # Conditioning on surviving EIP yields E_infective = P(survive n days) * (1/μ) = p^n / μ.
   output$e <- renderText({
      par <- params()
      if (is.null(par)) {
         return("")
      }
      e_inf <- par$p^par$n / par$mu
      paste("Expectation of infective life =", round(e_inf, 2), "days")
   })

   # Expectation of lifespan at emergence (under exponential mortality)
   # E[T] = 1/μ days.
   output$life_expect <- renderText({
      par <- params()
      if (is.null(par)) {
         return("")
      }
      e_life <- 1 / par$mu
      paste("Expectation of lifespan at emergence =", round(e_life, 1), "days")
   })

   # Vectorial capacity as a function of m
   # Plots C(m) = (m a^2 p^n)/μ on a log10 m axis and marks the R0=1 horizontal threshold and critical m.
   output$CPlot <- renderPlot({
      par <- params()
      if (is.null(par)) {
         return()
      }

      # grid of m on log-scale: 0.01–10,000 vectors/host
      m <- 10^seq(-2, 3, length.out = 500)
      C <- (m * par$a^2 * par$p^par$n) / par$mu

      # Threshold C for R0 = 1 and corresponding critical M if b, c > 0.
      if (par$b > 0 && par$c > 0) {
         Ccrit <- 1 / (par$b * par$c * par$D)
         M <- par$mu / (par$D * par$b * par$c * par$a^2 * par$p^par$n)
      } else {
         Ccrit <- NA
         M <- NA
      }

      # y limits for log-scale (avoid zero)
      Cpos <- C[C > 0 & is.finite(C)]
      ymax <- max(Cpos, na.rm = TRUE) * 1.2
      ymin <- min(Cpos, na.rm = TRUE) * 0.8
      ylim <- c(ymin, ymax)

      par(bty = "n", las = 1)
      plot(log10(m), C,
         col  = "darkgray",
         type = "l",
         ylim = ylim,
         log  = "y", # log-scale for C
         main = "Vectorial Capacity as a function of vector density",
         ylab = "Vectorial Capacity C (per day, log scale)",
         xlab = "No. vectors/host (log10 scale)"
      )

      # horizontal threshold R0 = 1: Ccrit = 1/(b c D)
      if (!is.na(Ccrit) && Ccrit > 0) {
         abline(h = Ccrit, col = "red", lty = 2)
         text(
            x = min(log10(m)) + 0.5,
            y = Ccrit * 1.05,
            labels = "R₀ = 1 threshold",
            col = "red", adj = 0
         )

         # arrow for critical M where C crosses the threshold
         if (is.finite(M) && M > 0) {
            arrows(
               x0 = log10(M), y0 = Ccrit,
               x1 = log10(M), y1 = ylim[1],
               col = "blue", lty = 3
            )
         }
      }

      # show current m on the curve for reference
      if (input$m_current > 0) {
         abline(v = log10(input$m_current), col = "orange", lwd = 2)
         text(
            x = log10(input$m_current),
            y = ymax * 0.8,
            labels = "current m", col = "orange", pos = 4
         )
      }
   })

   # Survivorship curve under the constant daily survival p (geometric/exponential survival).
   # S(t) = p^t gives the probability an individual alive at emergence is still alive t days later.
   output$Survivorship <- renderPlot({
      par <- params()
      if (is.null(par)) {
         return()
      }

      t <- 0:30
      S <- par$p^t

      par(bty = "n", las = 1)
      plot(t, S,
         type = "n",
         main = "Survivorship",
         xlab = "No. days after emergence (t)",
         ylab = "Proportion surviving after t days"
      )
      lines(t, S, col = "darkgray", lwd = 2)
   })

   # Reactive expression for current vectorial capacity (snake_case)
   c_current <- reactive({
      par <- params()
      if (is.null(par) || input$m_current <= 0) {
         return(NA)
      }
      (input$m_current * par$a^2 * par$p^par$n) / par$mu
   })

   # Current C and R0 for the chosen m_current
   output$C_current <- renderText({
      value <- c_current()
      if (is.na(value)) {
         return("Set current vector density m > 0 to compute C and R₀.")
      }
      paste(
         "Current vectorial capacity C =",
         round(value, 3),
         "infectious bites per host per day (given m =",
         input$m_current, ")."
      )
   })

   output$R0_current <- renderText({
      par <- params()
      value <- c_current()
      if (is.null(par) || is.na(value)) {
         return("")
      }
      R0 <- value * par$b * par$c * par$D
      paste("Current basic reproduction number R₀ =", round(R0, 2))
   })

   # Define threshold for borderline R₀ regime (epidemiological rationale: values slightly above 1 may still be unstable)
   R0_THRESHOLD_UPPER <- 1.2

   output$R0_regime <- renderText({
      par <- params()
      value <- c_current()
      if (is.null(par) || is.na(value)) {
         return("")
      }
      R0 <- value * par$b * par$c * par$D

      # Simple qualitative classification around the threshold R0=1
      if (R0 < 1) {
         "Regime: R₀ < 1 → transmission cannot be sustained ❄️"
      } else if (R0 <= R0_THRESHOLD_UPPER) {
         "Regime: R₀ ≈ 1 → threshold / borderline ⚖️"
      } else {
         "Regime: R₀ > 1 → sustained transmission possible 🔥"
      }
   })

   # Small summary table -----------------------------------------------------
   output$summaryTable <- renderTable({
      par <- params()
      if (is.null(par) || input$m_current <= 0) {
         return(NULL)
      }

      m <- input$m_current
      C_current <- (m * par$a^2 * par$p^par$n) / par$mu
      R0 <- C_current * par$b * par$c * par$D

      data.frame(
         Quantity = c(
            "Daily survival p",
            "Feeding probability on host h",
            "Gonotrophic cycle g",
            "EIP n",
            "Human biting rate a = h/g",
            "Duration of infectivity D",
            "Current vector density m",
            "Current vectorial capacity C",
            "Current basic reproduction number R₀"
         ),
         Value = c(
            round(par$p, 3),
            round(par$h, 3),
            round(par$g, 2),
            round(par$n, 1),
            round(par$a, 3),
            round(par$D, 1),
            round(m, 1),
            signif(C_current, 3),
            signif(R0, 3)
         ),
         Units = c(
            "probability",
            "probability",
            "days",
            "days",
            "bites per mosquito per day",
            "days",
            "vectors per host",
            "infectious bites per host per day",
            "dimensionless"
         ),
         stringsAsFactors = FALSE
      )
   })
}

# Launch the app
shinyApp(ui = ui, server = server)
