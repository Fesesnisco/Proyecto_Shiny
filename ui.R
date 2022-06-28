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
library(shinycustomloader)
library(plotly)
library(shinyBS)
library(shinyjs)
library(rintrojs)
library(party)
library(arm)
library(earth)
library(randomForest)
library(xgboost)
library(shinyMatrix)


shinyUI(dashboardPage(
    dashboardHeader(title = "poli[Clasificador]",
                    titleWidth = 200,
                    dropdownMenu(
                        type = "notifications", 
                        headerText = strong("HELP"), 
                        icon = icon("question"), 
                        badgeStatus = NULL,
                        notificationItem(
                            text = ('Import a file in CSV format by clicking on the browse button.'),
                            icon = icon("upload")
                        ),
                        notificationItem(
                            text = ('Choose the type of separator your csv file uses.'),
                            icon = icon("asterisk")
                        ),
                        notificationItem(
                            text = ('You will be able to visualise the resulting data table. Select the column you are going to use as Y variable.'),
                            icon = icon("hdd",lib = "glyphicon")
                        ),
                        notificationItem(
                            text = ('Now we can move on to the models. Click on Models.'),
                            icon = icon("tasks")
                        ),
                        notificationItem(
                            text = ('One model: choose a model, the k-fold for the cross validation and click on the Start button. The ROC curve and the AUC obtained are shown.'),
                            icon = icon("sitemap")
                        ),
                        notificationItem(
                            text = ('In case you want to use costs for the model, select the desired cost option and enter the required values in the cost matrix.'),
                            icon = icon("dollar")
                        ),
                        notificationItem(
                            text = ('Comparing models: choose more than one model and the k-fold for the cross-validation. Click on the Start button and a plot with the ROC curves of each model is displayed.'),
                            icon = icon("sitemap")
                        )),
                    tags$li(class="dropdown",tags$a(href="https://github.com/Fesesnisco/Proyecto_Shiny", icon("github"), "Source Code", target="_blank"))),
    dashboardSidebar(width = 200,
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
        useShinyjs(),
        introjsUI(),
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
                       HTML("@import url(https://use.fontawesome.com/releases/v6.0.0/css/all.css);")
                       ),
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    
        tabItems(
            tabItem(tabName = "import",
                    introBox(
                        data.step = 1,
                        data.intro = "You can preview your visual abstract here.",
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
                                   introBox(
                                       data.step = 1,
                                       data.intro = "Import a file in CSV format by clicking on the browse button.",
                                       fileInput("file1", "Choose CSV File",
                                                 multiple = F,
                                                 accept = c("text/csv",
                                                            "text/comma-separated-values,text/plain",
                                                            ".csv")))),
                            column(6,
                                   introBox(
                                       data.step = 2,
                                       data.intro = "Choose the type of separator your csv file uses.",
                                   radioButtons("sep", "Separator",
                                                choices = c(Comma = ",",
                                                            Semicolon = ";",
                                                            Tab = "\t"),
                                                selected = ","))))
                        )),
                    box(title = "Data head",
                        width = 12,
                        status = "success",
                        solidHeader = T,
                        collapsible = T,
                        
                        fluidRow(
                            column(12,
                                   introBox(
                                       data.step = 3,
                                       data.intro = "Once the file has been uploaded, select the column you are going to use as Y variable.",  
                                       DT::DTOutput("contents")))))),
            
            tabItem(tabName = "choosing_model",
                    fluidRow(
                        column(12,
                               box(
                                   title = "Settings",
                                   width = 3,
                                   status = "primary",
                                   solidHeader = T,
                                   
                                   tabsetPanel(
                                       tabPanel("Models",
                                                pickerInput(
                                                    inputId = "modelo",
                                                    label = "Choose a model",
                                                    choices = c("bayesglm", "rf","xgbLinear","bagEarth",
                                                                "treebag","ctree","glm","knn"),
                                                    selected = c("ctree"),
                                                    multiple = FALSE),
                                                
                                                numericInput("n", "Choose k-fold for cross-validation", 10),
                                                actionButton("b1", "Start", icon = icon('play'),
                                                             style="color: #fff; background-color: #00a8a8; border-color: #00a8a8")
                                                ),
                                       tabPanel("Costs", 
                                                radioButtons("costs", "Select:",
                                                             choices = c("Without costs" = "without_costs",
                                                                         "Model costs trained with accuracy" = "with_accur",
                                                                         "Model costs trained with costs" = "with_costs" ),
                                                             selected = "without_costs"),
                                                br(),
                                                matrixInput(
                                                    "matrix",
                                                    value = matrix(dimnames=list(c('P Predicted','N Predicted'), c('P Real','N Real')), nrow=2,ncol=2, data=c(0,0,0,0)),
                                                    rows = list(names=T),
                                                    cols = list(names=T),
                                                    class='numeric'
                                                ),
                                                )
                                       )
                                   ),
                               box(
                                   title="ROC Curve",
                                   width = 6,
                                   status = "primary",
                                   solidHeader = T,
                                   tabPanel("ROC", withLoader(plotOutput("plotROC"), type = 'html',loader = 'loader1')),
                                   
                                   ),
                               valueBoxOutput("infoBox", width = 3),
                               valueBoxOutput("infoBox1", width = 3),
                               
                               )
                        ), 
                        
                    
                    
                        
                
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
                            tabPanel("ROC", withLoader(plotOutput("multiROC"), type = 'html',loader = 'loader1')),
                            
                        ),
                        valueBoxOutput("infoBox2", width = 3)
                    )
                    
                    
            )
            )
    )
    )
    )
