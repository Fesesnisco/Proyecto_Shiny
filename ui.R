#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Hacedor de curvas ROC y AUC"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            # Input: Select a file ----
            fileInput("file1", "Choose CSV File",
                      multiple = TRUE,
                      accept = c("text/csv",
                                 "text/comma-separated-values,text/plain",
                                 ".csv")),
            # Horizontal line ----
            tags$hr(),
        
            
            # Input: Select separator ----
            radioButtons("sep", "Separator",
                         choices = c(Comma = ",",
                                     Semicolon = ";",
                                     Tab = "\t"),
                         selected = ","),
            
            
            
            # Horizontal line ----
            tags$hr(),

            
        
            pickerInput(
                inputId = "modelo",
                label = "Seleccione el modelo que desee",
                choices = c("svmLinear3","bayesglm", "rf","xgbLinear","bagEarth","treebag",
                            "ctree","glm","lm","ranger","cubist","knn"),
                selected = c("svmLinear3"),
                multiple = FALSE)
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            
            # Output: Data file ----
            tableOutput("contents")
            
            
            
        )
        
    )
)
)
