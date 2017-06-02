#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
library(shiny)
library(dplyr)
library(splines2)
library(ggplot2)

shinyServer(function(input, output) {

    # Load the airquality dataset.
    data("airquality")
    # Remove observations lacking an Ozone measure.
    airquality <- filter(airquality, !is.na(Ozone))

    # Fit the simple linear model
    slm <- lm(Ozone ~ Temp + I(Temp^2) + I(Temp^3) - 1, airquality)
    Ozone.fitlm <- slm$fitted.values

    # Get knot selection
    getKnots <- reactive({as.integer(input$knotSel)})

    # Fit the spline model, with the knot selection
    fitBslm <- eventReactive(input$calcFit, {
        bsMat <- bSpline(airquality$Temp, knots=getKnots(), degree=3)
        bslm <- lm(airquality$Ozone ~ bsMat - 1)
        bslm
    })

    # Generate the plot
    output$ozonePlot <- renderPlot({
        splineMdl <- fitBslm()
        Ozone.fitbslm <- splineMdl$fitted.values

        cols <- c("Simple"="#ef615c", "B-spline"="#20b2aa", "knot"="black")
        g <- ggplot(airquality, aes(x=Temp, y=Ozone)) +
            geom_point(color="blue") +
            geom_line(aes(x=Temp, y=Ozone.fitlm, color="Simple")) +
            geom_line(aes(x=Temp, y=Ozone.fitbslm, color="B-spline")) +
            geom_vline(aes(color="knot"), xintercept=getKnots(), linetype="dashed", size=1) +
            scale_colour_manual(name="Fit Lines",values=cols) +
            ggtitle("Ozone as predicted by Temp", "(knots shown as vertical lines)")
        g
    })
})






