# Librerías
library(shiny)
library(parsnip)  # Para usar los modelos entrenados
library(ranger) #para evitar error en logs de shiny

# Server Shiny ------------------------------------------------------------
server <- function(input, output) {
  modelo_fc <- readRDS("modelo_fc.rds")
  modelo_pwp <- readRDS("modelo_pwp.rds")
  
  # Predicción de Field Capacity (FC)
  output$WRfc <- renderText({
    # Obtener inputs del usuario
    new_data <- data.frame(
      sand = input$sd,
      silt = input$st,
      clay = input$cl,
      bulk_density = input$bd,
      organic_matter = input$om
    )
    
    # Realizar la predicción
    pred_fc <- predict(modelo_fc, new_data)$.pred
    
    # Redondear resultado y mostrar
    round(pred_fc, 4)
  })
  
  # Predicción de Permanent Wilting Point (PWP)
  output$WRpwp <- renderText({
    # Obtener inputs del usuario
    new_data <- data.frame(
      sand = input$sd,
      silt = input$st,
      clay = input$cl,
      bulk_density = input$bd,
      organic_matter = input$om
    )
    
    # Realizar la predicción
    pred_pwp <- predict(modelo_pwp, new_data)$.pred
    
    # Redondear resultado y mostrar
    round(pred_pwp, 4)
  })
}

# User Interface ----------------------------------------------------------
ui <- shinyUI(fluidPage(
  
  titlePanel("Modelo de regresión para FC y PWP para suelos chilenos"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput('sd', 'Sand', min = 0, max = 100, value = 33, step = 0.01),
      sliderInput('st', 'Silt', min = 0, max = 100, value = 33, step = 0.01),
      sliderInput('cl', 'Clay', min = 0, max = 100, value = 33, step = 0.01),
      sliderInput('om', 'Organic Matter', min = 0, max = 25, value = 2, step = 0.01),
      sliderInput('bd', 'Bulk Density', min = 0, max = 2, value = 1.3, step = 0.01),
      hr(),
      p('Para más detalle del desarrollo de este modelo, ver repositorio:',
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

# Correr ShinyApp ---------------------------------------------------------
shinyApp(ui = ui, server = server)
