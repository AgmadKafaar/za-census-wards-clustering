library(leaflet)
library(RColorBrewer)
library(shiny)
library(geojsonio)
library(stringr)
library(ggplot2)
library(RSQLite)
library(data.table)
source("geocoding.R")
source("data_access.R")

#geojson <- readLines("data/sample-wards.geojson")
wardShapes <- geojson_read("data/wards.geojson", what = "sp")
wardShapes$ward_code <- str_match(pattern = '"MDB"\\: "(.*?)"', 
                                  as.character(wardShapes$codes))[,2]

sqliteCon <- dbConnect(SQLite(), dbname='data/za-census.sqlite')
clusters <- data.table(dbGetQuery(sqliteCon, "SELECT * FROM ward_clusters;"))
setkey(clusters, geo_code)

wardShapes$cluster <- clusters[wardShapes$ward_code]$cluster_id

shinyServer(function(input, output) {
  # Create the map
  output$map <- renderLeaflet({
    pal <- colorFactor(topo.colors(15), 1:15)

    leaflet() %>%
      addTiles(
        urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
      ) %>%
      setView(lng = 18.42, lat = -33.92, zoom = 11) 
      #addPolygons(data = wardShapes, weight = 1, fillColor = ~pal(cluster))
      #addGeoJSON(geojson, weight = 1)
      #addGeoJSON(geojson, weight = 1, fillColor = xpal(geojson$features[1]$properties$cluster))
  })
  
  observe({
    #leafletProxy("map") %>% clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    print(str(event$ward_code))
  })
  
  displayWardDetails <- function(geocode) {
    output$incomeBarplot <- renderPlot({plotWardData(getWardIncome(sqliteCon, geocode), "pink", "Income")})
  }
  
  plotWardData <- function(data, colour, xlab) {
    ggplot(data, aes(x = bin, y = total)) + 
      geom_bar(fill = colour, stat="identity") + 
      labs(x = xlab, y = "") + theme(axis.text.x = element_text(angle = 45, hjust = 1))
  }
  
  observe({
    event <- input$map_click
    if (is.null(event))
      return()
    
    click <- input$map_click
    lat <- click$lat
    lng <- click$lng
    
    cat("Working on it!\n")
    ward <- getWard(lng, lat)
    wardsInSameCluster <- getWardsInSameCluster(sqliteCon, ward$geocode)
    relatedWardsGeoJson <- getGeojsonForWards(wardsInSameCluster)
    cat("Render time!\n")
    leafletProxy("map") %>%
      clearGeoJSON() %>% 
      clearPopups() %>%
      addGeoJSON(relatedWardsGeoJson, weight=1) %>%
      addPopups(lng = lng, lat = lat, popup = sprintf("Ward: %s", ward$name))
    
    displayWardDetails(ward$geocode)
    cat("Plot done!")
  })
})
