library(ggplot2)
library(ggthemes)
library(shinythemes)
## begin global

lang_ger <- c("Vergleich der Benutzung öffentlicher Verkehrsmittel vs. PKW in Wien", "Mobilitätscheck",
              "Wähle Sprache", "Details der Auswahl", 
              "Gesamttransportation", "Jahr",
              "Preis in Euro", "Oder: Liter pro 100 Kilometer angeben:",
              'Art der Kosten', 'Kosten im Jahr',
              'Kosten am Tag', 'Öffentlich',
              'Auto', 'Art des Transports',
              'Preis: ', "Jahr: ",
              'Selektierte Jahre: ', "Transport pro Person",
              "Oder: Anzahl der Autofahrer in Wien angeben:", "Verwende totale PKW-Zulassungen in Wien",
              "Verwende Durchschnittsverbrauch", " Millionen Euro",
              "Preis in Millionen Euro", "Preis Einzelfahrschein",
              "Preis Benzin/Diesel", "Gespartes Geld: ",
              "Gesamteinsparungen: ", "Verwende gefahrene Durchschnittsstrecken",
              "Oder: Gefahrene Tages-Km angeben")
              #29
lang_eng <- c("Comparison of car usage vs. public services in Vienna", "Mobility check",
              "Choose language", "Detailed look in this selection",
              "Total transportation cost", "Year",
              "Price in Euro", "Or: Specify Liters per 100 Kilometers: ",
              "Types of Cost", "Cost per Year",
              "Cost per day", "Public",
              "Car", "Type of transport",
              "Price: ", "Year: ",
              "Selected years: ", "Transport per person",
              "Or: Specify car drivers in Vienna:", "Use total amount of licensed cars in Vienna",
              "Use average consumption of all cars", " million Euro",
              "Price in million Euro", "Price Single trip",
              "Avg. price petrol/diesel", "Saved money per person: ",
              "Total savings: ", "Use average driven km ",
              "Or: Specify daily driven kilometers")
lang <- lang_ger
selectionStatus <- 0

# data from the energy report and other sources specified in the README.
# Missing values were estimated via linear and loess regression

transportationData <- data.frame (
  year = c(2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016),
  wl_cardsSold = c(303000, 323859, 356625, 370828, 336000, 314875, 363000,	501000, 582000,	650000, 720000, 800000),
  wl_cardsPrice = c(417, 417, 485, 485, 485, 485, 485, 365, 365, 365, 365, 365),
  car_kmPerDay = c(36.06,	36.06,	34.7,	34.7,	35.09,	35.09,	32.82,	32.82,	30.23,	30.23, 30, 30),
  car_PricePerL = c(0.83,	0.89,	0.93,	1.09,	0.90,	1.06,	1.28,	1.38,	1.35,	1.32,	1.22, 1.17),
  car_consumptionPer100km = c(7.4, 7.4, 7.5, 7.5, 7.3, 7.3, 7.3, 7.3, 7.1, 7.1, 7.1, 7.1),
  car_numbers = c( 655806, 658081, 657426, 657192, 663926, 669279, 674526, 679492, 681413, 683258, 685570, 687243),
  wl_ticketPrice = c(1.5, 1.5, 1.7, 1.7, 1.8, 1.8, 1.8, 2, 2.1, 2.2, 2.2, 2.2),
  na = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)
)

languageSelection <- c("English","Deutsch")
names(languageSelection) = c("English", "Deutsch")

## end global 


#Idee: aufschreiben, was gespart werden kann: in kraftwerke pro jahr vielleicht?

## begin server
server <- function(input, output) {
  # change language
  updateUI <- reactive({
    #todo refresh display
    #lang <- switch(input$langSel, German = lang_ger, English = lang_eng )
  })
  
  # compare: total cost of cars: km per day * days * cost per km(diesel/gas according to split) (see: energieanwendung_verkehr_gesamt, energipreise_gesamt)
  #       vs. year card cost * year card sales? (same as before)
  #       vs. rest of cards * travelers (tourists etc.)
  # when brushed: show additional plots: decreasing price, increasing fuel price
  # add: total saved emissions / total saved money
  
  # create the data used in the main plot and transform according to selection input
  mainPlotData <- reactive({
    publicMultiplier = 1
    carMultiplier = 1
    #adjust data if selection is cost per year or per day
    if(input$costType == lang[10]) {
      carMultiplier = 365
    } else {
      publicMultiplier = 1/365
    }
    #adjust if selection is custom value for number of cars or fuel consumption
    carNumber = input$carDrivers
    fuelConsumption = input$LitersPerKm
    if(input$useFuelStatisticValues) {
      fuelConsumption = transportationData$car_consumptionPer100km
    }
    if(input$useCarStatisticValues) {
      carNumber = transportationData$car_numbers
    }
    
    carPricePerPerson = carMultiplier * transportationData$car_PricePerL * transportationData$car_kmPerDay * (fuelConsumption/100)
    main <- data.frame (
      year = transportationData$year,
      publicPrice = transportationData$wl_cardsPrice * publicMultiplier,
      carPrice =  carPricePerPerson,
      publicPriceTotal = transportationData$wl_cardsPrice * publicMultiplier * transportationData$wl_cardsSold/1000000,
      carPriceTotal = carNumber * carPricePerPerson / 1000000
    )
    
  })
  
  ##start text output for hovering / brushing
  output$selectYear <- renderText({
    yearFrom <- input$mainBrush$xmin
    yearTo <- input$mainBrush$xmax
    if(is.null(yearFrom)) {
      yearFrom <- 2005
      yearTo <- 2016
    }
    paste0(lang[17], round(yearFrom), " - ", round(yearTo))
  })
  output$hoverYear <- renderText({
    val <- input$plot_hover$x
    if(is.null(val)) {
      val <- 0
    }
    paste0(lang[16], round(val))
  })
  output$hoverPrice <- renderText({
     val <- input$plot_hover$y
     if(is.null(val)) {
       val <- 0
     }
     paste0(lang[15], round(val, digits = 2), " Euro")
  })
  output$selectYearTotal <- renderText({
    yearFrom <- input$sideBrush$xmin
    yearTo <- input$sideBrush$xmax
    if(is.null(yearFrom)) {
      yearFrom <- 2005
      yearTo <- 2016
    }
    paste0(lang[17], round(yearFrom), " - ", round(yearTo))
  })
  output$hoverYearTotal <- renderText({
    val <- input$plot_hover_total$x
    if(is.null(val)) {
      val <- 0
    }
    paste0(lang[16], round(val))
  })
  output$hoverPriceTotal <- renderText({
    val <- input$plot_hover_total$y
    if(is.null(val)) {
      val <- 0
    }
    paste0(lang[15], round(val, digits = 2), lang[22])
  })
  #todo
  output$savedMoneyTotal <- renderText({
    val <- mainPlotData()
    if(is.null(input$sideBrush$xmin)){
      val <- 0
    } else {
      yF <- max(2005, round(input$sideBrush$xmin))
      yT <- min(2016, round(input$sideBrush$xmax))
      iF <- which(val$year == yF)
      iT <- which(val$year == yT)
      val <- val[iF:iT,] 
      val <- sum((val$carPriceTotal - val$publicPriceTotal))
    }
    paste0(lang[27], round(val, digits = 2), lang[22])
  })
  output$savedMoney <- renderText({
    val <- mainPlotData()
    if(is.null(input$mainBrush$xmin)){
      val <- 0
    } else {
      yF <- max(2005, round(input$mainBrush$xmin))
      yT <- min(2016, round(input$mainBrush$xmax))
      iF <- which(val$year == yF)
      iT <- which(val$year == yT)
      val <- val[iF:iT,] 
      val <- sum((val$carPrice - val$publicPrice))
    }
    
    paste0(lang[26], round(val, digits = 2), " Euro")
  })
  ##end text output for hovering / brushing
  
  ## main plot for per person price
  output$mainPlot <- renderPlot({
    m <- mainPlotData()
    ggplot() +
      geom_line(data=m, aes(x = year, y = publicPrice, color = lang[12]), size=.75 ) +
      geom_point(data=m, aes(x = year, y = publicPrice, color = lang[12]), size=3, fill="white") +
      geom_line(data=m, aes(x = year, y = carPrice, color = lang[13]), size=.75) +
      geom_point(data=m, aes(x = year, y = carPrice, color = lang[13]), size=3, fill="white") + 
      labs(color=lang[14]) +
      xlab(lang[6]) +
      ylab(lang[7]) + 
      expand_limits(y=0) +
      theme_solarized_2(light = TRUE) +
      scale_colour_solarized("blue")
  })
  
  ## plot for total price
  output$sidePlot <- renderPlot({
    m <- mainPlotData()
    ggplot() +
      geom_line(data=m, aes(x = year, y = publicPriceTotal, color = lang[12]), size=.75 ) +
      geom_point(data=m, aes(x = year, y = publicPriceTotal, color = lang[12]), size=3, fill="white") +
      geom_line(data=m, aes(x = year, y = carPriceTotal, color = lang[13]), size=.75) +
      geom_point(data=m, aes(x = year, y = carPriceTotal, color = lang[13]), size=3, fill="white") + 
      labs(color=lang[14]) +
      xlab(lang[6]) +
      ylab(lang[23]) + 
      expand_limits(y=0) +
      theme_solarized_2(light = TRUE) +
      scale_colour_solarized("blue")
  })
  
  getBrushedSubset <- reactive({
    yF = 2005
    yT = 2016
    if(is.null(input$sideBrush$xmin)) {
      if(!is.null(input$mainBrush$xmin)) {
        yF = max(2005, round(input$mainBrush$xmin))
      }
    } else {
      if(is.null(input$mainBrush$xmin)) {
        yF = max(2005, round(input$sideBrush$xmin))
      } else {
        yF <- max(2005, min(round(input$sideBrush$xmin), round(input$mainBrush$xmin)))
      }
    }
    if(is.null(input$sideBrush$xmax)) {
      if(!is.null(input$mainBrush$xmax)) {
        yT = min(2016, round(input$mainBrush$xmax))
      }
    } else {
      if(is.null(input$mainBrush$xmax)) {
        yT = min(2016, round(input$sideBrush$xmax))
      } else {
        yT <- min(2016, max(round(input$sideBrush$xmax), round(input$mainBrush$xmax)))
      }
    }
    iF <- which(transportationData$year == yF)
    iT <- which(transportationData$year == yT)
    tSubset <- transportationData[iF:iT,]
  })
  
  #supporting plot for ticket price
  output$ticketPrice <- renderPlot({
    m <- mainPlotData()
    ggplot() +
      scale_x_date() +
      geom_line(data=getBrushedSubset(), aes(x = as.Date(paste0(year,'-01-01')), y = car_PricePerL), size=.75 ) +
      geom_point(data=getBrushedSubset(), aes(x = as.Date(paste0(year,'-01-01')), y = car_PricePerL), size=3, fill="white") +
      xlab(lang[6]) +
      ylab(lang[25]) + 
      theme_solarized_2(light = TRUE) +
      scale_colour_solarized("blue")
  })
  
  #supporting plot for fuel price
  output$fuelPrice <- renderPlot({
    m <- mainPlotData()
    ggplot() +
      scale_x_date() +
      geom_line(data=getBrushedSubset(), aes(x =  as.Date(paste0(year,'-01-01')), y = wl_ticketPrice), size=.75 ) +
      geom_point(data=getBrushedSubset(), aes(x =  as.Date(paste0(year,'-01-01')), y = wl_ticketPrice), size=3, fill="white") +
      xlab(lang[6]) +
      ylab(lang[24]) + 
      theme_solarized_2(light = TRUE) +
      scale_colour_solarized("blue")
  })
}
## end server


## begin UI

ui <- fluidPage(theme = shinytheme("flatly"),
                tags$head(
                  tags$style(HTML("
                    @import url('//fonts.googleapis.com/css?family=Anton');
                    body {
                      background-color: #fdf6e3;;
                    }
                    h2 {
                      font-family: 'Anton', sans-serif;
                      font-weight: 500;
                      line-height: 1.1;
                    }
                    .checkbox label span{
                      font-weight: bold;
                    }
                  "))
  ),
  
  # Application title
  titlePanel(lang[1], windowTitle = lang[2]),
  
  # Sidebar with a slider input for number of bins 
  fluidRow(
    column( width = 2,
            #selectInput('langSel', lang[3], languageSelection, selected = "Deutsch"),
            radioButtons(inputId = 'costType', label = lang[9], choices = c(lang[10], lang[11])),
            helpText("_"),
            checkboxInput(inputId = 'useFuelStatisticValues', label = lang[21], value = TRUE),
            sliderInput(inputId = 'LitersPerKm', label = lang[8], min = 2, max = 10, value = 8, step = 0.5 ),
            helpText("_"),
            checkboxInput(inputId = 'useKmStatisticValues', label = lang[28], value = TRUE),
            sliderInput(inputId = 'drivenKmPerDay', label = lang[29], min = 0, max = 100, value = 32, step = 1 ),
            helpText("_"),
            checkboxInput(inputId = 'useCarStatisticValues', label = lang[20], value = TRUE),
            sliderInput(inputId = 'carDrivers', label = lang[19], min = 0, max = 800000, value = 680000, step = 10000 )
    ),
    
    # Show a plot of the generated distribution
    column( width = 5,
            helpText(lang[18]),
            plotOutput(outputId = "mainPlot", height = 300,
                       brush = brushOpts(
                          id = "mainBrush",
                          delayType = 'debounce',
                          delay = 200,
                          direction = 'x'
                       ),
                       hover = hoverOpts(
                         id = "plot_hover",
                         delay = 200,
                         delayType = 'throttle',
                         nullOutside = FALSE
                       )
            ),    
            fluidRow(
              column( width = 1
              ),
              column( width = 5,
                      helpText(lang[4]),
                      textOutput("hoverYear"),
                      textOutput("hoverPrice"),
                      helpText("-")

              ),column( width = 6,
                        helpText("-"),
                        textOutput("selectYear"),
                        textOutput("savedMoney"),
                        helpText("-")
              )
              
            ),
            fluidRow(
              column( width = 5,
                      plotOutput(outputId = "fuelPrice", height = 180)
              ),
              column( width = 5,
                      plotOutput(outputId = "ticketPrice", height = 180)
              )
            )#include: how much money/co2 saved compared to how many car owners drive per day
            
    ),
    
    column( width = 5,
    helpText(lang[5]),
    plotOutput(outputId = "sidePlot",height = 300,
               brush = brushOpts(
                 id = "sideBrush",
                 delayType = 'debounce',
                 delay = 200,
                 direction = 'x'
               ),
               hover = hoverOpts(
                 id = "plot_hover_total",
                 delay = 200,
                 delayType = 'throttle',
                 nullOutside = FALSE
               )
    ), 
    fluidRow(
      column( width = 1
      ),
      column( width = 5,
              helpText(lang[4]),
              textOutput("hoverYearTotal"),
              textOutput("hoverPriceTotal"),
              helpText("-")
              
      ),
      column( width = 6,
              helpText("-"),
              textOutput("selectYearTotal"),
              textOutput("savedMoneyTotal"),
              helpText("-")
      )
    )
    ),
    
    position = "right",
    fluid = TRUE
  )
)

## end UI

shinyApp(ui = ui, server = server)