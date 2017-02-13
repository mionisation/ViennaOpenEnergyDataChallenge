## begin global

lang_ger <- c("Vergleich von Benutzung öffentlicher Verkehrsmittel vs. PKW in Wien", "Mobilitätscheck",
              "Wähle Sprache", "Details der Auswahl", 
              "Gesamttransportation", "Jahr",
              "Preis in Euro", "Liter pro 100 Kilometer",
              'Art der Kosten', 'Kosten im Jahr',
              'Kosten am Tag', 'Öffentlich',
              'Auto', 'Art des Transports',
              'Preis: ', "Jahr: ")
lang_eng <- c("Comparison of car usage vs. public services in Vienna", "Mobility check",
              "Choose language", "Detailed look in this selection",
              "Plot of transportation details", "Year",
              "Price in Euro", "Liters per 100 Kilometers",
              "Types of Cost", "Cost per Year",
              "Cost per day", "Public",
              "Car", "Type of transport",
              "Price: ", "Year: ")
lang <- lang_ger

transportationData <- data.frame (
  year = c(2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016),
  wl_cardsSold = c(303000, 323859, 356625, 370828, 336000, 314875, 363000,	501000, 582000,	650000, 720000, 800000),
  wl_cardsPrice = c(417, 417, 485, 485, 485, 485, 485, 365, 365, 365, 365, 365),
  car_kmPerDay = c(36.06,	36.06,	34.7,	34.7,	35.09,	35.09,	32.82,	32.82,	30.23,	30.23, 30, 30),
  car_PricePerL = c(0.83,	0.89,	0.93,	1.09,	0.90,	1.06,	1.28,	1.38,	1.35,	1.32,	1.22, 1.17),
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
    if(input$costType == lang[10]) {
      carMultiplier = 365
    } else {
      publicMultiplier = 1/365
    }
    main <- data.frame (
      year = transportationData$year,
      publicPrice = transportationData$wl_cardsPrice * publicMultiplier,
      carPrice =  carMultiplier * transportationData$car_PricePerL * transportationData$car_kmPerDay * (input$LitersPerKm/100)
    )
    
  })
  
  output$selectYear <- renderText({
    yearFrom <- input$mainBrush$xmin
    yearTo <- input$mainBrush$xmax
    if(is.null(yearFrom)) {
      yearFrom <- 2005
      yearTo <- 2016
    }
    paste0("Years selected: ", round(yearFrom), " to ", round(yearTo))
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

  output$mainPlot <- renderPlot({
    m <- mainPlotData()
    ggplot() +
      geom_line(data=m, aes(x = year, y = publicPrice, color = lang[12]), size=.75 ) +
      geom_point(data=m, aes(x = year, y = publicPrice, color = lang[12]), size=3, fill="white") +
      geom_line(data=m, aes(x = year, y = carPrice, color = lang[13]), size=.75) +
      geom_point(data=m, aes(x = year, y = carPrice, color = lang[13]), size=3, fill="white") + 
      labs(color=lang[14]) +
      xlab(lang[6]) +
      ylab(lang[7])
  })
}
## end server


## begin UI

ui <- fluidPage(
  
  # Application title
  titlePanel(lang[1], windowTitle = lang[2]),
  
  # Sidebar with a slider input for number of bins 
  fluidRow(
    column( width = 3,
            #selectInput('langSel', lang[3], languageSelection, selected = "Deutsch"),
            sliderInput(inputId = 'LitersPerKm', label = lang[8], min = 2, max = 10, value = 8, step = 0.5 ),
            selectInput(inputId = 'costType', label = lang[9], choices = c(lang[10], lang[11])),
            helpText(""),
            helpText("")
    ),
    
    # Show a plot of the generated distribution
    column( width = 6,
            plotOutput(outputId = "mainPlot",
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
            helpText(lang[5])
    ),
    
    column( width = 3,
    #todo: include here selection plots
    helpText(lang[4]),
    textOutput("hoverYear"),
    textOutput("hoverPrice"),
    textOutput("selectYear")
    ),
    
    position = "right",
    fluid = TRUE
  )
)

## end UI

shinyApp(ui = ui, server = server)