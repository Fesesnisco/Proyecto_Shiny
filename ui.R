#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinyWidgets)
library(shinydashboard)
library(plotly)
library(shinyBS)



shinyUI(dashboardPage(
    dashboardHeader(title = "Hacedor de curvas ROC y AUC",
                    titleWidth = 350),
    dashboardSidebar(width = 350,
                     sidebarMenu(
        menuItem("Import", tabName = "import", icon = icon("folder-open",lib = "glyphicon")),
        menuItem("Models", icon = icon('tasks'),
                 
                 menuSubItem('One model',
                             tabName = 'choosing_model',
                             icon = icon('sitemap')),
                 menuSubItem('Comparing models',
                             tabName = 'comparing_model',
                             icon = icon('sitemap')))
    )),
    dashboardBody(
        tags$head(
            # Formato de las box
            tags$style(HTML("
            .box.box-solid.box-primary>.box-header {
            color:white;
            background:#00a8a8
            }
            
            .box.box-solid.box-primary{
            border-bottom-color:#00a8a8;
            border-left-color:#00a8a8;
            border-right-color:#00a8a8;
            border-top-color:#00a8a8;
            }
            
            .box.box-solid.box-success>.box-header {
            color:white;
            background:#FF8000
            }
            
            .box.box-solid.box-success{
            border-bottom-color:#FF8000;
            border-left-color:#FF8000;
            border-right-color:#FF8000;
            border-top-color:#FF8000;
            }
            
            .wrapper {
            height: auto !important; 
            position:relative; 
            overflow-x:hidden; 
            overflow-y:hidden;
            }

                                    "),
                       "@import url(https://use.fontawesome.com/releases/v5.7.2/css/all.css);"
                       ),
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
        tabItems(
            tabItem(tabName = "import",
                    box(
                        title = "Import CSV",
                        width = 12,
                        status = "primary",
                        solidHeader = T,
                        collapsible = T,
                        
                        fluidRow(
                            column(3, h4(icon("upload"), "Upload"))), 
                        
                        fluidRow(
                            column(6,
                                   fileInput("file1", "Choose CSV File",
                                                    multiple = F,
                                                    accept = c("text/csv",
                                                               "text/comma-separated-values,text/plain",
                                                               ".csv"))),
                            column(6,
                                   radioButtons("sep", "Separator",
                                                choices = c(Comma = ",",
                                                            Semicolon = ";",
                                                            Tab = "\t"),
                                                selected = ",")))
                        ),
                    box(title = "Data head",
                        width = 12,
                        status = "success",
                        solidHeader = T,
                        collapsible = T,
                        
                        fluidRow(
                            column(12,
                                DT::DTOutput("contents"))))),
            
            tabItem(tabName = "choosing_model",
                    box(
                        title = "Models",
                        width = 3,
                        status = "primary",
                        solidHeader = T,
                        
                        pickerInput(
                            inputId = "modelo",
                            label = "Choose a model",
                            choices = c("bayesglm", "rf","xgbLinear","bagEarth","treebag","ctree","glm","knn"),
                            selected = c("ctree"),
                            multiple = FALSE),
                        numericInput("n", "Choose k-fold for cross-validation", 10),
                        actionButton("b1", "Start", icon = icon('play'),
                                     style="color: #fff; background-color: #00a8a8; border-color: #00a8a8")),
                    
                    fluidRow(
                        box(title="ROC Curve",
                            width = 5,
                            status = "primary",
                            solidHeader = T,
                            tabPanel("ROC", plotOutput("plotROC")),
                               
                        ),
                        valueBoxOutput("infoBox", width = 3)
                    )
                        
                
                ),
            tabItem(tabName = "comparing_model",
                    box(
                        title = "Models",
                        width = 3,
                        status = "primary",
                        solidHeader = T,
                        
                        pickerInput(
                            inputId = "varios_modelos",
                            label = "Choose minimum two models",
                            choices = c("bayesglm", "rf","xgbLinear","bagEarth","treebag","ctree","glm","knn"),
                            selected = c("ctree"),
                            multiple = TRUE),
                        numericInput("n2", "Choose k-fold for cross-validation", 10),
                        actionButton("b2", "Start", icon = icon('play'),
                                     style="color: #fff; background-color: #00a8a8; border-color: #00a8a8")),
                    
                    fluidRow(
                        box(title="ROC Curve",
                            width = 8,
                            status = "primary",
                            solidHeader = T,
                            tabPanel("ROC", plotOutput("multiROC")),
                            
                        ),
                        valueBoxOutput("infoBox2", width = 3)
                    )
                    
                    
            )
            )
    )
    )
    )
