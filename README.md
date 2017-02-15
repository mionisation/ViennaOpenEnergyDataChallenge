# ViennaOpenEnergyDataChallenge

This is an interactive Visualization for comparing the costs of using public transport versus the use of a car in the city of Vienna. It has been created for the "Open Energy Data Challenge" ( https://open.wien.gv.at/site/files/2016/12/OEDC1.2.pdf )

It features two plots, one for the cost per person and one for the total amount of persons using public or private transportation. You can specify if the cost should be per year or day. You can also specify custom values of car drivers and average fuel consumption of cars. Otherwise, average year fuel consumption and total licensed cards in Austria will be used.

Check it out here in live mode:
https://mionisation.shinyapps.io/ViennaOpenEnergyDataChallenge/

## Calculations (in brackets: total cost)
* Calculations of public transport:
  Year card price \* (Total tickets sold)
* Calculations of car usage:
  Car km per day \* Fuel price \* Car Fuel Consumption \* (total car amount)

Missing values between time points were estimated via linear and LOESS regression.

### Main data source:

The "Energy report of the City of Vienna" - https://www.data.gv.at/katalog/dataset/stadt-wien_energieberichtderstadtwien

### Additional data sources:

Additional daily kilometers, average fuel consumption of cars: Statistics Austria - http://statistik.at/web_de/statistiken/energie_umwelt_innovation_mobilitaet/energie_und_umwelt/energie/energieeinsatz_der_haushalte/index.html

Amount of cars in Vienna: http://www.statistik.at/web_de/statistiken/energie_umwelt_innovation_mobilitaet/verkehr/strasse/kraftfahrzeuge_-_bestand/index.html

Daily kilometers 2016: VCÖ Austria - https://www.vcoe.at/

Fuel prices 2016: ADAC - https://www.adac.de/infotestrat/tanken-kraftstoffe-und-antrieb/kraftstoffpreise/kraftstoff-durchschnittspreise/

## Tech stuff
Realized with the R shiny framework - http://shiny.rstudio.com

Using solarized theme for plot https://cran.r-project.org/web/packages/ggthemes/vignettes/ggthemes.html

and bootstrap theme "Flatly" https://rstudio.github.io/shinythemes/



## German version:

Die zwei oberen Hauptgraphen bilden den Vergleich der Kosten von Öffibenutzung und PKW-nutzung. Man kann in der linken Kontrolleiste einstellen, ob jährliche oder tägliche Kosten angezeigt werden sollen.

Berechnung für den linken Graph ist:

*Öffikosten = "jahreskarten preis"

*PKW-kosten = "tägliche PKW km" * "Treibstoffpreis" * "Verbrauch"

Für den rechten Graph werden Öffikosten mit "verkauften Jahrestickets" und PKW-Kosten mit "Anzahl der Autos" multipliziert.

Die Default Einstellung ist, dass für "tägliche PKW km", "Verbrauch" und "Anzahl der Autos" die statistischen Daten der entsprechenden Jahre verwendet werden. Man kann diese Werte aber verändern, um einen Einblick dafür zu bekommen, ab wann sich eine Jahreskarte rentieren würde und um verschiedene Szenarios auszuprobieren.

Man kann in den zwei Hauptgraphen auch eine Region auswählen (Mausklick und ziehen).

Dann wird in den linken unteren Graphen die Entwicklung der Ticket- und Treibstoffpreise angezeigt.

Rechts wird der gesamte Betrag angezeigt, um den der Autotransport den öffentlichen Verkehr übersteigt, und welche Art von umweltfreundlichen Energieerzeugungsanlagen, die man (ungefähr) damit bauen könnte.

Missing values between time points were estimated via linear and LOESS regression

Using solarized theme for plot https://cran.r-project.org/web/packages/ggthemes/vignettes/ggthemes.html
and bootstrap theme

Sources:

Hauptdatenquelle, alles bis auf nachfolgend erwähntes: Energy report of the City of Vienna - https://www.data.gv.at/katalog/dataset/stadt-wien_energieberichtderstadtwien
Ergänzende Tageskilometer, Durchschnittsverbrauch: Statistics Austria - http://statistik.at/web_de/statistiken/energie_umwelt_innovation_mobilitaet/energie_und_umwelt/energie/energieeinsatz_der_haushalte/index.html
PKW - Bestand: http://www.statistik.at/web_de/statistiken/energie_umwelt_innovation_mobilitaet/verkehr/strasse/kraftfahrzeuge_-_bestand/index.html
Tageskilometer 2016: VCÖ Austria - https://www.vcoe.at/
Spritpreise 2016: ADAC - https://www.adac.de/infotestrat/tanken-kraftstoffe-und-antrieb/kraftstoffpreise/kraftstoff-durchschnittspreise/
