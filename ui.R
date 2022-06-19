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



shinyUI(dashboardPage(
    dashboardHeader(title = "Hacedor de curvas ROC y AUC",
                    titleWidth = 350),
    dashboardSidebar(width = 350,
                     sidebarMenu(
        menuItem("Import", tabName = "import", icon = icon("folder-open",lib = "glyphicon")),
        menuItem("Models", tabName = "choosing_model", icon = icon("blackboard",lib = "glyphicon"))
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

                                    ")),
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
        tabItems(
            tabItem(tabName = "import",
                    box(
                        title = "Import CSV",
                        width = 4,
                        status = "primary",
                        solidHeader = T,
                        collapsible = T,
                        
                        fileInput("file1", "Choose CSV File",
                                  multiple = F,
                                  accept = c("text/csv",
                                             "text/comma-separated-values,text/plain",
                                             ".csv")),
                        tags$hr(),
                        radioButtons("sep", "Separator",
                                     choices = c(Comma = ",",
                                                 Semicolon = ";",
                                                 Tab = "\t"),
                                     selected = ","),
                        tags$hr()
                        ),
                    box(title = "Data head",
                        width = 8,
                        status = "success",
                        solidHeader = T,
                        collapsible = T,
                        tableOutput("contents"))),
            
            tabItem(tabName = "choosing_model",
                    box(
                        title = "Models",
                        width = 2,
                        status = "primary",
                        solidHeader = T,
                        
                        pickerInput(
                            inputId = "modelo",
                            label = "Choose a model",
                            choices = c("svmLinear3","bayesglm", "rf","xgbLinear","bagEarth",
                                                 "treebag","ctree","glm","lm","ranger","cubist","knn"),
                            selected = c("svmLinear3"),
                            multiple = FALSE)),
                    
                    fluidRow(
                        tabBox(id="tabchart1",side = "right",
                               tabPanel("ROC", plotOutput("ROC")),
                               tabPanel("AUC", plotlyOutput("plot_AUC")),
                        )
                    )
                        
                
                )
            )
    )
    )
    )
