#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

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
                     value = 0.75),
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
                     step = 0.1),
         sliderInput("n",
                     "Duration of parasite extrinsic cycle (days)",
                     min = 8,
                     max = 50,
                     value = 10,
                     step = 1)
      ),
      
      # Show a plot of the generated model output
      mainPanel(
        plotOutput("Survivorship"),
        p(textOutput("life_expect")),
        plotOutput("CPlot"),
        p(textOutput("criticalM")),
        p(textOutput("criticalMA")),
        p(textOutput("e"))
         )
   )
)

# Define server logic required to draw plot of vectorial capacity
server <- function(input, output) {
   
   output$criticalM <- renderText({
      a  <- input$h/input$g
      M <- -log(input$p) / ( a^2 * input$p^input$n )
      return(paste("Critical density for stable transmission (blue arrow) =", round(M, 2), "vectors/host"))
   })
   
   output$criticalMA <- renderText({
      a  <- input$h/input$g
      MA <- -log(input$p) / ( a * input$p^input$n)
      return(paste("Critical biting rate for stable transmission (green arrow) =", round(MA, 2), "bites/host"))
   })
   
   output$e <- renderText({
     e <- input$p^input$n / -log(input$p)
     return(paste("Expectation of infective life =", round(e, 1), "days"))
   })
   
   output$life_expect <- renderText({
     e <- 1 / -log(input$p)
     return(paste("Expectation of lifespan at emergence =", round(e, 1), "days"))
   })
   
   output$CPlot <- renderPlot({
     # generate model output based on input parameters from ui.R
     m  <- seq(0.01, 1e4, 0.001)
     a  <- input$h/input$g
     C  <- ( m * a^2 * input$p^input$n) / -log(input$p )
     M <- -log(input$p) / ( a^2 * input$p^input$n ) # critical m for stability
     MA <- -log(input$p) / ( a * input$p^input$n ) # critical ma for stability
     
     # draw a plot with the specified parameters
     par(bty = "n", las = 1)
     plot(log10(m), C,
          col = 'darkgray',
          type = "l",
          ylim = c(0, 2),
          main = "Vectorial Capacity",
          ylab = "Vectorial Capacity",
          xlab = "No. vectors/host (log-scale)")
     abline(h = 1, col = "red", lty = 2)
     text(90, 1, "threshold of stability")
     arrows(x0 = log10(M), y0 = 1, x = log10(M), y = 0, col = "blue", lty = 3)
     arrows(x0 = log10(MA), y0 = 1, x = log10(MA), y = 0, col = "dark green", lty = 3)
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