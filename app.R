#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
# Calculation of vectorial capacity according to Garett-Jones (1964)

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Vectorial Capacity"),
   
   # Sidebar with a slider input for parameters 
   sidebarLayout(
      sidebarPanel(
         sliderInput("p",
                     "Daily probability of survival",
                     min = 0,
                     max = 1,
                     value = 0.8),
         sliderInput("h",
                     "Probability of feeding on host",
                     min = 0,
                     max = 1,
                     value = 0.5),
         sliderInput("g",
                     "Duration of gonotrophic cycle (days)",
                     min = 1,
                     max = 6,
                     value = 2.5,
                     step = 0.5),
         sliderInput("n",
                     "Duration of parasite extrinsic incubation period (days)",
                     min = 8,
                     max = 50,
                     value = 12,
                     step = 1)
      ),
      
      # Show a plot of the generated model output
      mainPanel(
        img(src = "Anopheles.jpg", width = 50),
        h3("Definition of vectorial capacity"),
        div("The vectorial capacity of a malaria vector population is defined as the average number of inoculations
            with a specified (Plasmodium) parasite, originating from one case of malaria in unit time,
            that the population would distribute to humans if all the vectors biting the case became infected."),
        em("---Garrett-Jones, C. & Grab, B. (1964) Bull. Wld. Hlth. Org. 31:71-86."),
        br(),
        h3("Critical threshold for endemicity"),
        div("We use the Macdonald model, according to which endemic level reaches zero when vectorial capacity equals
            the duration of infective gametocytaemia. In non-immune persons this value is estimated at 80 days for P. falciparum."),
        em("---Macdonald, G. (1955) Proc. Roy. Soc. Med. 48:295-301."),
        plotOutput("CPlot"),
        p(textOutput("criticalM")),
        p(textOutput("criticalMA")),
        p(textOutput("e")),
        br(),
        plotOutput("Survivorship"),
        p(textOutput("life_expect"))
         )
   )
)

# Define server logic required to draw plot of vectorial capacity
server <- function(input, output) {
   
   output$criticalM <- renderText({
      a  <- input$h/input$g
      r <- 80
      M <- -log(input$p) / ( r * a^2 * input$p^input$n )
      return(paste("Critical density for stable transmission (blue arrow) =", round(M, 2), "vectors/host"))
   })
   
   output$criticalMA <- renderText({
      a  <- input$h/input$g
      r <- 80
      MA <- -log(input$p) / ( r * a * input$p^input$n)
      return(paste("Critical biting rate for stable transmission (green arrow) =", round(MA, 2), "bites/day (on host)"))
   })
   
   output$e <- renderText({
     e <- input$p^input$n / -log(input$p)
     return(paste("Expectation of infective life =", round(e, 2), "days"))
   })
   
   output$life_expect <- renderText({
     e <- 1 / -log(input$p)
     return(paste("Expectation of lifespan at emergence =", round(e, 1), "days"))
   })
   
   output$CPlot <- renderPlot({
     # generate model output based on input parameters from ui.R
     m  <- seq(0.01, 1e4, 0.001)
     r <- 80
     a  <- input$h/input$g
     C  <- ( m * a^2 * input$p^input$n) / -log(input$p )
     M <- -log(input$p) / ( r * a^2 * input$p^input$n ) # critical m for stability
     MA <- -log(input$p) / ( r * a * input$p^input$n ) # critical ma for stability
     
     # draw a plot with the specified parameters
     par(bty = "n", las = 1)
     plot(log10(m), C,
          col = 'darkgray',
          type = "l",
          ylim = c(0, 0.1),
          main = "Vectorial Capacity",
          ylab = "Vectorial Capacity",
          xlab = "No. vectors/host (log-scale)")
     abline(h = 1/r, col = "red", lty = 2)
     text(3, 1/100, "threshold of stability")
     arrows(x0 = log10(M), y0 = 1/r, x = log10(M), y = 0, col = "blue", lty = 3)
     arrows(x0 = log10(MA), y0 = 1/r, x = log10(MA), y = 0, col = "dark green", lty = 3)
   })
   
   output$Survivorship <- renderPlot({
     # days after emergence (1 month)
     t <- 0:30
     
     # survival plot
     par(bty = "n", las = 1)
     plot(t, input$p^t,
          type = "n",
          main = "Survivorship",
          xlab = "No. days after emergence (t)",
          ylab = "Proportion surviving after t days")
     lines(t, input$p^t, col = 'darkgray')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)