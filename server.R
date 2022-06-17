#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(caret)
library(pROC)
library(ModelMetrics)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$contents = renderTable({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file1)
        
        df <- read.csv(input$file1$datapath,
                       header = TRUE,
                       sep = input$sep,
                       quote = '"')
    })
    
    output$ROC = renderPlot({
      
      library(mlbench)
      data('PimaIndiansDiabetes')
      df = PimaIndiansDiabetes
      
      control = trainControl(method = 'cv',
                             number = 10)
      
      model = train(diabetes ~ .,
                    data = df,
                    method = 'ctree',
                    trControl = control)
      pred = predict(model, df, type = 'prob')
      curva <- roc(df$diabetes, pred$pos)
      plot(curva, col = "blue")
    })
    
})
