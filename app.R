#
# Vectorial capacity & reproduction-number explorer
#
# Classical Garrett-Jones / Ross-Macdonald framework:
#   C = m * a^2 * p^n / mu
#   R = C * b * c * D
#
# Here:
#   m  = adult mosquito density (mosquitoes per human)
#   a  = human blood-feeding rate per mosquito per day
#   p  = daily mosquito survival probability
#   n  = parasite extrinsic incubation period (days)
#   mu = constant mortality hazard = -ln(p) per day
#   b  = probability an infectious mosquito bite infects a susceptible human
#   c  = probability a mosquito becomes infected after biting an infectious human
#   D  = effective duration of human infectiousness to mosquitoes (days)
#
# The human biting rate (HBR) is m * a, not a itself.
# The generic symbol R is used because intervention and immunity-inspired presets
# are not all valid interpretations of the basic reproduction number R0.
#

library(shiny)

ui <- fluidPage(
   titlePanel("Vectorial Capacity & Reproduction Number Explorer"),

   sidebarLayout(
      sidebarPanel(
         h4("Vector & parasite parameters"),
         sliderInput(
            "p",
            "Daily mosquito survival probability (p)",
            min = 0.5,
            max = 0.99,
            value = 0.8,
            step = 0.01
         ),
         sliderInput(
            "h",
            "Effective probability of a human blood meal per gonotrophic cycle (h)",
            min = 0,
            max = 1,
            value = 0.5,
            step = 0.05
         ),
         sliderInput(
            "g",
            "Gonotrophic-cycle duration (days, g)",
            min = 1,
            max = 6,
            value = 2.5,
            step = 0.5
         ),
         sliderInput(
            "n",
            "Parasite extrinsic incubation period (days, n)",
            min = 8,
            max = 50,
            value = 12,
            step = 1
         ),
         hr(),
         h4("Human & infection parameters"),
         sliderInput(
            "D",
            "Effective duration of human infectiousness to mosquitoes (days, D)",
            min = 0,
            max = 200,
            value = 80,
            step = 5
         ),
         sliderInput(
            "b",
            "Prob. mosquito → human infection per infectious bite (b)",
            min = 0,
            max = 1,
            value = 0.3,
            step = 0.05
         ),
         sliderInput(
            "c",
            "Prob. human → mosquito infection per bite (c)",
            min = 0,
            max = 1,
            value = 0.5,
            step = 0.05
         ),
         hr(),
         h4("Current scenario"),
         sliderInput(
            "m_current",
            "Current adult mosquito density (m, mosquitoes/human)",
            min = 0,
            max = 200,
            value = 10,
            step = 1
         ),
         hr(),
         h4("Illustrative presets"),
         p(
            small(
               "Teaching examples only: parameter values are not empirical intervention-effect estimates."
            )
         ),
         fluidRow(
            column(
               width = 6,
               actionButton(
                  "preset_baseline",
                  "Illustrative high transmission",
                  width = "100%"
               ),
               br(),
               actionButton(
                  "preset_suppression",
                  "Vector-density suppression",
                  width = "100%"
               ),
               br(),
               actionButton(
                  "preset_immunity",
                  "Host-immunity-inspired",
                  width = "100%"
               )
            ),
            column(
               width = 6,
               actionButton("preset_irs", "IRS-inspired", width = "100%"),
               br(),
               actionButton("preset_llin", "LLIN-inspired", width = "100%")
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
               p(
                  "The classical vectorial-capacity expression used here is:"
               ),
               withMathJax("$$C = \\frac{ma^2p^n}{\\mu}$$"),
               tags$ul(
                  tags$li(strong("m:"), "adult mosquito density, mosquitoes per human"),
                  tags$li(strong("a:"), "human blood-feeding rate per mosquito per day"),
                  tags$li(strong("p:"), "daily mosquito survival probability"),
                  tags$li(strong("n:"), "parasite extrinsic incubation period in days"),
                  tags$li(strong("μ:"), "constant mosquito mortality hazard = -ln(p) per day")
               ),
               p(
                  "Vectorial capacity has units of day⁻¹ and represents transmission potential generated by mosquitoes feeding on a fully infectious human under the model assumptions. It is not the entomological inoculation rate (EIR)."
               ),
               h3("Human blood feeding and HBR"),
               withMathJax("$$a = \\frac{h}{g}, \\qquad \\mathrm{HBR}=ma$$"),
               p(
                  "Here a is a per-mosquito human blood-feeding rate. The human biting rate (HBR) is ma, in bites per human per day. The derivation assumes one successful blood meal per gonotrophic cycle and does not represent interrupted or repeated feeding attempts."
               ),
               h3("Scenario reproduction number"),
               withMathJax("$$R = C \\times b \\times c \\times D$$"),
               p(
                  "The app uses the generic symbol R. Under an uncontrolled, fully susceptible baseline this corresponds to the classical basic reproduction number R₀. Under control it is more appropriately interpreted as a controlled or scenario reproduction number. The host-immunity-inspired preset is phenomenological and should not be interpreted as a dynamically modelled effective reproduction number."
               ),
               h4("Threshold principle"),
               tags$ul(
                  tags$li(strong("R < 1:"), "infections decline near the disease-free state"),
                  tags$li(strong("R = 1:"), "critical transmission threshold"),
                  tags$li(strong("R > 1:"), "sustained transmission is possible under the model assumptions")
               ),
               p(
                  "R = 1 is a critical threshold, not a general statement that an endemic system is 'at equilibrium'."
               ),
               h3("Human infectiousness parameter D"),
               p(
                  "D is the effective duration of human infectiousness to mosquitoes. The default value of 80 days is retained as a historical teaching value associated with classical Macdonald-era malaria theory; it is not a universal contemporary estimate. Gametocyte carriage, gametocyte density, and actual mosquito infectivity are distinct quantities."
               ),
               h3("Vector mortality"),
               p(
                  "The app assumes constant exponential mortality: S(t) = p^t and μ = -ln(p). Real mosquito mortality and competence may depend on age; the constant-hazard approximation is retained because it is part of the classical framework explored here."
               ),
               h3("References"),
               tags$ol(
                  tags$li("Garrett-Jones, C. & Grab, B. (1964). Bull. World Health Organ. 31:71–86."),
                  tags$li("Macdonald, G. (1955). Proc. R. Soc. Med. 48(4):295–302."),
                  tags$li("Smith, D.L., et al. (2012). PLoS Pathog. 8(4):e1002588."),
                  tags$li("Brady, O.J., et al. (2016). Trans. R. Soc. Trop. Med. Hyg. 110(2):107–117.")
               )
            ),

            tabPanel(
               "Vectorial Capacity & R",
               br(),
               img(src = "Anopheles.jpg", width = 50, alt = "Anopheles mosquito"),
               h3("Definition of vectorial capacity"),
               div(
                  "The vectorial capacity of a malaria vector population is the expected rate of future potentially infectious bites generated by mosquitoes feeding on a fully infectious human, under the classical Garrett-Jones assumptions."
               ),
               em("— adapted from Garrett-Jones & Grab (1964), Bull. World Health Organ. 31:71–86."),
               br(),
               h3("Critical threshold and scenario reproduction number"),
               div(
                  "The explorer calculates R = C × b × c × D. R = 1 is the critical threshold. When parameters describe an uncontrolled, fully susceptible system, this corresponds to the classical R₀. Intervention and immunity-inspired presets should instead be interpreted as controlled or scenario reproduction numbers."
               ),
               fluidRow(
                  column(
                     width = 7,
                     plotOutput("CPlot", height = "450px"),
                     p(textOutput("criticalM")),
                     p(textOutput("criticalHBR")),
                     p(textOutput("e"))
                  ),
                  column(
                     width = 5,
                     h4("Current C, HBR, R and parameters"),
                     p(textOutput("C_current")),
                     p(textOutput("HBR_current")),
                     p(textOutput("R_current")),
                     p(textOutput("R_regime")),
                     tableOutput("summaryTable")
                  )
               )
            ),

            tabPanel(
               "Survivorship",
               br(),
               img(src = "Anopheles.jpg", width = 50, alt = "Anopheles mosquito"),
               h3("Vector survivorship under constant exponential mortality"),
               p(
                  "This plot shows the probability that a mosquito survives t days after emergence under S(t) = p^t."
               ),
               plotOutput("Survivorship"),
               p(textOutput("life_expect")),
               br(),
               h4("Interpretation"),
               tags$ul(
                  tags$li("The mortality hazard μ = -ln(p) is constant over time."),
                  tags$li("The model has no senescence or other age dependence."),
                  tags$li("The conditional remaining lifespan after any age is 1/μ because of the memoryless exponential model."),
                  tags$li("Real mosquitoes may show age-dependent mortality and transmission competence; those processes are outside this v1.0 model.")
               )
            )
         )
      )
   )
)

server <- function(input, output, session) {
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
      if (is.null(p) || p <= 0 || p >= 1) {
         return(NULL)
      }

      h <- input$h
      g <- input$g
      n <- input$n
      D <- input$D
      b <- input$b
      c <- input$c

      if (
         is.null(h) || is.null(g) || is.null(n) || is.null(D) ||
            is.null(b) || is.null(c) || g <= 0
      ) {
         return(NULL)
      }

      a <- h / g
      mu <- -log(p)

      list(
         p = p,
         h = h,
         g = g,
         n = n,
         a = a,
         D = D,
         b = b,
         c = c,
         mu = mu
      )
   })

   # Illustrative teaching presets -----------------------------------------
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

   output$criticalM <- renderText({
      par <- params()
      if (is.null(par)) {
         return("Choose valid parameters.")
      }
      if (par$a <= 0) {
         return("With a = 0 there is no human blood feeding and R = 0, so no finite critical mosquito density exists.")
      }
      if (par$b <= 0 || par$c <= 0 || par$D <= 0) {
         return("With b = 0, c = 0, or D = 0 there is no transmission (R = 0), so no finite critical mosquito density exists.")
      }
      M <- critical_vector_density(
         par$mu, par$D, par$b, par$c, par$a, par$p, par$n
      )
      paste("Critical mosquito density for R = 1 =", round(M, 2), "mosquitoes/human")
   })

   output$criticalHBR <- renderText({
      par <- params()
      if (is.null(par)) {
         return("")
      }
      if (par$a <= 0) {
         return("Critical HBR is undefined when a = 0 (R = 0).")
      }
      if (par$b <= 0 || par$c <= 0 || par$D <= 0) {
         return("Critical HBR is undefined when b = 0, c = 0, or D = 0 (R = 0).")
      }
      HBR <- critical_hbr(
         par$mu, par$D, par$b, par$c, par$a, par$p, par$n
      )
      paste("Critical human biting rate (HBR) for R = 1 =", round(HBR, 2), "bites/human/day")
   })

   output$e <- renderText({
      par <- params()
      if (is.null(par)) {
         return("")
      }
      e_inf <- par$p^par$n / par$mu
      paste(
         "Expected infectious life per mosquito at emergence =",
         round(e_inf, 2),
         "days"
      )
   })

   output$life_expect <- renderText({
      par <- params()
      if (is.null(par)) {
         return("")
      }
      e_life <- 1 / par$mu
      paste("Expected lifespan at emergence =", round(e_life, 1), "days")
   })

   output$CPlot <- renderPlot({
      par <- params()
      if (is.null(par)) {
         return()
      }

      if (par$a <= 0) {
         par(bty = "n")
         plot.new()
         title(main = "Vectorial capacity as a function of mosquito density")
         text(0.5, 0.5, "C = 0 because the human blood-feeding rate is zero")
         return()
      }

      m <- 10^seq(-2, 3, length.out = 500)
      C <- vectorial_capacity(m, par$a, par$p, par$n, par$mu)

      if (par$b > 0 && par$c > 0 && par$D > 0) {
         Ccrit <- 1 / (par$b * par$c * par$D)
         M <- critical_vector_density(
            par$mu, par$D, par$b, par$c, par$a, par$p, par$n
         )
      } else {
         Ccrit <- NA_real_
         M <- NA_real_
      }

      Cpos <- C[C > 0 & is.finite(C)]
      ymax <- max(Cpos, na.rm = TRUE) * 1.2
      ymin <- min(Cpos, na.rm = TRUE) * 0.8
      ylim <- c(ymin, ymax)

      par(bty = "n", las = 1)
      plot(
         log10(m),
         C,
         col = "darkgray",
         type = "l",
         ylim = ylim,
         log = "y",
         main = "Vectorial capacity as a function of mosquito density",
         ylab = "Vectorial capacity C (day⁻¹, log scale)",
         xlab = "Mosquitoes per human (log10 scale)"
      )

      if (!is.na(Ccrit) && Ccrit > 0) {
         abline(h = Ccrit, col = "red", lty = 2)
         text(
            x = min(log10(m)) + 0.5,
            y = Ccrit * 1.05,
            labels = "R = 1 threshold",
            col = "red",
            adj = 0
         )

         if (
            is.finite(M) && M >= min(m) && M <= max(m) &&
               Ccrit >= ymin && Ccrit <= ymax
         ) {
            arrows(
               x0 = log10(M),
               y0 = Ccrit,
               x1 = log10(M),
               y1 = ylim[1],
               col = "blue",
               lty = 3
            )
         }
      }

      if (input$m_current > 0) {
         abline(v = log10(input$m_current), col = "orange", lwd = 2)
         text(
            x = log10(input$m_current),
            y = ymax * 0.8,
            labels = "current m",
            col = "orange",
            pos = 4
         )
      }
   })

   output$Survivorship <- renderPlot({
      par <- params()
      if (is.null(par)) {
         return()
      }

      t <- 0:30
      S <- par$p^t

      par(bty = "n", las = 1)
      plot(
         t,
         S,
         type = "n",
         ylim = c(0, 1),
         main = "Survivorship",
         xlab = "Days after emergence (t)",
         ylab = "Proportion surviving after t days"
      )
      lines(t, S, col = "darkgray", lwd = 2)
   })

   c_current <- reactive({
      par <- params()
      if (is.null(par)) {
         return(NA_real_)
      }
      vectorial_capacity(
         input$m_current, par$a, par$p, par$n, par$mu
      )
   })

   hbr_current <- reactive({
      par <- params()
      if (is.null(par)) {
         return(NA_real_)
      }
      input$m_current * par$a
   })

   r_current <- reactive({
      par <- params()
      C <- c_current()
      if (is.null(par) || is.na(C)) {
         return(NA_real_)
      }
      scenario_reproduction_number(C, par$b, par$c, par$D)
   })

   output$C_current <- renderText({
      value <- c_current()
      if (is.na(value)) {
         return("Choose valid parameters to compute C and R.")
      }
      paste(
         "Current vectorial capacity C =",
         round(value, 3),
         "day⁻¹."
      )
   })

   output$HBR_current <- renderText({
      value <- hbr_current()
      if (is.na(value)) {
         return("")
      }
      paste(
         "Current human biting rate HBR =",
         round(value, 3),
         "bites/human/day."
      )
   })

   output$R_current <- renderText({
      R <- r_current()
      if (is.na(R)) {
         return("")
      }
      paste("Current scenario reproduction number R =", round(R, 2))
   })

   output$R_regime <- renderText({
      R <- r_current()
      if (is.na(R)) {
         return("")
      }

      if (R <= 0) {
         "Regime: R = 0 → no transmission under the selected parameters"
      } else if (R < 1) {
         "Regime: R < 1 → infections decline near the disease-free state"
      } else if (abs(R - 1) < 1e-8) {
         "Regime: R = 1 → critical transmission threshold"
      } else {
         "Regime: R > 1 → sustained transmission is possible under the model assumptions"
      }
   })

   output$summaryTable <- renderTable({
      par <- params()
      if (is.null(par)) {
         return(NULL)
      }

      m <- input$m_current
      C <- c_current()
      HBR <- hbr_current()
      R <- r_current()

      data.frame(
         Quantity = c(
            "Daily survival p",
            "Human-meal probability h",
            "Gonotrophic cycle g",
            "EIP n",
            "Human blood-feeding rate a = h/g",
            "Effective infectious duration D",
            "Current mosquito density m",
            "Current human biting rate HBR = ma",
            "Current vectorial capacity C",
            "Current scenario reproduction number R"
         ),
         Value = c(
            round(par$p, 3),
            round(par$h, 3),
            round(par$g, 2),
            round(par$n, 1),
            round(par$a, 3),
            round(par$D, 1),
            round(m, 1),
            signif(HBR, 3),
            signif(C, 3),
            signif(R, 3)
         ),
         Units = c(
            "probability",
            "probability",
            "days",
            "days",
            "human blood meals per mosquito per day",
            "days",
            "mosquitoes per human",
            "bites per human per day",
            "day⁻¹",
            "dimensionless"
         ),
         stringsAsFactors = FALSE
      )
   })
}

shinyApp(ui = ui, server = server)
