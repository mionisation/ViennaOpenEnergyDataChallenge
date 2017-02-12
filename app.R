## begin global

lang_ger <- c("Vergleich von Benutzung öffentlicher Verkehrsmittel vs. PKW in Wien", "Mobilitätscheck",
              "Wähle Sprache", "Details der Auswahl", "Gesamttransportation")
lang_eng <- c("Comparison of car usage vs. public services in Vienna", "Mobility check",
              "Choose language", "Detailed look in this selection", "Plot of transportation details")
lang <- lang_ger

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
  mainData <- data.frame(
    sex = factor(c("Female","Female","Male","Male")),
    time = factor(c("Lunch","Dinner","Lunch","Dinner"), levels=c("Lunch","Dinner")),
    total_bill = c(13.53, 16.81, 16.24, 17.42)
  )
  
  transportationData <- data.frame (
    year = c(2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016),
    wl_yCardsSold = c(303000, NA, NA, NA, 336000, NA, 363000,	501000, 582000,	650000, NA, NA),
    wl_yCardsPrice = c(417, 417, 485, 485, 485, 485, 485, 365, 365, 365, 365, 365),
    car_kmPerDay = c(36.06,	36.06,	34.7,	34.7,	35.09,	35.09,	32.82,	32.82,	30.23,	30.23, NA, 30),
    car_fuelPerL = c(0.83,	0.89,	0.93,	1.09,	0.90,	1.06,	1.28,	1.38,	1.35,	1.32,	1.22, NA),
    car_kmPerL = c(),
    na = c(NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA)
  )
  
  output$mainPlot <- renderPlot({
    ggplot(data=mainData, aes(x=time, y=total_bill, group=sex)) +
      geom_line() +
      geom_point()
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
            helpText(""),
            helpText(""),
            helpText("")
    ),
    
    # Show a plot of the generated distribution
    column( width = 6,
            plotOutput("mainPlot"),
            helpText(lang[5])
    ),
    
    column( width = 1,
    #todo: include here selection plots
    helpText(lang[4])
    ),
    position = "right",
    fluid = TRUE
  )
)

## end UI

shinyApp(ui = ui, server = server)