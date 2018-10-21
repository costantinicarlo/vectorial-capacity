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
                     "Daily probability of survival:",
                     min = 0,
                     max = 1,
                     value = 0.75),
         sliderInput("h",
                     "Probability of feeding on host:",
                     min = 0,
                     max = 1,
                     value = 0.5),
         sliderInput("g",
                     "Duration of gonotrophic cycle:",
                     min = 1,
                     max = 10,
                     value = 3)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("CPlot")
      )
   )
)

# Define server logic required to draw plot of vectorial capacity
server <- function(input, output) {
   
   output$CPlot <- renderPlot({
      # generate model output based on input parameters from ui.R
      m    <- 0:100
      a    <- input$h/input$g
      n    <- 8:12
      C    <- vector(mode = "list", length = length(n))
      for(i in 1:5) {C[[i]] <- (m*a*input$p^n[i])/-log(input$p)}
      
      # draw a plot with the specified parameters
      par(bty = "n", las = 1)
      plot(m, C[[1]], col = 'darkgray', type = "l", ylab = "Vectorial Capacity", xlab = "No. vectors / host")
      lines(m, C[[2]], col = 'darkgray')
      lines(m, C[[3]], col = 'darkgray')
      lines(m, C[[4]], col = 'darkgray')
      lines(m, C[[5]], col = 'darkgray')
      abline(h = 1, col = "red", lty = 2)
      text(100, C[[1]][100], "n=8")
      text(100, C[[2]][100], "n=9")
      text(100, C[[3]][100], "n=10")
      text(100, C[[4]][100], "n=11")
      text(100, C[[5]][100], "n=12")
      text(90, 1, "threshold of stability")
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

