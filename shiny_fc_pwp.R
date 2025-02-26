
# librerias ---------------------------------------------------------------

library(shiny)

# server shiny ------------------------------------------------------------
#Función
server <- function(input, output) {

  #Gupta and Larson Calibrated
  WR = function(sd,st,cl,om,bd) {
    wrfc = -0.57804 + (0.00575*sd) + (0.01013*st) + (0.00873*cl) + (0.00802*om) + (0.06254*bd)
    wrpwp = -0.00831 + 0.00029*sd + 0.00257*st + 0.00326*cl + 0.00371*om + 0.01121*bd
    res = c(wrfc,wrpwp)
  }

  #FC
  output$WRfc <- renderText({
    #Get inputs
    sd = input$sd
    st = input$st
    cl = input$cl
    om = input$om
    bd = input$bd
    res = round(WR(sd,st,cl,om,bd)[1],4)
  })

  #PWP
  output$WRpwp <- renderText({
    #Get inputs
    sd = input$sd
    st = input$st
    cl = input$cl
    om = input$om
    bd = input$bd
    res = round(WR(sd,st,cl,om,bd)[2],4)
  })

}

# user interface ----------------------------------------------------------

ui <- shinyUI(fluidPage(

  titlePanel("Modelo de regresión para FC y PWP para suelos chilenos"),

  sidebarLayout(
    sidebarPanel(
      sliderInput('sd','Sand',min=0,max=100,value=33,step=0.01),
      sliderInput('st','Silt',min=0,max=100,value=33,step=0.01),
      sliderInput('cl','Clay',min=0,max=100,value=33,step=0.01),
      sliderInput('om','Organic Matter',min=0,max=25,value=2,step=0.01),
      sliderInput('bd','Bulk Density',min=0,max=2,value=1.3,step=0.01),
      hr(),
      p('Para más detalle del desarrolo de este modelo, ver repositorio:',
        a("Sara Acevedo y Agustín Coddou",
          href = "https://github.com/acoddou/shiny_shp")),
      hr()
    ),

    mainPanel(
      p('Field Capacity'),
      textOutput("WRfc"),
      hr(),
      p('Permanent Wilting Point'),
      textOutput("WRpwp"),
      hr()
    )
  )
))

# Correr Shinyapp ---------------------------------------------------------

shinyApp(ui = ui, server = server)
