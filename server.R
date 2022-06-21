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
library(plotly)
paleta = c("#ff2020", "#fe3420", "#fd4320", "#fb4f1f", "#fa5a1f", "#f8631f", "#f76c1f", "#f5741f", 
            "#f37c1e", "#f1841e", "#ef8b1e", "#ed921e", "#eb991d", "#e99f1d", "#e6a61d", "#e3ac1d", 
            "#e0b31c", "#ddb91c", "#dabf1c", "#d7c51b", "#d3cb1b", "#cfd11b", "#cbd71a", "#c7dd1a", 
            "#c2e31a", "#bee819", "#b8ee19", "#b3f419", "#adf918", "#a6ff18")

# Define server logic required to draw a histogram
shinyServer(function(input, output,session) {
  
  # Funcion que lee el fichero con las opciones que hemos escogido
    
    readDf = reactive({
      df <- read.csv(input$file1$datapath,
                                      header = TRUE,
                                      sep = input$sep,
                                      quote = '"')
      return(df)
      })
  
    output$contents = DT::renderDT({
        
        # input$file1 will be NULL initially. After the user selects
        # and uploads a file, head of that data file by default,
        # or all rows if selected, will be shown.
        
        req(input$file1)
        
        df <- readDf()
        
        DT::datatable(df,
                      #option = list(dom = 't'),
                      rownames = F,
                      selection = list(mode = 'single',
                                       target = 'column'))
        
        
        
    })
    
        # Funcion que calcula la curva ROC
    ROC = reactive({

      df = readDf()
      req(input$contents_columns_selected)
      index = input$contents_columns_selected + 1 # se obtiene el indice de la columna selecciona y se le suma 1 (sale uno menos siempre)
      
      df[,index] = as.factor(df[,index])
      df[,index] = ifelse(df[,index] == 1, 'pos', 'neg') # se cambian los 0 y 1 por neg y pos
      
      control = trainControl(method = 'cv',
                             number = input$n)
      
      model = train(x = df[,-index],
                    y = df[,index],
                    method = input$modelo,
                    trControl = control)
      pred = predict(model, df, type = 'prob')
      curva <- roc(df[,index], pred$pos)
      return(curva)
      
    })
    
    output$multiROC = renderPlot({
      if(input$b2){
      df = readDf()
      req(input$contents_columns_selected)
      index = input$contents_columns_selected + 1 # se obtiene el indice de la columna selecciona y se le suma 1 (sale uno menos siempre)
      
      df[,index] = as.factor(df[,index])
      df[,index] = ifelse(df[,index] == 1, 'pos', 'neg') # se cambian los 0 y 1 por neg y pos
      
      control = isolate(trainControl(method = 'cv',
                             number = input$n2))
      choosen_colors = c()
      for (i in 1:length(input$varios_modelos)){
        model = isolate(train(x = df[,-index],
                      y = df[,index],
                      method = input$varios_modelos[i],
                      trControl = control))
        pred = isolate(predict(model, df, type = 'prob'))
        if (i == 1){
          col_i = sample.int(30, 1)
          choosen_colors = c(choosen_colors, paleta[col_i])
          isolate(plot.roc(df[,index], pred$pos, col = paleta[col_i]))
        }
        col_i = sample.int(30, 1)
        choosen_colors = c(choosen_colors, paleta[col_i])
        isolate(lines.roc(df[,index], pred$pos, col = paleta[col_i]))
        
        if (i == length(input$varios_modelos)){
          isolate(legend("bottomright", legend=input$varios_modelos, col=choosen_colors, lwd=2))
        }
      }
      }
      
      
    })

              # Funcion que dibuja la curva ROC pasandole la funcion de ROC anterior
    output$plotROC = renderPlot({
      if(input$b1){   # el if es para que se ejecute cuando se aprete el boton, al igual que el isolate()
      req(input$contents_columns_selected)
      curva = isolate(ROC())
      return(plot(curva, col = "#00a8a8"))
      }
    })
    
    # output$info1 = renderInfoBox({
    #   curva = ROC()
    #   infoBox("AUC", col = "orange",round(curva$auc[1],3), icon = icon("area-chart"))
    # })
    
    output$infoBox <- renderValueBox({
      if(input$b1){
      curva = isolate(ROC())
      valueBox(
        value = round(curva$auc[1],3),
        subtitle = "AUC",
        icon=icon("chart-area"),
        color="orange") 
      }
    })

  
})
