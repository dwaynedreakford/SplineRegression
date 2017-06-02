#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)

# Get the Temp values, which defines the accepted range of knots
# for the b-spline model.
library(dplyr)
data("airquality")
airquality <- filter(airquality, !is.na(Ozone))
uniqueTemps <- unique(airquality[order(airquality$Temp), "Temp"])
selectedTemps <- sample(uniqueTemps, 2)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Simple Linear vs Spline Fit"),

  # Sidebar
  sidebarLayout(
      sidebarPanel(
        selectInput("knotSel", "Select knot values for B-spline fit:",
                    uniqueTemps, selected=selectedTemps,
                    multiple=TRUE),
        actionButton("calcFit", "Generate Plot")
    ),

    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("ozonePlot"),
       h4("Example Data: airquality {datasets}"),
       p("This plot uses linear models to predict ozone levels based on temperature readings.",
         tags$br(),
         tags$em("Simple formula: "),
         tags$code("lm(Ozone ~ Temp + I(Temp^2) + I(Temp^3) - 1, airquality)"),
         tags$br(),
         tags$em("Spline formula: "),
         tags$code("lm(airquality$Ozone ~ bSpline(airquality$Temp, knots=getKnots(), degree=3) - 1)")
        )
  )
)))




