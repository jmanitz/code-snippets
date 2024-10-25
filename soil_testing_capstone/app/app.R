library(plotly)
library(tidyverse)
library(shiny)
library(bslib)

# Define Optimum values for reference 
elmts <- c("Nitrogen (N)","Phosphorus (P)","Potassium (K)")
ref <- data.frame(
  id = "optimum", element = elmts, 
  value=c(120, 8, 130), low=c(110, 4, 100), high=c(130,14,160)
)


# Define UI ----
ui <- #page_sidebar(
  pageWithSidebar(
    headerPanel('Soil Test Analysis'),
    sidebarPanel(
      fileInput('data', 'Choose csv file:', accept='csv'),
      numericInput('nitr', 'Nitrogen (N)', 85, min = 1, max = 200),
      numericInput('phos', 'Phosphorus (P)', 76, min = 1, max = 200),
      numericInput('pota', 'Potassium (K)', 308, min = 1, max = 500), 
      numericInput('ph', 'pH value', 7, min = 1, max = 14)
    ),

    mainPanel(
      plotlyOutput('NPKplot'),
      plotlyOutput('pHplot')
    )
  )
  
# Define server logic ----
server <- function(input, output) { #  function(input, output, session) {

  # <TODO> Load data set as csv
  # Combine the selected variables into a new data frame
  dt <- reactive({
#    if(is.null(input$data)){
      data.frame(
        id = rep("sample 1", times=3), element = elmts, 
        value = c(input$nitr, input$phos, input$pota), low=NA, high=NA
      )
#    }else{input$data}
  })
  
  # NPKplot <- reactive({
  # })

  output$NPKplot <- renderPlotly({
    rbind(dt(), ref) %>% 
      ggplot(aes(x=element, y=value, fill=id, label=value)) +  
      geom_bar(stat="identity", position=position_dodge()) +
      #geom_text(position=position_dodge()) + # add numbers to top of the bar
      geom_errorbar(aes(ymin=low, ymax=high), width=.2, position=position_dodge(.9)) + 
      scale_fill_paletteer_d("ggthemes::excel_Crop") + 
      labs(title="NPK Macronutrients", x="Macronutirent", y="Test Value", fill="" ) + 
      theme_minimal()
    
    # <TODO> Make graphics interactive 
    #ggplotly(NPKplot())
  })
  
  output$pHplot <- renderPlotly({
    # <TODO> plotly does show in shiny output
    plot_ly( 
      type = "indicator", mode = "gauge+number+delta", #
      #title = list(text = "Soil pH", font = list(size = 24)),
      value = 6.4,
      delta = list(reference = 7, increasing = list(color = "deeppink"), decreasing = list(color = "deeppink")),
      gauge = list(
        axis = list(range = list(NULL, 14), tickwidth = 0.2, tickcolor = "darkgray"),
        bar = list(color = "darkgray", thickness = 0.2),bgcolor = "white", borderwidth = 2, bordercolor = "gray",
        threshold = list(line = list(color = "deeppink", width = 7), thickness = 1, value = 7),
        steps = list(
          list(range = c(0,1), color="tomato"),
          list(range = c(1,2), color="coral"),
          list(range = c(2,3), color="orange"),
          list(range = c(3,4), color="gold"),
          list(range = c(4,5), color="yellow"),
          list(range = c(5,6), color="greenyellow"),
          list(range = c(6,7), color="limegreen"),
          list(range = c(7,8), color="forestgreen"), #"seagreen3"),
          list(range = c(8,9), color="darkcyan"), 
          list(range = c(9,10),color="steelblue"),       
          list(range = c(10,11),color="royalblue"),
          list(range = c(11,12),color="slateblue"),
          list(range = c(12,13),color="RebeccaPurple"),
          list(range = c(13,14),color="indigo")))) %>%
      layout(margin = list(l=20,r=30), font = list(color = "darkblue", family = "Arial"))
  })
    
}

# Run the app ----
shinyApp(ui = ui, server = server)
