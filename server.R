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
library(shinycustomloader)
library(plotly)
library(party)
library(arm)
library(earth)
library(randomForest)
library(xgboost)


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
  
    modifiedDf = reactive({
      index = input$contents_columns_selected + 1
      df = readDf()
      c = c()
      u = c()
      for (i in df[,index]){
        
        c = c(c,i)
        u = unique(c)
        
      }
      
      df[,index] = ifelse(df[,index] == u[1], 0, 1)
      dummy <- dummyVars(" ~ .", data=df)
      df = data.frame(predict(dummy, newdata=df))
      
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

      df = modifiedDf()
      req(input$contents_columns_selected)
      index = input$contents_columns_selected + 1 # se obtiene el indice de la columna selecciona y se le suma 1 (sale uno menos siempre)
      
      df[,index] = as.factor(df[,index])
      df[,index] = ifelse(df[,index] == 1, 'pos', 'neg') # se cambian los 0 y 1 por neg y pos
      
      if (input$b1){
        
      
      if (input$costs == 'with_costs'){
        
        coste_caret = function(data, lev = c('pos', 'neg'), model = NULL){
          cost = 0
          for (i in 1:nrow(data)){
            #data$amount = as.numeric(tr$amount)
            if (data[i,'obs'] == 'pos'){
              if (data[i,'pred'] == 'pos'){
                cost = cost + input$c1n1 #TP
              } else {
                cost = cost + input$c1n2 #FN
              }
            } else {
              if (data[i,'pred'] == 'pos'){
                cost = cost + input$c2n1 #FP
              } else {
                cost = cost + input$c2n2 #TN
              }
            }
          }
          names(cost) = c('Coste')
          cost
        }
        
        control = trainControl(method = 'cv',
                               number = input$n,
                               summaryFunction = coste_caret)
        
      } else {
        control = trainControl(method = 'cv',
                               number = input$n)
      }
      
      model = train(x = df[,-index],
                    y = df[,index],
                    method = input$modelo,
                    trControl = control)
    }
      return(model)
      
      
    })
    
    curva = reactive({
      index = input$contents_columns_selected + 1
      df = modifiedDf()
      model = ROC()
      pred = predict(model, df, type = 'prob')
      curva <- roc(df[,index], pred$pos)
      return(curva)
    })
    
    pred_with_costs = reactive({
      index = input$contents_columns_selected + 1
      df = modifiedDf()
      model = ROC()
      df[,index] = as.factor(df[,index])
      df[,index] = ifelse(df[,index] == 1, 'pos', 'neg')
      pred_with_cost = cbind(df[index], predict(model, df))
      colnames(pred_with_cost) = c('obs', 'pred')
      return(pred_with_cost)
      
      })
    
    coste_accuracy = reactive({
      coste_accuracy<-cost_caret()
      return(coste_accuracy)
    })
    
    cost_caret = reactive({
      data = pred_with_costs()
      cost = 0
      for (i in 1:nrow(data)){
        #data$amount = as.numeric(tr$amount)
        if (data[i,'obs'] == 'pos'){
          if (data[i,'pred'] == 'pos'){
            cost = cost + input$c1n1 #TP
          } else {
            cost = cost + input$c1n2 #FN
          }
        } else {
          if (data[i,'pred'] == 'pos'){
            cost = cost + input$c2n1 #FP
          } else {
            cost = cost + input$c2n2 #TN
          }
        }
      }
      names(cost) = c('Coste')
      return(cost)
    })
    
    output$multiROC = renderPlot({
      if(input$b2){
      df = isolate(modifiedDf())
      isolate(req(input$contents_columns_selected))
      index = isolate(input$contents_columns_selected + 1) # se obtiene el indice de la columna selecciona y se le suma 1 (sale uno menos siempre)
      
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
      curva = isolate(curva())
      return(plot(curva, col = "#00a8a8"))
      }
    })
    
    
    output$infoBox <- renderValueBox({
      if(input$b1){
      curva = isolate(curva())
      valueBox(
        value = round(curva$auc[1],3),
        subtitle = "AUC",
        icon=icon("chart-area"),
        color="orange") 
      }
    })
    
    output$infoBox1 <- renderValueBox({
      if(input$b1){
        valor = 'Without costs'
        if (input$costs == "with_costs"){
          model = isolate(ROC())
          valor = isolate(min(model$results[,"Coste"]))
        }
        else if (input$costs == "with_accur"){
            valor = isolate(coste_accuracy())
          }
        
        valueBox(
          value = valor,
          subtitle = "Costs",
          icon=icon("dollar"),
          color="red") 
      }
    })
    
    
  
    observeEvent("", {
      showModal(modalDialog(
        includeHTML("intro_text.html"),
        easyClose = TRUE,
        footer = tagList(
          actionButton(inputId = "intro", label = "INTRODUCTION TOUR", icon = icon("info-circle"))
        )
      ))
    })
    
    observeEvent(input$intro,{
      removeModal()
    })
    
    # show intro tour
    observeEvent(input$intro,
                 introjs(session, options = list("nextLabel" = "Continue",
                                                 "prevLabel" = "Previous",
                                                 "doneLabel" = "Alright. Let's go"))
    )
    
    observe({
      if (input$costs == "without_costs"){
        shinyjs::hide("value")
        return()
      }
      
      isolate({
        shinyjs::show("value")
        output$value <-renderTable({
          pos <- paste0("<input id='c1n", 1:2, "' class='shiny-bound-input' type='number' value='0'>")
          neg <- paste0("<input id='c2n", 1:2, "' class='shiny-bound-input' type='number' value='0'>")
          data.frame(pos, neg)
          
        }, sanitize.text.function = function(x) x)
      })
    })

    
  
})
