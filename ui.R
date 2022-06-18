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



shinyUI(dashboardPage(
    dashboardHeader(title = "Hacedor de curvas ROC y AUC"),
    dashboardSidebar(sidebarMenu(
        menuItem("Import", tabName = "import", icon = icon("dashboard")),
        menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )),
    dashboardBody(
        tabItems(
            tabItem(tabName = "import",
                    fluidRow(
                        sidebarLayout(
                            sidebarPanel(
                                fileInput("file1", "Choose CSV File",
                                          multiple = TRUE,
                                          accept = c("text/csv",
                                                     "text/comma-separated-values,text/plain",
                                                     ".csv")),
                                tags$hr(),
                                
                                radioButtons("sep", "Separator",
                                             choices = c(Comma = ",",
                                                         Semicolon = ";",
                                                         Tab = "\t"),
                                             selected = ","),
                                tags$hr(),
                                
                                pickerInput(
                                    inputId = "modelo",
                                    label = "Seleccione el modelo que desee",
                                    choices = c("svmLinear3","bayesglm", "rf","xgbLinear","bagEarth","treebag",
                                                "ctree","glm","lm","ranger","cubist","knn"),
                                    selected = c("svmLinear3"),
                                    multiple = FALSE)
                                ),
                            mainPanel(
                                tableOutput("contents")
            )
        )
        )),
        tabItem(tabName = "widgets",
                h2("Widgets tab content"))))))
